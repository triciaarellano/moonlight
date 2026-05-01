import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFFB5A957),
              const Color(0xFF2B125A),
              const Color(0xFF9D7171),
            ],
            stops: const [0.1, 0.47, 0.85],
          ),
        ),
        child: Stack(
          children: [
            // Top status bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time
                      Text(
                        '15:45',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      // Signal indicators
                      Row(
                        children: [
                          // Wifi icon
                          CustomPaint(
                            size: const Size(21, 10.3),
                            painter: WifiIconPainter(),
                          ),
                          const SizedBox(width: 6),
                          // Battery icon
                          CustomPaint(
                            size: const Size(18, 7.3),
                            painter: BatteryIconPainter(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main logo/content
            Center(
              child: Container(
                width: 196,
                height: 41,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'MOONLIGHT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom home indicator
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WifiIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.5, size.height * 0.6);

    // Wifi arcs
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 8, height: 8),
      -2.3,
      2.3,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCenter(center: center, width: 14, height: 14),
      -2.3,
      2.3,
      false,
      paint,
    );

    // Wifi dot
    canvas.drawCircle(center, 1.5, fillPaint);
  }

  @override
  bool shouldRepaint(WifiIconPainter oldDelegate) => false;
}

class BatteryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Battery body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 1.5, size.width * 0.88, size.height * 0.65),
        const Radius.circular(1.3),
      ),
      strokePaint,
    );

    // Battery nub
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.92, size.height * 0.25, size.width * 0.08,
          size.height * 0.5),
      strokePaint,
    );

    // Battery fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 2.5, size.width * 0.75, size.height * 0.5),
        const Radius.circular(1),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(BatteryIconPainter oldDelegate) => false;
}
