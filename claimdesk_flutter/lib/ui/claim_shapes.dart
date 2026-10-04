import 'package:flutter/material.dart';
import 'desk_theme.dart';

/// Luggage-tag outline: pointed left end, rounded right corners.
class TagShape extends ShapeBorder {
  const TagShape({
    this.point = 9,
    this.radius = 6,
    this.side = BorderSide.none,
  });
  final double point, radius;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = radius.clamp(0.0, rect.height / 2);
    return Path()
      ..moveTo(rect.left + point, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r))
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(
        Offset(rect.right - r, rect.bottom),
        radius: Radius.circular(r),
      )
      ..lineTo(rect.left + point, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(getOuterPath(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      TagShape(point: point * t, radius: radius * t, side: side.scale(t));

  @override
  bool operator ==(Object other) =>
      other is TagShape &&
      other.point == point &&
      other.radius == radius &&
      other.side == side;

  @override
  int get hashCode => Object.hash(point, radius, side);
}

/// Claim-ticket outline: rounded rectangle with a half-circle notch punched
/// into the middle of its left edge.
class TicketShape extends ShapeBorder {
  const TicketShape({this.radius = 6, this.notch = 5});
  final double radius, notch;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path.combine(
    PathOperation.difference,
    Path()..addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    ),
    Path()..addOval(
      Rect.fromCircle(
        center: Offset(rect.left, rect.center.dy),
        radius: notch,
      ),
    ),
  );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      TicketShape(radius: radius * t, notch: notch * t);

  @override
  bool operator ==(Object other) =>
      other is TicketShape && other.radius == radius && other.notch == notch;

  @override
  int get hashCode => Object.hash(radius, notch);
}

/// Orange tag carrying a found item's reference code.
class RefTag extends StatelessWidget {
  const RefTag(this.code, {super.key, this.large = false});
  final String code;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final size = large ? 17.0 : 12.5;
    final eyelet = large ? 9.0 : 6.0;
    return Semantics(
      label: 'Item $code',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: c.tag,
          shape: TagShape(point: large ? 13 : 9, radius: large ? 8 : 6),
        ),
        child: SizedBox(
          height: large ? 38 : 26,
          child: Padding(
            padding: EdgeInsets.only(
              left: large ? 19 : 13,
              right: large ? 15 : 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: eyelet,
                  height: eyelet,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x5916181B),
                      width: large ? 2 : 1.5,
                    ),
                  ),
                ),
                SizedBox(width: large ? 10 : 7),
                Text(
                  code,
                  maxLines: 1,
                  softWrap: false,
                  style: context.type.codeAt(size).copyWith(color: c.tagOn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Blue ticket carrying a lost report's reference code.
class RefTicket extends StatelessWidget {
  const RefTicket(this.code, {super.key, this.large = false});
  final String code;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final size = large ? 17.0 : 12.5;
    return Semantics(
      label: 'Report $code',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: c.ticket,
          shape: TicketShape(radius: large ? 8 : 6, notch: large ? 7 : 5),
        ),
        child: SizedBox(
          height: large ? 38 : 26,
          child: Padding(
            padding: EdgeInsets.only(
              left: large ? 17 : 12,
              right: large ? 15 : 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DashedLine(
                  axis: Axis.vertical,
                  length: large ? 20 : 14,
                  thickness: 1.5,
                  dash: 3,
                  gap: 2.5,
                  color: c.ticketOn.withValues(alpha: .6),
                ),
                SizedBox(width: large ? 11 : 8),
                Text(
                  code,
                  maxLines: 1,
                  softWrap: false,
                  style: context.type.codeAt(size).copyWith(color: c.ticketOn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A found item and a lost report joined into one claim.
class ClaimPair extends StatelessWidget {
  const ClaimPair({
    super.key,
    required this.item,
    required this.report,
    this.large = false,
  });
  final String item, report;
  final bool large;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      RefTag(item, large: large),
      const SizedBox(width: 6),
      Icon(Icons.link, size: 16, color: context.desk.ink3),
      const SizedBox(width: 6),
      RefTicket(report, large: large),
    ],
  );
}

class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    required this.axis,
    required this.length,
    required this.color,
    this.thickness = 2,
    this.dash = 6,
    this.gap = 5,
  });
  final Axis axis;
  final double length, thickness, dash, gap;
  final Color color;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: axis == Axis.vertical
        ? Size(thickness, length)
        : Size(length, thickness),
    painter: _DashPainter(axis, color, thickness, dash, gap),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.axis, this.color, this.thickness, this.dash, this.gap);
  final Axis axis;
  final Color color;
  final double thickness, dash, gap;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    final total = axis == Axis.vertical ? size.height : size.width;
    for (var at = 0.0; at < total; at += dash + gap) {
      final end = (at + dash).clamp(0.0, total);
      if (axis == Axis.vertical) {
        canvas.drawLine(
          Offset(size.width / 2, at),
          Offset(size.width / 2, end),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(at, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.axis != axis || old.thickness != thickness;
}

/// Perforation between the two halves of a claim: a dashed line with a notch
/// bitten out of each edge. Place it directly inside a clipped card whose
/// border is painted beneath its children, such as DeskCard.
class Seam extends StatelessWidget {
  const Seam({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return SizedBox(
      height: 22,
      child: CustomPaint(
        painter: _SeamPainter(c.line, c.paper, Axis.horizontal),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

/// Vertical perforation for side-by-side halves. Needs a bounded height.
class VSeam extends StatelessWidget {
  const VSeam({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return SizedBox(
      width: 24,
      child: CustomPaint(painter: _SeamPainter(c.line, c.paper, Axis.vertical)),
    );
  }
}

class _SeamPainter extends CustomPainter {
  _SeamPainter(this.line, this.paper, this.axis);
  final Color line, paper;
  final Axis axis;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final dash = Paint()
      ..color = line
      ..strokeWidth = 2;
    final fill = Paint()..color = paper;
    final ring = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (axis == Axis.horizontal) {
      final y = size.height / 2;
      for (var x = 18.0; x < size.width - 18; x += 11) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + 6).clamp(0.0, size.width - 18), y),
          dash,
        );
      }
      for (final centre in [Offset(-1, y), Offset(size.width + 1, y)]) {
        canvas.drawCircle(centre, 11, fill);
        canvas.drawCircle(centre, 10.5, ring);
      }
    } else {
      final x = size.width / 2;
      for (var y = 18.0; y < size.height - 18; y += 11) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, (y + 6).clamp(0.0, size.height - 18)),
          dash,
        );
      }
      for (final centre in [Offset(x, -1), Offset(x, size.height + 1)]) {
        canvas.drawCircle(centre, 11, fill);
        canvas.drawCircle(centre, 10.5, ring);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeamPainter old) =>
      old.line != line || old.paper != paper || old.axis != axis;
}
