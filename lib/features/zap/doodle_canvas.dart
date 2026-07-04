import 'package:flutter/material.dart';

/// One finger stroke, points normalized to 0..1 of the canvas size so
/// doodles render identically on any screen.
class DoodleStroke {
  final Color color;
  final double width;
  final List<Offset> points;

  DoodleStroke({required this.color, required this.width, required this.points});

  Map<String, dynamic> toJson() => {
        'color': color.toARGB32(),
        'width': width,
        'points': [
          for (final p in points) [double.parse(p.dx.toStringAsFixed(4)), double.parse(p.dy.toStringAsFixed(4))]
        ],
      };

  factory DoodleStroke.fromJson(Map<String, dynamic> j) => DoodleStroke(
        color: Color(j['color'] as int),
        width: (j['width'] as num).toDouble(),
        points: [
          for (final p in (j['points'] as List))
            Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())
        ],
      );

  static List<DoodleStroke> listFromRaw(List<dynamic>? raw) => [
        for (final s in raw ?? [])
          DoodleStroke.fromJson((s as Map).cast<String, dynamic>())
      ];
}

class DoodlePainter extends CustomPainter {
  final List<DoodleStroke> strokes;
  final DoodleStroke? active;

  DoodlePainter({required this.strokes, this.active});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in [...strokes, if (active != null) active!]) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      if (s.points.length < 2) {
        if (s.points.isNotEmpty) {
          canvas.drawCircle(
              Offset(s.points.first.dx * size.width,
                  s.points.first.dy * size.height),
              s.width / 2,
              paint..style = PaintingStyle.fill);
        }
        continue;
      }
      final path = Path()
        ..moveTo(s.points.first.dx * size.width, s.points.first.dy * size.height);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter old) =>
      old.strokes != strokes || old.active != active;
}

/// Interactive finger-drawing layer.
class DoodleCanvas extends StatefulWidget {
  final List<DoodleStroke> strokes;
  final Color color;
  final ValueChanged<List<DoodleStroke>> onChanged;

  const DoodleCanvas({
    super.key,
    required this.strokes,
    required this.color,
    required this.onChanged,
  });

  @override
  State<DoodleCanvas> createState() => _DoodleCanvasState();
}

class _DoodleCanvasState extends State<DoodleCanvas> {
  DoodleStroke? _active;

  Offset _norm(Offset local, Size size) => Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onPanStart: (d) => setState(() => _active = DoodleStroke(
            color: widget.color,
            width: 4,
            points: [_norm(d.localPosition, size)])),
        onPanUpdate: (d) => setState(
            () => _active?.points.add(_norm(d.localPosition, size))),
        onPanEnd: (_) {
          if (_active != null) {
            widget.onChanged([...widget.strokes, _active!]);
          }
          setState(() => _active = null);
        },
        child: CustomPaint(
          painter: DoodlePainter(strokes: widget.strokes, active: _active),
          size: Size.infinite,
        ),
      );
    });
  }
}
