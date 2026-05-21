import 'package:flutter/material.dart';

import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card_model.dart';
import 'package:bloot/features/game/presentation/widgets/playing_card/playing_card_style.dart';

/// Renders a realistic playing card using pure Flutter widgets.
///
/// No image assets required. Fully themable via [PlayingCardStyle].
class PlayingCardWidget extends StatelessWidget {
  const PlayingCardWidget({
    required this.card,
    this.style,
    this.faceDown = false,
    super.key,
  });

  final PlayingCard card;
  final PlayingCardStyle? style;
  final bool faceDown;

  PlayingCardStyle get _style => style ?? PlayingCardStyle.standard;

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return Container(
      width: s.width,
      height: s.height,
      decoration: BoxDecoration(
        color: faceDown ? s.faceDownColor : s.backgroundColor,
        borderRadius: s.borderRadius,
        border: Border.all(
          color: s.borderColor,
          width: s.borderWidth,
        ),
        boxShadow: [s.shadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: faceDown
          ? _FaceDownContent(style: s)
          : _FaceUpContent(card: card, style: s),
    );
  }
}

class _FaceUpContent extends StatelessWidget {
  const _FaceUpContent({
    required this.card,
    required this.style,
  });

  final PlayingCard card;
  final PlayingCardStyle style;

  @override
  Widget build(BuildContext context) {
    final color = style.foregroundColorFor(card);

    return Stack(
      children: [
        // Center watermark suit
        Center(
          child: Text(
            card.suit.symbol,
            style: TextStyle(
              fontSize: style.centerSuitSize,
              color: color.withValues(alpha: style.centerSuitOpacity),
              height: 1.0,
            ),
          ),
        ),

        // Top-left corner
        Positioned(
          top: style.cornerPadding.top,
          left: style.cornerPadding.left,
          child: _Corner(
            rank: card.rank,
            suit: card.suit,
            style: style,
            color: color,
          ),
        ),

        // Bottom-right corner (rotated 180°)
        Positioned(
          bottom: style.cornerPadding.bottom,
          right: style.cornerPadding.right,
          child: RotatedBox(
            quarterTurns: 2,
            child: _Corner(
              rank: card.rank,
              suit: card.suit,
              style: style,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.rank,
    required this.suit,
    required this.style,
    required this.color,
  });

  final CardRank rank;
  final CardSuit suit;
  final PlayingCardStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank.label,
          style: style.rankTextStyle.copyWith(color: color),
        ),
        Text(
          suit.symbol,
          style: style.suitTextStyle.copyWith(color: color),
        ),
      ],
    );
  }
}

class _FaceDownContent extends StatelessWidget {
  const _FaceDownContent({required this.style});

  final PlayingCardStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: style.width * 0.75,
        height: style.height * 0.82,
        decoration: BoxDecoration(
          color: style.faceDownPatternColor,
          borderRadius: style.borderRadius * 0.7,
          border: Border.all(
            color: style.faceDownColor.withValues(alpha: 0.5),
          ),
        ),
        child: CustomPaint(
          painter: _DiamondPatternPainter(
            color: style.faceDownColor,
          ),
        ),
      ),
    );
  }
}

class _DiamondPatternPainter extends CustomPainter {
  const _DiamondPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const spacing = 8.0;
    const diamondSize = 3.0;

    for (var y = -spacing; y < size.height + spacing; y += spacing) {
      for (var x = -spacing; x < size.width + spacing; x += spacing) {
        final path = Path()
          ..moveTo(x, y - diamondSize)
          ..lineTo(x + diamondSize, y)
          ..lineTo(x, y + diamondSize)
          ..lineTo(x - diamondSize, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
