import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:bloot/firebase_options.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';
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
  String? _lastPushedPayload;
  String? _lastError;
  String? _rtdbToken;
  bool _rtdbAuthInProgress = false;
  bool _rtdbActive = false;
  DateTime _lastAudioResume = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = _createWebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(ColorManager.darkCanvas)
      ..setOnConsoleMessage(_onConsoleMessage)
      ..addJavaScriptChannel('BlootNative', onMessageReceived: _onBridgeMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('WebView page started: $url'),
          onProgress: (progress) =>
              debugPrint('WebView load progress: $progress%'),
          onPageFinished: (_) => _onWebViewReady(),
          onWebResourceError: (error) {
            debugPrint(
              'WebView error: ${error.description} (errorCode=${error.errorCode}, type=${error.errorType})',
            );
            setState(() => _lastError = error.description);
          },
        ),
      )
      ;

    _configureWebView();
    _loadGamePage();

    final cubit = context.read<GameCubit>();
    if (cubit.state == const GameState.initial()) {
      if (widget.isSpectator) {
        cubit.watchGameAsSpectator(widget.id);
      } else {
        cubit.loadGame(widget.id);
      }
    }
  }

  WebViewController _createWebViewController() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return WebViewController.fromPlatformCreationParams(
        WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        ),
      );
    }
    return WebViewController();
  }

  Future<void> _configureWebView() async {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      // Android: respect the viewport meta tag and allow sound effects without
      // requiring a user gesture every cold start.
      await platform.setUseWideViewPort(true);
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  Future<void> _loadGamePage() async {
    // Load the bundled HTML game directly. We intentionally avoid clearing the
    // WebView cache on every launch because it causes a noticeable stall on
    // lower-end devices. Flutter assets are version-locked to the app binary,
    // so the bundled JS/CSS are always current.
    await _controller.loadFlutterAsset('assets/web_game/play.html');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Tell the WebView to stop its RTDB watcher and release audio/DOM resources
    // before the native view is torn down.
    try {
      _controller.runJavaScript(
        'if (window.__bloot_bridge && window.__bloot_bridge.stopRtdb) __bloot_bridge.stopRtdb();',
      );
      _controller.loadRequest(Uri.parse('about:blank'));
    } catch (e) {
      debugPrint('[HtmlGame] dispose cleanup error: $e');
    }
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
    debugPrint('[Bloot WebView ${message.level.name}] ${message.message}');
  }

  Future<void> _onWebViewReady() async {
    _webViewReady = true;
    await _runDiagnostics();
    await _resumeWebAudio();
    if (!mounted) return;
    _pushStartIfNeeded();
  }

  Future<void> _resumeWebAudio() async {
    final now = DateTime.now();
    if (now.difference(_lastAudioResume) < const Duration(seconds: 1)) return;
    _lastAudioResume = now;
    try {
      await _controller.runJavaScript(
        'if (window.BalootVoice && BalootVoice.resumeAudio) BalootVoice.resumeAudio();',
      );
    } catch (e) {
      debugPrint('[HtmlGame] resumeAudio error: $e');
    }
  }

  Future<void> _resetWebViewAck() async {
    try {
      await _controller.runJavaScript(
        'if (window.__bloot_ui && __bloot_ui.resetAck) __bloot_ui.resetAck();',
      );
    } catch (e) {
      debugPrint('[HtmlGame] resetAck error: $e');
    }
  }

  Future<void> _runDiagnostics() async {
    try {
      final result = await _controller.runJavaScriptReturningResult("""
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
        """);
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

    if (type == 'rtdbActive') {
      debugPrint('[HtmlGame] RTDB fast path confirmed by WebView');
      _rtdbActive = true;
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
        break;
      case 'play':
        final card = payload['card'] as String?;
        if (card != null) cubit.playCard(card);
        break;
      case 'declare':
        final types = (payload['claimedTypes'] as List<dynamic>?)
            ?.cast<String>();
        cubit.declareProject(types ?? []);
        break;
      case 'double':
        final double = payload['double'] as String?;
        cubit.applyDouble(double ?? 'pass');
        break;
      case 'qaid':
        final claimType = payload['claimType'] as String?;
        cubit.claimQaid(claimType);
        break;
      case 'sawa':
        cubit.claimSawa();
        break;
      case 'nextRound':
        cubit.dealNextRound();
        break;
    }
  }

  void _pushStartIfNeeded() {
    if (!_webViewReady || !mounted) return;

    final game = _extractGame(context.read<GameCubit>().state);
    if (game == null) return;

    if (_startSent) {
      _pushState(game);
    } else {
      _ensureRtdbToken().then((_) => _sendStart(game));
    }
  }

  Future<void> _ensureRtdbToken() async {
    if (_rtdbToken != null || _rtdbAuthInProgress) return;
    _rtdbAuthInProgress = true;
    try {
      final repo = getIt<GameRepository>();
      _rtdbToken = await repo.createRtdbToken();
    } catch (e) {
      debugPrint('[HtmlGame] failed to get RTDB token: $e');
    } finally {
      _rtdbAuthInProgress = false;
    }
  }

  Map<String, dynamic> _buildRtdbConfig(String gameId) {
    const web = DefaultFirebaseOptions.web;
    return <String, dynamic>{
      'firebaseConfig': <String, dynamic>{
        'apiKey': web.apiKey,
        'authDomain': web.authDomain,
        'databaseURL':
            FirebaseDatabase.instance.databaseURL ??
            'https://bloot-89b2b-default-rtdb.firebaseio.com',
        'projectId': web.projectId,
        'storageBucket': web.storageBucket,
        'messagingSenderId': web.messagingSenderId,
        'appId': web.appId,
        'measurementId': web.measurementId,
      },
      'gameId': gameId,
      'token': _rtdbToken,
    };
  }

  void _sendStart(Game game) {
    _startSent = true;
    debugPrint(
      '[HtmlGame] sending start for ${game.id}, seat ${game.mySeatIndex}',
    );
    _send('start', <String, dynamic>{
      'gameId': game.id,
      'seat': game.mySeatIndex,
      'safeMode': true,
      'players': game.players.map(_playerToJson).toList(),
      'rtdbConfig': _buildRtdbConfig(game.id),
    });
    _pushState(game);
  }

  void _pushState(Game game) {
    if (!_webViewReady) return;
    _lastPushedGame = game;
    // Once the WebView confirms RTDB is delivering snapshots, the JS bridge
    // state push is redundant and only burns CPU/battery. Keep audio resume
    // and error clearing so the UI stays responsive.
    if (_rtdbActive) {
      debugPrint('[HtmlGame] RTDB active; skipping bridge state push');
      _resumeWebAudio();
      if (mounted) setState(() => _lastError = null);
      return;
    }
    final payload = <String, dynamic>{
      'engineState': game.engineState,
      'status': game.status,
      'players': game.players.map(_playerToJson).toList(),
    };
    final payloadJson = jsonEncode(payload);
    if (_lastPushedPayload == payloadJson) {
      debugPrint('[HtmlGame] payload unchanged; skipping bridge state push');
      _resumeWebAudio();
      if (mounted) setState(() => _lastError = null);
      return;
    }
    _lastPushedPayload = payloadJson;
    debugPrint('[HtmlGame] pushing state status=${game.status}');
    _send('state', payload);
    _resumeWebAudio();
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
              current.maybeMap(error: (_) => true, orElse: () => false) ||
              _extractGame(current) != null,
          listener: (context, state) {
            debugPrint('[HtmlGame] cubit state: ${state.runtimeType}');
            state.mapOrNull(
              error: (s) {
                _send('error', {'message': s.message});
                setState(() => _lastError = s.message);
              },
            );
            final lastError = _extractLastActionError(state);
            if (lastError != null) _resetWebViewAck();
            final game = _extractGame(state);
            if (game != null) _pushStartIfNeeded();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _controller),
              _buildMediaControls(),
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

  String? _extractLastActionError(GameState state) {
    return state.mapOrNull(
      dealing: (s) => s.lastActionError,
      bidding: (s) => s.lastActionError,
      bonusClaim: (s) => s.lastActionError,
      playing: (s) => s.lastActionError,
      trickEnd: (s) => s.lastActionError,
      roundEnd: (s) => s.lastActionError,
      gameEnd: (s) => s.lastActionError,
    );
  }

  Widget _buildMediaControls() {
    // Spectators don't publish audio/video; no local toggles needed.
    if (widget.isSpectator) return const SizedBox.shrink();

    final agoraService = context.read<AgoraService>();
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MediaToggleButton(
                icon: agoraService.isMicOn
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                color: agoraService.isMicOn
                    ? ColorManager.success
                    : ColorManager.error,
                onTap: () async {
                  await context.read<GameCubit>().toggleMic();
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(width: AppSpacing.md),
              _MediaToggleButton(
                icon: agoraService.isCameraOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                color: agoraService.isCameraOn
                    ? ColorManager.success
                    : ColorManager.darkTextMuted,
                onTap: () async {
                  await context.read<GameCubit>().toggleCamera();
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaToggleButton extends StatelessWidget {
  const _MediaToggleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
