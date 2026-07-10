import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';

/// Replaces the old Flutter game UI with the HTML/JS Baloot renderer.
///
/// The page hosts a local WebView that loads the adapted HTML game from
/// `assets/web_game/play.html`. Flutter pushes the authoritative game state
/// over a JavaScript bridge and receives user actions (bid, play, declare,
/// double, qaid, sawa) back.
class HtmlGamePlayPage extends StatefulWidget {
  const HtmlGamePlayPage({
    super.key,
    required this.id,
    this.isSpectator = false,
  });

  final String id;
  final bool isSpectator;

  @override
  State<HtmlGamePlayPage> createState() => _HtmlGamePlayPageState();
}

class _HtmlGamePlayPageState extends State<HtmlGamePlayPage>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _webViewReady = false;
  bool _startSent = false;
  Game? _lastPushedGame;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(ColorManager.darkCanvas)
      ..setOnConsoleMessage(_onConsoleMessage)
      ..addJavaScriptChannel(
        'BlootNative',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('WebView page started: $url'),
          onProgress: (progress) => debugPrint('WebView load progress: $progress%'),
          onPageFinished: (_) => _onWebViewReady(),
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description} (errorCode=${error.errorCode}, type=${error.errorType})');
            setState(() => _lastError = error.description);
          },
        ),
      )
      ..loadFlutterAsset('assets/web_game/play.html');

    _configureWebView();

    final cubit = context.read<GameCubit>();
    if (cubit.state == const GameState.initial()) {
      if (widget.isSpectator) {
        cubit.watchGameAsSpectator(widget.id);
      } else {
        cubit.loadGame(widget.id);
      }
    }
  }

  Future<void> _configureWebView() async {
    // Android-specific tweaks so the HTML game behaves like a native game
    // surface: respect the viewport meta tag (so our responsive CSS works) and
    // allow sound effects without requiring a user gesture every cold start.
    if (_controller.platform is AndroidWebViewController) {
      final android = _controller.platform as AndroidWebViewController;
      await android.setUseWideViewPort(true);
      await android.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final agoraService = context.read<AgoraService>();
    if (state == AppLifecycleState.paused) {
      agoraService.enterBackgroundMode();
    } else if (state == AppLifecycleState.resumed) {
      agoraService.leaveBackgroundMode();
    }
  }

  void _onConsoleMessage(JavaScriptConsoleMessage message) {
    debugPrint(
      '[Bloot WebView ${message.level.name}] ${message.message}',
    );
  }

  Future<void> _onWebViewReady() async {
    _webViewReady = true;
    await _runDiagnostics();
    if (!mounted) return;
    _pushStartIfNeeded();
  }

  Future<void> _runDiagnostics() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        """
        JSON.stringify({
          readyState: document.readyState,
          hasBridge: typeof window.__bloot_bridge !== 'undefined',
          hasUi: typeof window.__bloot_ui !== 'undefined',
          hasBalootNet: typeof window.BalootNet !== 'undefined',
          bridgeEnabled: !!window.__BLOOT_BRIDGE_ENABLED,
          bodyHtmlLen: document.body ? document.body.innerHTML.length : 0,
          setupDisplay: document.getElementById('setup-screen')
            ? document.getElementById('setup-screen').style.display
            : 'no-el',
          tableHidden: document.getElementById('table-area')
            ? document.getElementById('table-area').hidden
            : 'no-el',
          topbarHidden: document.getElementById('topbar')
            ? document.getElementById('topbar').hidden
            : 'no-el'
        })
        """,
      );
      debugPrint('WebView diagnostics: $result');
    } catch (e) {
      debugPrint('WebView diagnostics error: $e');
    }
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    debugPrint('[BlootNative] ${message.message}');
    final dynamic payload;
    try {
      payload = jsonDecode(message.message);
    } catch (e) {
      debugPrint('Invalid bridge message: ${message.message}');
      return;
    }

    final type = payload['type'] as String?;
    if (type == 'ready') {
      if (_startSent && _lastPushedGame != null) {
        _pushState(_lastPushedGame!);
      } else {
        _pushStartIfNeeded();
      }
      return;
    }

    if (type == 'action') {
      _handleAction(payload as Map<String, dynamic>);
      return;
    }

    if (type == 'exit') {
      _onPop();
      return;
    }

    debugPrint('Bridge message: $payload');
  }

  void _handleAction(Map<String, dynamic> payload) {
    final cubit = context.read<GameCubit>();
    final action = payload['action'] as String?;

    switch (action) {
      case 'bid':
        final bid = payload['bid'] as String?;
        if (bid != null) cubit.placeBid(bid);
      case 'play':
        final card = payload['card'] as String?;
        if (card != null) cubit.playCard(card);
      case 'declare':
        final types = (payload['claimedTypes'] as List<dynamic>?)
            ?.cast<String>();
        cubit.declareProject(types ?? []);
      case 'double':
        final double = payload['double'] as String?;
        cubit.applyDouble(double ?? 'pass');
      case 'qaid':
        final claimType = payload['claimType'] as String?;
        cubit.claimQaid(claimType);
      case 'sawa':
        cubit.claimSawa();
    }
  }

  void _pushStartIfNeeded() {
    if (!_webViewReady || !mounted) return;

    final game = _extractGame(context.read<GameCubit>().state);
    if (game == null) return;

    if (_startSent) {
      _pushState(game);
    } else {
      _sendStart(game);
    }
  }

  void _sendStart(Game game) {
    _startSent = true;
    debugPrint('[HtmlGame] sending start for ${game.id}, seat ${game.mySeatIndex}');
    _send('start', <String, dynamic>{
      'gameId': game.id,
      'seat': game.mySeatIndex,
      'safeMode': true,
      'players': game.players.map(_playerToJson).toList(),
    });
    _pushState(game);
  }

  void _pushState(Game game) {
    if (!_webViewReady) return;
    _lastPushedGame = game;
    debugPrint('[HtmlGame] pushing state status=${game.status}');
    _send('state', <String, dynamic>{
      'engineState': game.engineState,
      'players': game.players.map(_playerToJson).toList(),
    });
    if (mounted) setState(() => _lastError = null);
  }

  void _send(String type, Map<String, dynamic> payload) {
    final msg = jsonEncode(<String, dynamic>{'type': type, ...payload});
    debugPrint('[HtmlGame] JS >> $type');
    _controller.runJavaScript('window.__bloot_bridge.receive($msg)');
  }

  Map<String, dynamic> _playerToJson(GamePlayer p) {
    return <String, dynamic>{
      'seat': p.seatIndex,
      'name': p.name,
      'avatarUrl': p.avatarUrl,
      'team': p.team,
      'isBot': false,
      'isMuted': p.isMuted,
      'hasCamera': p.hasCamera,
      'isConnected': p.isConnected,
    };
  }

  Future<void> _onPop() async {
    final cubit = context.read<GameCubit>();
    final router = GoRouter.of(context);
    await cubit.leaveGame();
    if (mounted) router.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const Scaffold(
        body: Center(
          child: Text('HTML game is only available on Android and iOS.'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPop();
      },
      child: Scaffold(
        backgroundColor: ColorManager.darkCanvas,
        body: BlocListener<GameCubit, GameState>(
          listenWhen: (previous, current) =>
              current.maybeMap(
                error: (_) => true,
                orElse: () => false,
              ) ||
              _extractGame(current) != null,
          listener: (context, state) {
            debugPrint('[HtmlGame] cubit state: ${state.runtimeType}');
            state.mapOrNull(
              error: (s) {
                _send('error', {'message': s.message});
                setState(() => _lastError = s.message);
              },
            );
            final game = _extractGame(state);
            if (game != null) _pushStartIfNeeded();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _controller),
              // Loading / error overlay until the first state is pushed.
              if (!_startSent || _lastError != null)
                Positioned.fill(
                  child: ColoredBox(
                    color: ColorManager.darkCanvas.withValues(alpha: 0.92),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_lastError != null)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _lastError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: ColorManager.error,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            const CircularProgressIndicator(
                              color: ColorManager.primary,
                            ),
                          const SizedBox(height: 16),
                          Text(
                            _lastError != null
                                ? 'Failed to load game'
                                : 'Starting game…',
                            style: const TextStyle(
                              color: ColorManager.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Game? _extractGame(GameState state) {
    return state.mapOrNull(
      dealing: (s) => s.game,
      bidding: (s) => s.game,
      bonusClaim: (s) => s.game,
      playing: (s) => s.game,
      trickEnd: (s) => s.game,
      roundEnd: (s) => s.game,
      gameEnd: (s) => s.game,
    );
  }
}
