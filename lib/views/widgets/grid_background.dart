import 'package:flutter/material.dart';
import 'dart:math' as math;

class GridBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;

  const GridBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  State<GridBackground> createState() => _GridBackgroundState();
}

class _GridBackgroundState extends State<GridBackground> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Offset _touchPosition = const Offset(-1000, -1000);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use AnimatedSwitcher or just a container that reacts to theme changes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Ensure the background extends behind everything
      resizeToAvoidBottomInset: false,
      body: MouseRegion(
        onHover: (event) => setState(() => _touchPosition = event.localPosition),
        onExit: (_) => setState(() => _touchPosition = const Offset(-1000, -1000)),
        child: GestureDetector(
          onPanUpdate: (details) => setState(() => _touchPosition = details.localPosition),
          onPanEnd: (_) => setState(() => _touchPosition = const Offset(-1000, -1000)),
          child: Stack(
            children: [
              // Persistent Base Gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [const Color(0xFF0B1120), const Color(0xFF162135)] 
                      : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)], 
                  ),
                ),
              ),
              
              // Persistent Grid
              if (widget.showGrid)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ModernGridPainter(
                          isDark: isDark,
                          pulseValue: _pulseController.value,
                          touchPosition: _touchPosition,
                        ),
                      );
                    },
                  ),
                ),
                
              // Screen Content
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernGridPainter extends CustomPainter {
  final bool isDark;
  final double pulseValue;
  final Offset touchPosition;
  final double spacing = 35.0; 

  _ModernGridPainter({
    required this.isDark,
    required this.pulseValue,
    required this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? Colors.cyanAccent : Colors.blueAccent;
    final gridOpacity = 0.05 + (pulseValue * 0.03);
    
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(gridOpacity) : Colors.black.withOpacity(gridOpacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    _drawGrid(canvas, size, paint);

    if (touchPosition.dx >= 0 && touchPosition.dy >= 0) {
      final glowPaint = Paint()
        ..color = baseColor.withOpacity(isDark ? 0.2 : 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12); 

      _drawHighlightedGrid(canvas, size, glowPaint, touchPosition, 120.0);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final crossPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 1.5) 
      ..strokeWidth = 1.0;
      
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawLine(Offset(x - 2, y), Offset(x + 2, y), crossPaint);
        canvas.drawLine(Offset(x, y - 2), Offset(x, y + 2), crossPaint);
      }
    }
  }

  void _drawHighlightedGrid(Canvas canvas, Size size, Paint paint, Offset center, double radius) {
    for (double i = 0; i <= size.width; i += spacing) {
      if ((i - center.dx).abs() < radius) {
        double dySq = (radius * radius) - ((i - center.dx) * (i - center.dx));
        if (dySq > 0) {
          double dy = math.sqrt(dySq);
          canvas.drawLine(Offset(i, center.dy - dy), Offset(i, center.dy + dy), paint);
        }
      }
    }
    for (double i = 0; i <= size.height; i += spacing) {
      if ((i - center.dy).abs() < radius) {
         double dxSq = (radius * radius) - ((i - center.dy) * (i - center.dy));
         if (dxSq > 0) {
           double dx = math.sqrt(dxSq);
           canvas.drawLine(Offset(center.dx - dx, i), Offset(center.dx + dx, i), paint);
         }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModernGridPainter oldDelegate) => true;
}
