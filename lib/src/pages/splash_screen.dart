import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'home_page.dart';

/// A beautiful splash screen with Islamic theme styling.
/// Displays the app icon, title, slogan, and developer name with animations.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Navigate to home page after splash duration
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainHomePage()),
        );
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kDarkBackground, kDarkBackgroundVariant],
          ),
        ),
        child: Stack(
          children: [
            // Islamic geometric pattern background (subtle)
            Positioned.fill(
              child: CustomPaint(painter: IslamicPatternPainter()),
            ),
            // Main content
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    width: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.4,
                                    ),
                                    height: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: kLightsColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Islamic decorative circle
                                  Container(
                                    width: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.36,
                                    ),
                                    height: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.36,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: kLightsColor,
                                        width: 2,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          kLightsColor.withValues(alpha: 0.2),
                                          kLightsColor.withValues(alpha: 0.2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Central icon (Quran/Islamic symbol)
                                  Container(
                                    width: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.28,
                                    ),
                                    height: ResponsiveUtils.getResponsiveWidth(
                                      context,
                                      0.28,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFF1ABC9C,
                                      ).withValues(alpha: 0.1),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/splash/splash.png',
                                        width:
                                            ResponsiveUtils.getResponsiveWidth(
                                              context,
                                              0.2,
                                            ),
                                        height:
                                            ResponsiveUtils.getResponsiveWidth(
                                              context,
                                              0.2,
                                            ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  // Islamic star at top
                                  Positioned(
                                    top: 0,
                                    child: CustomPaint(
                                      size: const Size(30, 30),
                                      painter: IslamicStarPainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.10,
                            ),
                          ),
                          // App title
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'القرآن الكريم',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineLarge?.copyWith(
                                        color: kLightBackground,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ) ??
                                      const TextStyle(
                                        color: kLightBackground,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'مصحف ورش للحفظ',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color: const Color.fromARGB(
                                          162,
                                          231,
                                          231,
                                          231,
                                        ),
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 1,
                                      ) ??
                                      const TextStyle(
                                        color: kLightBackground,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: ResponsiveUtils.getResponsiveHeight(
                                    context,
                                    0.035,
                                  ),
                                ),
                                Container(
                                  width: ResponsiveUtils.getResponsiveWidth(
                                    context,
                                    0.12,
                                  ),
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [kLightsColor, kLightsColor],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.035,
                            ),
                          ),
                          // Islamic slogan
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'اللَّهُ نَزَّلَ أَحْسَنَ الْحَدِيثِ كِتَابًا مُّتَشَابِهًا مَّثَانِيَ',
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: kLightsColor,
                                      letterSpacing: 1,
                                    ) ??
                                    const TextStyle(
                                      color: kLightsColor,
                                      fontSize: 20,
                                      letterSpacing: 1,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.12,
                            ),
                          ),
                          // Spacer to push developer credit to bottom
                        ],
                      ),
                    ),
                  ),
                ),
                // Developer credit bottom bar
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    border: Border(
                      top: BorderSide(
                        color: kLightsColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Text(
                        'جميع الحقوق محفوظة للمطور  © 2026',
                        style: const TextStyle(
                          color: kLightBackground,
                          fontSize: 12,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),
              ],
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
      ..color = kLightsColor.withValues(alpha: 0.03)
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
      ..color = kLightsColor
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
