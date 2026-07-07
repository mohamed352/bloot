import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/cubit/game_state.dart';
import 'package:bloot/features/game/presentation/widgets/bidding_overlay.dart';
import 'package:bloot/features/game/presentation/widgets/bonus_claim_overlay.dart';
import 'package:bloot/features/game/presentation/widgets/final_score_overlay.dart';
import 'package:bloot/features/game/presentation/widgets/round_score_overlay.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/features/game/presentation/widgets/disconnect_overlay.dart';
import 'package:bloot/features/game/presentation/widgets/game_tutorial_overlay.dart';
import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card.dart';


class GamePlayPage extends StatefulWidget {
  const GamePlayPage({super.key, required this.id, this.isSpectator = false});
  final String id;
  final bool isSpectator;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final List<AnimationController> _activeControllers = [];
  final GlobalKey _tableKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};
  String? _draggedCard;
  OverlayEntry? _dragOverlayEntry;
  final ValueNotifier<Offset> _dragPosition = ValueNotifier(Offset.zero);
  Timer? _hideControlsTimer;
  Timer? _disconnectCountdownTimer;
  int _disconnectSeconds = 30;
  bool _isDisconnected = false;
  bool _showTutorial = false;
  late bool _isMicOn;
  late bool _isCameraOn;

  bool get _isLocalGame => widget.id.startsWith('sim_');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // The route already initializes the cubit with loadGame/watchGame, so we
    // do not start watching again here. This prevents duplicate subscriptions
    // and avoids resetting the game state.

    final agoraService = context.read<AgoraService>();
    _isMicOn = agoraService.isMicOn;
    _isCameraOn = agoraService.isCameraOn;

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.read<GameCubit>().hideControls();
    });

    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    if (widget.isSpectator) return;
    final shouldShow = await GameTutorialOverlay.shouldShow();
    if (shouldShow && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideControlsTimer?.cancel();
    _disconnectCountdownTimer?.cancel();
    _dragOverlayEntry?.remove();
    _dragPosition.dispose();
    for (final controller in _activeControllers) {
      controller.dispose();
    }
    _activeControllers.clear();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startDisconnectCountdown() {
    if (_isLocalGame) return;
    _disconnectCountdownTimer?.cancel();
    _disconnectSeconds = 30;
    _isDisconnected = true;
    if (mounted) setState(() {});
    _disconnectCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _disconnectSeconds--;
      });
      if (_disconnectSeconds <= 0) {
        _disconnectCountdownTimer?.cancel();
        if (mounted) {
          context.read<GameCubit>().leaveGame();
          context.goNamed(RouteNames.home);
        }
      }
    });
  }

  void _stopDisconnectCountdown() {
    _disconnectCountdownTimer?.cancel();
    setState(() {
      _isDisconnected = false;
      _disconnectSeconds = 30;
    });
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

  void _playCard(String card, Game game) {
    if (game.status != 'playing' ||
        !game.isMyTurn ||
        !game.myHand.contains(card)) {
      return;
    }

    // Play the card immediately so it shows on the table right away.
    // The previous overlay fly animation delayed the state update and felt
    // buggy, especially when cards did not land cleanly with the others.
    _finalizeCardPlay(card);
  }

  void _finalizeCardPlay(String card) {
    if (mounted) {
      HapticFeedback.lightImpact();
      context.read<AudioService>().playCardSound();
      context.read<GameCubit>().playCard(card);
      context.read<GameCubit>().selectCard(null);
    }
  }

  void _startCardDrag(String card, DragStartDetails details) {
    if (_draggedCard != null) return;
    final cardKey = _cardKeys[card];
    final cardRenderBox =
        cardKey?.currentContext?.findRenderObject() as RenderBox?;
    final cardPosition = cardRenderBox?.localToGlobal(Offset.zero);
    if (cardPosition == null) return;

    _draggedCard = card;
    _dragPosition.value = cardPosition;

    final overlay = Overlay.of(context);
    _dragOverlayEntry = OverlayEntry(
      builder: (context) {
        return ValueListenableBuilder<Offset>(
          valueListenable: _dragPosition,
          builder: (context, offset, child) {
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: child!,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: PlayingCardWidget(
              card: PlayingCard.fromString(card),
            ),
          ),
        );
      },
    );
    overlay.insert(_dragOverlayEntry!);
  }

  void _updateCardDrag(DragUpdateDetails details) {
    if (_draggedCard == null) return;
    _dragPosition.value += details.delta;
  }

  void _endCardDrag(String card, Game game, DragEndDetails details) {
    final dragged = _draggedCard;
    final overlayEntry = _dragOverlayEntry;
    if (dragged != card || overlayEntry == null) return;

    final tableRenderBox =
        _tableKey.currentContext?.findRenderObject() as RenderBox?;
    final tablePosition = tableRenderBox?.localToGlobal(Offset.zero);
    final tableSize = tableRenderBox?.size;

    final cardWidth = PlayingCardStyle.standard.width;
    final cardHeight = PlayingCardStyle.standard.height;

    bool isOverTable = false;
    if (tablePosition != null && tableSize != null) {
      final tableRect = tablePosition & tableSize;
      final cardCenter = _dragPosition.value +
          Offset(cardWidth / 2, cardHeight / 2);
      isOverTable = tableRect.contains(cardCenter);
    }

    if (isOverTable) {
      overlayEntry.remove();
      _dragOverlayEntry = null;
      _draggedCard = null;
      _playCard(card, game);
      return;
    }

    // Not over the table: animate the card back to the hand.
    final cardKey = _cardKeys[card];
    final cardRenderBox =
        cardKey?.currentContext?.findRenderObject() as RenderBox?;
    final cardPosition = cardRenderBox?.localToGlobal(Offset.zero);

    if (cardPosition != null) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _activeControllers.add(controller);
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
      final startOffset = _dragPosition.value;

      animation.addListener(() {
        _dragPosition.value = Offset.lerp(
          startOffset,
          cardPosition,
          animation.value,
        )!;
      });

      controller.forward().whenComplete(() {
        overlayEntry.remove();
        _dragOverlayEntry = null;
        _draggedCard = null;
        _activeControllers.remove(controller);
        controller.dispose();
      });
    } else {
      overlayEntry.remove();
      _dragOverlayEntry = null;
      _draggedCard = null;
    }
  }

  void _toggleControls() {
    context.read<GameCubit>().toggleControls();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final cubit = context.read<GameCubit>();
        final router = GoRouter.of(context);
        await cubit.leaveGame();
        if (mounted) router.goNamed(RouteNames.home);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: _toggleControls,
        child: Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) {
              final prevError = previous.mapOrNull(
                dealing: (s) => s.lastActionError,
                bidding: (s) => s.lastActionError,
                bonusClaim: (s) => s.lastActionError,
                playing: (s) => s.lastActionError,
                trickEnd: (s) => s.lastActionError,
                roundEnd: (s) => s.lastActionError,
                gameEnd: (s) => s.lastActionError,
              );
              final currError = current.mapOrNull(
                dealing: (s) => s.lastActionError,
                bidding: (s) => s.lastActionError,
                bonusClaim: (s) => s.lastActionError,
                playing: (s) => s.lastActionError,
                trickEnd: (s) => s.lastActionError,
                roundEnd: (s) => s.lastActionError,
                gameEnd: (s) => s.lastActionError,
              );
              return prevError != currError &&
                  currError != null &&
                  currError.isNotEmpty;
            },
            listener: (context, state) {
              final message = state.mapOrNull(
                dealing: (s) => s.lastActionError,
                bidding: (s) => s.lastActionError,
                bonusClaim: (s) => s.lastActionError,
                playing: (s) => s.lastActionError,
                trickEnd: (s) => s.lastActionError,
                roundEnd: (s) => s.lastActionError,
                gameEnd: (s) => s.lastActionError,
              );
              if (message == null || message.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: ColorManager.error,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
              context.read<GameCubit>().clearLastActionError();
            },
            child: BlocListener<ConnectivityCubit, ConnectivityState>(
              listenWhen: (previous, current) =>
                  previous.isConnected != current.isConnected,
              listener: (context, state) {
                if (!state.isConnected) {
                  _startDisconnectCountdown();
                } else {
                  _stopDisconnectCountdown();
                }
              },
              child: Stack(
                children: [
                  BlocConsumer<GameCubit, GameState>(
                    listener: (context, state) {
                      // Auto-hide controls after state change
                      state.maybeWhen(
                        playing: (game, controlsVisible, selectedCardIndex,
                            actionInProgress, lastActionError) {
                              _hideControlsTimer?.cancel();
                              _hideControlsTimer = Timer(
                                const Duration(seconds: 3),
                                () {
                                  if (mounted) {
                                    context.read<GameCubit>().hideControls();
                                  }
                                },
                              );
                            },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return state.map(
                        initial: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        loading: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        dealing: (s) => _buildGameLayout(
                          s.game,
                          s.controlsVisible,
                          s.selectedCardIndex,
                          isDealing: true,
                        ),
                        bidding: (s) => widget.isSpectator || !s.game.isMyTurn
                            ? _buildGameLayout(
                                s.game,
                                s.controlsVisible,
                                s.selectedCardIndex,
                              )
                            : Stack(
                                children: [
                                  _buildGameLayout(
                                    s.game,
                                    s.controlsVisible,
                                    s.selectedCardIndex,
                                  ),
                                  BiddingOverlay(
                                    currentBidder:
                                        s.game.currentPlayer?.name ?? '',
                                    isEnabled: s.game.isMyTurn,
                                    faceUpCard: s.game.faceUpCard,
                                    timeLeft: context
                                        .read<GameCubit>()
                                        .humanTurnTimeoutDuration
                                        .inSeconds,
                                    onBid: (bid) =>
                                        context.read<GameCubit>().placeBid(bid),
                                  ),
                                ],
                              ),
                        bonusClaim: (s) =>
                            widget.isSpectator || !s.game.isMyTurn
                            ? _buildGameLayout(
                                s.game,
                                s.controlsVisible,
                                s.selectedCardIndex,
                              )
                            : Stack(
                                children: [
                                  _buildGameLayout(
                                    s.game,
                                    s.controlsVisible,
                                    s.selectedCardIndex,
                                  ),
                                  BonusClaimOverlay(
                                    hand: s.game.myHand,
                                    onClaim: (bonuses) => context
                                        .read<GameCubit>()
                                        .claimBonuses(bonuses),
                                    onPass: () => context
                                        .read<GameCubit>()
                                        .claimBonuses([]),
                                  ),
                                ],
                              ),
                        playing: (s) => _buildGameLayout(
                          s.game,
                          s.controlsVisible,
                          s.selectedCardIndex,
                        ),
                        trickEnd: (s) => _buildGameLayout(
                          s.game,
                          s.controlsVisible,
                          s.selectedCardIndex,
                          winnerSeat: s.winnerSeat,
                        ),
                        roundEnd: (s) => Stack(
                          children: [
                            _buildGameLayout(
                              s.game,
                              s.controlsVisible,
                              s.selectedCardIndex,
                            ),
                            RoundScoreOverlay(
                              teamAScore: s.teamAPoints,
                              teamBScore: s.teamBPoints,
                              roundPoints: s.fellTeam != null
                                  ? {
                                      '${s.fellTeam == s.game.localTeam ? 'us'.tr() : 'them'.tr()} ${'fell'.tr()}':
                                          s.fellTeam == s.game.localTeam
                                          ? 0
                                          : (s.game.gameType == 'hokm'
                                                ? 152
                                                : 120),
                                    }
                                  : {},
                              onNextRound: () =>
                                  context.read<GameCubit>().dealNextRound(),
                            ),
                          ],
                        ),
                        gameEnd: (s) => Stack(
                          children: [
                            _buildGameLayout(
                              s.game,
                              s.controlsVisible,
                              s.selectedCardIndex,
                            ),
                            FinalScoreOverlay(
                              teamAScore: s.game.scoreUs,
                              teamBScore: s.game.scoreThem,
                              isWinner: s.winnerTeam == s.game.localTeam,
                              onRematch: () {
                                final cubit = context.read<GameCubit>();
                                final router = GoRouter.of(context);
                                cubit.rematch().then((_) {
                                  if (!mounted) return;
                                  if (_isLocalGame) {
                                    // Local simulator restarts in-place.
                                    return;
                                  }
                                  final roomId = s.game.roomId;
                                  if (roomId != null && roomId.isNotEmpty) {
                                    router.goNamed(
                                      RouteNames.roomLobby,
                                      pathParameters: {'id': roomId},
                                    );
                                  } else {
                                    router.goNamed(RouteNames.home);
                                  }
                                });
                              },
                              onHome: () => context.goNamed(RouteNames.home),
                            ),
                          ],
                        ),
                        error: (s) => Center(
                          child: Text(
                            s.message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_isDisconnected)
                    DisconnectOverlay(
                      secondsRemaining: _disconnectSeconds,
                      onExit: () {
                        _disconnectCountdownTimer?.cancel();
                        context.read<GameCubit>().leaveGame();
                        context.goNamed(RouteNames.home);
                      },
                    ),
                  if (_showTutorial)
                    GameTutorialOverlay(
                      onDone: () => setState(() => _showTutorial = false),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameLayout(
    Game game,
    bool controlsVisible,
    int? selectedCardIndex, {
    bool isDealing = false,
    int? winnerSeat,
  }) {
    // Map players to seats relative to the local player:
    // bottom = local (you), top = partner, left/right = opponents.
    final players = game.players;
    final mySeat = game.mySeatIndex;
    final myPlayer = game.localPlayer;

    final topSeat = (mySeat + 2) % 4;
    final leftSeat = (mySeat + 1) % 4;
    final rightSeat = (mySeat + 3) % 4;

    final topPlayer = players.firstWhere(
      (p) => p.seatIndex == topSeat,
      orElse: () => players[0],
    );
    final leftPlayer = players.firstWhere(
      (p) => p.seatIndex == leftSeat,
      orElse: () => players[1],
    );
    final rightPlayer = players.firstWhere(
      (p) => p.seatIndex == rightSeat,
      orElse: () => players[2],
    );

    final isMyTurn = game.isMyTurn;
    final tableCards = game.playedCards;

    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorManager.gameTableTop, ColorManager.gameTableBot],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Game layout
        SafeArea(
          child: Padding(
            // Keep bottom padding constant so the game area does not resize
            // (and therefore zoom) when the control bars hide/show.
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 76),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Scale the board down on very short landscape screens so the
                // hand + seats fit without vertical overflow.
                final layoutScale = constraints.maxHeight < 420
                    ? (constraints.maxHeight / 420).clamp(0.72, 1.0)
                    : 1.0;
                return Column(
                  children: [
                    // Top player (partner)
                    _GamePlayerSeat(
                      player: topPlayer,
                      isMe: myPlayer.seatIndex == topPlayer.seatIndex,
                      isActive: game.turnIndex == topPlayer.seatIndex,
                      scale: layoutScale,
                    ),
                    // Middle row: left, table, right
                    Expanded(
                      child: Row(
                        children: [
                          // Left player (opponent)
                          _GamePlayerSeat(
                            player: leftPlayer,
                            isMe: myPlayer.seatIndex == leftPlayer.seatIndex,
                            isActive: game.turnIndex == leftPlayer.seatIndex,
                            scale: layoutScale,
                          ),
                          const SizedBox(width: 12),
                          // Game table
                          Flexible(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1.4,
                                child: Container(
                                  key: _tableKey,
                                  decoration: BoxDecoration(
                                    color: ColorManager.gameTableTop.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.gameTable,
                                    ),
                                    border: Border.all(
                                      color: ColorManager.gameTableBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, tableConstraints) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Score + trump at top of table
                                          PositionedDirectional(
                                            top: 12,
                                            start: 0,
                                            end: 0,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Score chip
                                                Container(
                                                  padding:
                                                      const EdgeInsetsDirectional.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: FittedBox(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'us'.tr(),
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ColorManager
                                                                .darkTextSecondary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${game.scoreUs}',
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: ColorManager
                                                                .darkTextPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Text(
                                                          '—',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: ColorManager
                                                                .darkTextMuted,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '${game.scoreThem}',
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: ColorManager
                                                                .secondary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'them'.tr(),
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ColorManager
                                                                .secondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (game.gameType != null)
                                                  Container(
                                                    padding:
                                                        const EdgeInsetsDirectional.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: ColorManager
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      game.gameType == 'hokm'
                                                          ? '${LocaleKeys.hokm.tr()} ${game.trump}'
                                                          : LocaleKeys.sun.tr(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: ColorManager
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Played cards in center
                                          ...tableCards.asMap().entries.map((
                                            entry,
                                          ) {
                                            final seatIndex = entry.key;
                                            final cardString = entry.value;
                                            if (cardString == null) {
                                              return const SizedBox.shrink();
                                            }
                                            return Transform.translate(
                                              offset: _playedCardOffset(
                                                seatIndex,
                                                mySeat,
                                                tableConstraints.biggest,
                                              ),
                                              child: PlayingCardWidget(
                                                card: PlayingCard.fromString(
                                                  cardString,
                                                ),
                                                style: PlayingCardStyle.gameTable
                                                    .copyWith(
                                                      width: 44,
                                                      height: 62,
                                                      centerSuitSize: 22,
                                                    ),
                                              ),
                                            );
                                          }),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right player (opponent)
                          _GamePlayerSeat(
                            player: rightPlayer,
                            isMe: myPlayer.seatIndex == rightPlayer.seatIndex,
                            isActive: game.turnIndex == rightPlayer.seatIndex,
                            scale: layoutScale,
                          ),
                        ],
                      ),
                    ),
                    // My hand area (bottom - you)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // My player info
                        _GamePlayerSeat(
                          player: myPlayer,
                          isMe: true,
                          isActive: isMyTurn,
                          scale: layoutScale,
                        ),
                        SizedBox(height: 4 * layoutScale),
                        // Cards
                        if (!isDealing && !widget.isSpectator)
                          _buildHand(game, scale: layoutScale),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // Top controls overlay
        if (controlsVisible)
          SafeArea(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: ColorManager.darkTextPrimary,
                    ),
                    onPressed: () => _showLeaveDialog(context),
                  ),
                  if (widget.isSpectator)
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 8),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'spectating'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.primary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (!widget.isSpectator && !_isLocalGame) ...[
                    _ControlIcon(
                      _isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                      _isMicOn
                          ? ColorManager.success
                          : ColorManager.darkTextMuted,
                      onPressed: () async {
                        await context.read<GameCubit>().toggleMic();
                        setState(() {
                          _isMicOn = context.read<AgoraService>().isMicOn;
                        });
                      },
                    ),
                    _ControlIcon(
                      _isCameraOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      _isCameraOn
                          ? ColorManager.success
                          : ColorManager.darkTextMuted,
                      onPressed: () async {
                        await context.read<GameCubit>().toggleCamera();
                        setState(() {
                          _isCameraOn = context.read<AgoraService>().isCameraOn;
                        });
                      },
                    ),
                  ],

                ],
              ),
            ),
          ),
        // Bottom control bar
        if (controlsVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Gradient background - not hit-testable so it doesn't block
                  // taps/swipes on the card hand underneath.
                  IgnorePointer(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const SizedBox(width: double.infinity, height: 48),
                    ),
                  ),
                  // Actual tappable buttons.
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!widget.isSpectator && !_isLocalGame) ...[
                          const SizedBox(width: 16),
                          _BottomControlButton(
                            icon: _isMicOn
                                ? Icons.mic_rounded
                                : Icons.mic_off_rounded,
                            color: _isMicOn
                                ? ColorManager.success
                                : ColorManager.darkTextMuted,
                            onTap: () async {
                              await context.read<GameCubit>().toggleMic();
                              setState(() {
                                _isMicOn = context.read<AgoraService>().isMicOn;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          _BottomControlButton(
                            icon: _isCameraOn
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                            color: _isCameraOn
                                ? ColorManager.success
                                : ColorManager.darkTextMuted,
                            onTap: () async {
                              await context.read<GameCubit>().toggleCamera();
                              setState(() {
                                _isCameraOn = context
                                    .read<AgoraService>()
                                    .isCameraOn;
                              });
                            },
                          ),
                        ],
                        const SizedBox(width: 16),
                        _BottomControlButton(
                          icon: Icons.logout_rounded,
                          color: ColorManager.error,
                          onTap: () => _showLeaveDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHand(Game game, {double scale = 1.0}) {
    final myHand = game.myHand;
    if (myHand.isEmpty) return const SizedBox.shrink();

    final legalCards = game.legalCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = 58.0 * scale;
        final cardHeight = 82.0 * scale;
        // Keep a fixed hand width so cards don't jump around as the hand
        // shrinks. Cards distribute evenly within this width.
        final handWidth = min(560.0 * scale, constraints.maxWidth);
        final overlap = myHand.length > 1
            ? (handWidth - cardWidth) / (myHand.length - 1)
            : 0.0;

        // Extend the tappable area slightly below the visible card so taps
        // near the bottom edge still register.
        final hitExtension = 16.0 * scale;

        return SizedBox(
          width: handWidth,
          height: cardHeight + hitExtension,
          child: Stack(
            clipBehavior: Clip.none,
            children: myHand.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final isPlayable = legalCards.contains(card);
              final key = _cardKeys.putIfAbsent(card, () => GlobalKey());
              final left = index * overlap;
              return PositionedDirectional(
                start: left,
                top: 0,
                child: GestureDetector(
                  key: key,
                  behavior: HitTestBehavior.opaque,
                  onTap: isPlayable ? () => _playCard(card, game) : null,
                  onPanStart:
                      isPlayable
                          ? (details) => _startCardDrag(card, details)
                          : null,
                  onPanUpdate: isPlayable ? _updateCardDrag : null,
                  onPanEnd:
                      isPlayable
                          ? (details) => _endCardDrag(card, game, details)
                          : null,
                  child: SizedBox(
                    width: cardWidth + overlap,
                    height: cardHeight + hitExtension,
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: PlayingCardWidget(
                          card: PlayingCard.fromString(card),
                          style: PlayingCardStyle.gameTable.copyWith(
                            width: cardWidth,
                            height: cardHeight,
                            centerSuitSize: 26 * scale,
                            rankTextStyle: TextStyle(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                            suitTextStyle: TextStyle(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                            borderColor: isPlayable
                                ? ColorManager.primary
                                : const Color(0xFF9E9E9E),
                            borderWidth: isPlayable ? 2.0 * scale : 0.5,
                            shadow: isPlayable
                                ? BoxShadow(
                                    color: ColorManager.primary.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  )
                                : const BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Offset _playedCardOffset(int seatIndex, int mySeatIndex, Size tableSize) {
    final relativeSeat = (seatIndex - mySeatIndex + 4) % 4;
    // Place cards near each seat so they do not overlap the score chip.
    final dx = tableSize.width * 0.22;
    final dy = tableSize.height * 0.22;
    switch (relativeSeat) {
      case 0: // bottom seat -> card below center
        return Offset(0, dy);
      case 1: // left seat -> card left of center
        return Offset(-dx, 0);
      case 2: // top seat -> card above center
        return Offset(0, -dy);
      case 3: // right seat -> card right of center
        return Offset(dx, 0);
    }
    return Offset.zero;
  }

  void _showLeaveDialog(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final router = GoRouter.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'leave_game'.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          'forfeit_warning'.tr(),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              cubit.leaveGame().then((_) {
                if (!mounted) return;
                router.goNamed(RouteNames.home);
              });
            },
            child: Text(
              'leave'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamePlayerSeat extends StatefulWidget {
  const _GamePlayerSeat({
    required this.player,
    required this.isMe,
    required this.isActive,
    this.scale = 1.0,
  });

  final GamePlayer player;
  final bool isMe;
  final bool isActive;
  final double scale;

  @override
  State<_GamePlayerSeat> createState() => _GamePlayerSeatState();
}

class _GamePlayerSeatState extends State<_GamePlayerSeat> {
  late final AgoraService _agoraService;
  StreamSubscription<AgoraAudioVolumeIndicationEvent>? _volumeSubscription;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _agoraService = context.read<AgoraService>();
    _subscribeToVideo();
    _listenToVolume();
  }

  @override
  void didUpdateWidget(covariant _GamePlayerSeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCameraOn = oldWidget.player.hasCamera;
    final newCameraOn = widget.player.hasCamera;
    if (!oldCameraOn && newCameraOn) {
      _subscribeToVideo();
    } else if (oldCameraOn && !newCameraOn) {
      _unsubscribeFromVideo();
    }
  }

  @override
  void dispose() {
    _volumeSubscription?.cancel();
    _unsubscribeFromVideo();
    super.dispose();
  }

  void _subscribeToVideo() {
    if (!widget.player.hasCamera) return;
    if (!widget.isMe) {
      _agoraService.subscribeToRemoteVideo();
    }
  }

  void _unsubscribeFromVideo() {
    if (!widget.isMe) {
      _agoraService.unsubscribeFromRemoteVideo();
    }
  }

  void _listenToVolume() {
    final agoraUid = widget.player.agoraUid;
    if (agoraUid == null) return;

    _volumeSubscription = _agoraService.onAudioVolumeIndication.listen((event) {
      final isSpeaking = event.speakers.any(
        (s) => s.uid == agoraUid && s.volume != null && s.volume! > 50,
      );
      if (isSpeaking != _isSpeaking && mounted) {
        setState(() {
          _isSpeaking = isSpeaking;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final teamColor = player.team == 'A'
        ? ColorManager.primary
        : ColorManager.secondary;
    final isSpeaking = _isSpeaking;

    final scale = widget.scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Turn countdown for the active seat (human and bots).
        ValueListenableBuilder<int?>(
          valueListenable: context.read<GameCubit>().humanTurnSecondsLeft,
          builder: (context, seconds, child) {
            if (seconds == null || !widget.isActive) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: EdgeInsets.only(bottom: 2 * scale),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 6 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                color: ColorManager.error.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Text(
                '${seconds}s',
                style: TextStyle(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        Container(
          width: (widget.isMe ? 48 : 40) * scale,
          height: (widget.isMe ? 48 : 40) * scale,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSpeaking
                  ? ColorManager.success
                  : (widget.isActive ? teamColor : Colors.transparent),
              width: isSpeaking ? 3 : 2,
            ),
            boxShadow: isSpeaking
                ? [
                    BoxShadow(
                      color: ColorManager.success.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : (widget.isActive
                      ? [
                          BoxShadow(
                            color: teamColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null),
          ),
          clipBehavior: Clip.antiAlias,
          child: player.hasCamera
              ? _buildVideoView(player)
              : CachedAvatar(
                  imageUrl: _playerAvatarUrl(player),
                  size: (widget.isMe ? 44 : 36) * scale,
                  borderRadius: (widget.isMe ? 22 : 18) * scale,
                ),
        ),
        SizedBox(height: 4 * scale),
        SizedBox(
          width: (widget.isMe ? 56 : 48) * scale,
          child: Text(
            widget.isMe ? LocaleKeys.you.tr() : player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: widget.isActive ? teamColor : ColorManager.darkTextPrimary,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              player.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 12 * scale,
              color: player.isMuted
                  ? ColorManager.error.withValues(alpha: 0.8)
                  : ColorManager.success.withValues(alpha: 0.8),
            ),
            SizedBox(width: 2 * scale),
            Icon(
              player.hasCamera
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              size: 12 * scale,
              color: player.hasCamera
                  ? ColorManager.success.withValues(alpha: 0.8)
                  : ColorManager.darkTextMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ],
    );
  }

  String _playerAvatarUrl(GamePlayer player) {
    if (player.avatarUrl.isNotEmpty) return player.avatarUrl;
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=${player.uid}';
  }

  Widget _buildVideoView(GamePlayer player) {
    final scale = widget.scale;
    if (widget.isMe) {
      return _agoraService.getLocalVideoView();
    }
    if (player.agoraUid == null) {
      return CachedAvatar(
        imageUrl: _playerAvatarUrl(player),
        size: (widget.isMe ? 44 : 36) * scale,
        borderRadius: (widget.isMe ? 22 : 18) * scale,
      );
    }
    return _agoraService.getRemoteVideoView(player.agoraUid!);
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon(this.icon, this.color, {this.onPressed});

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onPressed,
    );
  }
}

class _BottomControlButton extends StatelessWidget {
  const _BottomControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
