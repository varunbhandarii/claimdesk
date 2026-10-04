import 'package:flutter/material.dart';
import 'desk_theme.dart';

enum MarkTone { colour, mono, white }

/// The ClaimDesk mark: an orange luggage tag whose point fits the notch of a
/// blue claim ticket. Drawn on a 64 x 40 grid; [simplified] drops the eyelet
/// and tightens the corners for sizes of 16 px and below.
class ClaimDeskMark extends StatelessWidget {
  const ClaimDeskMark({
    super.key,
    this.width = 34,
    this.tone = MarkTone.colour,
    this.simplified = false,
    this.semanticLabel,
  });
  final double width;
  final MarkTone tone;
  final bool simplified;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (tag, ticket) = switch (tone) {
      MarkTone.colour => (c.tag, c.ticket),
      MarkTone.mono => (c.ink, c.ink),
      MarkTone.white => (const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)),
    };
    final mark = CustomPaint(
      size: Size(width, width * 40 / 64),
      painter: MarkPainter(tag: tag, ticket: ticket, simplified: simplified),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: mark)
        : Semantics(label: semanticLabel, image: true, child: mark);
  }
}

class MarkPainter extends CustomPainter {
  const MarkPainter({
    required this.tag,
    required this.ticket,
    this.simplified = false,
  });
  final Color tag, ticket;
  final bool simplified;

  static Path tagPath({bool simplified = false}) {
    final r = simplified ? 4.0 : 6.0;
    final path = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(26, 0)
      ..lineTo(36, 20)
      ..lineTo(26, 40)
      ..lineTo(r, 40)
      ..arcToPoint(Offset(0, 40 - r), radius: Radius.circular(r))
      ..close();
    if (!simplified) {
      path
        ..addOval(Rect.fromCircle(center: const Offset(10, 20), radius: 3.6))
        ..fillType = PathFillType.evenOdd;
    }
    return path;
  }

  static Path ticketPath({bool simplified = false}) {
    final r = simplified ? 4.0 : 6.0;
    final left = simplified ? 32.0 : 30.5;
    return Path()
      ..moveTo(left, 0)
      ..lineTo(64 - r, 0)
      ..arcToPoint(Offset(64, r), radius: Radius.circular(r))
      ..lineTo(64, 40 - r)
      ..arcToPoint(Offset(64 - r, 40), radius: Radius.circular(r))
      ..lineTo(left, 40)
      ..lineTo(left + 10, 20)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 40);
    canvas.drawPath(
      tagPath(simplified: simplified),
      Paint()
        ..color = tag
        ..isAntiAlias = true,
    );
    canvas.drawPath(
      ticketPath(simplified: simplified),
      Paint()
        ..color = ticket
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(MarkPainter oldDelegate) =>
      oldDelegate.tag != tag ||
      oldDelegate.ticket != ticket ||
      oldDelegate.simplified != simplified;
}

/// Mark and wordmark side by side. The word is about 1.15 times the mark's
/// height and sits a quarter of its size away from the mark.
class DeskWordmark extends StatelessWidget {
  const DeskWordmark({super.key, this.size = 21, this.colour});
  final double size;
  final Color? colour;
  @override
  Widget build(BuildContext context) {
    final markHeight = size / 1.15;
    return Semantics(
      label: 'ClaimDesk',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClaimDeskMark(width: markHeight * 64 / 40),
          SizedBox(width: size / 4),
          Text(
            'ClaimDesk',
            style: context.type.display.copyWith(
              fontSize: size,
              height: 1,
              letterSpacing: -.03 * size,
              color: colour ?? context.desk.ink,
            ),
          ),
        ],
      ),
    );
  }
}
