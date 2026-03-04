import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The Bird (using a stylized dove/crow icon)
              Positioned(
                top: 0,
                child: Icon(
                  FontAwesomeIcons.dove,
                  size: size * 0.7,
                  color: AppTheme.primaryCyan,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),
              ),
              // The Padlock "carried" by the bird
              Positioned(
                bottom: size * 0.1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withAlpha(100),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesomeIcons.lock,
                    size: size * 0.3,
                    color: AppTheme.primaryCyan,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut)
                 .shimmer(delay: 3.seconds, duration: 1.5.seconds),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              children: [
                const TextSpan(
                  text: 'TheBid ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'CipherTask',
                  style: TextStyle(color: AppTheme.primaryCyan, shadows: [
                    Shadow(color: AppTheme.primaryCyan.withAlpha(100), blurRadius: 10),
                  ]),
                ),
              ],
            ),
          ).animate()
           .fadeIn(duration: 800.ms)
           .shimmer(delay: 2.seconds, duration: 2.seconds, color: Colors.white24),
        ],
      ],
    );
  }
}
