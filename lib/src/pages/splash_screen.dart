import 'dart:math';

import 'package:flutter/material.dart';
import 'home_page.dart';

/// A beautiful splash screen with Islamic theme styling.
/// Displays the app icon, title, slogan, and developer name with animations.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();

    // Navigate to home page after splash duration
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainHomePage()));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F3460), Color(0xFF16213E)]),
        ),
        child: Stack(
          children: [
            // Islamic geometric pattern background (subtle)
            Positioned.fill(child: CustomPaint(painter: IslamicPatternPainter())),
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    // Animated icon with Islamic star decoration
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow circle
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: const Color(0xFF64FFDA).withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                              ),
                            ),
                            // Islamic decorative circle
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF64FFDA), width: 2),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [const Color(0xFF64FFDA).withOpacity(0.2), const Color(0xFF1DE9B6).withOpacity(0.2)],
                                ),
                              ),
                            ),
                            // Central icon (Quran/Islamic symbol)
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF64FFDA).withOpacity(0.1)),
                              child: Center(child: Image.asset('assets/splash/splash.png', width: 100, height: 100, fit: BoxFit.contain)),
                            ),
                            // Islamic star at top
                            Positioned(
                              top: 0,
                              child: CustomPaint(size: const Size(30, 30), painter: IslamicStarPainter()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    // App title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'القرآن الكريم - مصحف الحفظ',
                            style:
                                Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1) ??
                                const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: 60,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF64FFDA), Color(0xFF1DE9B6)]),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Islamic slogan
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'اللَّهُ نَزَّلَ أَحْسَنَ الْحَدِيثِ كِتَابًا مُّتَشَابِهًا مَّثَانِيَ',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF64FFDA), letterSpacing: 1) ??
                              const TextStyle(color: Color(0xFF64FFDA), fontSize: 20, letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    // Spacer to push developer credit to bottom
                    // Developer credit
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'تطوير',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, letterSpacing: 1) ?? const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Text('جميع الحقوق محفوظة للمطور محمد نور © 2026', style: TextStyle(color: Colors.white54)),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Islamic geometric pattern
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64FFDA).withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle geometric grid
    for (int i = 0; i < (size.width / 60).ceil(); i++) {
      for (int j = 0; j < (size.height / 60).ceil(); j++) {
        final x = i * 60.0;
        final y = j * 60.0;

        // Draw small circles
        canvas.drawCircle(Offset(x, y), 15, paint);

        // Draw connecting lines
        if (i < (size.width / 60).ceil() - 1) {
          canvas.drawLine(Offset(x + 15, y), Offset(x + 45, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) => false;
}

/// Custom painter for Islamic star
class IslamicStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64FFDA)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    const points = 5;
    const innerRadius = 4.0;
    const outerRadius = 10.0;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(IslamicStarPainter oldDelegate) => false;
}
