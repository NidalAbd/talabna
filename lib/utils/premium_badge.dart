import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final String badgeType;
  final double size;

  const PremiumBadge({
    super.key,
    required this.badgeType,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty container if it's a regular post
    if (badgeType == 'عادي') {
      return const SizedBox.shrink();
    }

    final isPremiumGold = badgeType == 'ذهبي';
    final isPremiumDiamond = badgeType == 'ماسي';

    // Modern color palette
    final Color primaryColor = isPremiumGold
        ? const Color(0xFFFFD700) // Gold
        : const Color(0xFF00CCFF); // Diamond blue

    final Color glowColor = isPremiumGold
        ? const Color(0xFFFFF0B3) // Light gold glow
        : const Color(0xFFB3F0FF); // Light blue glow

    return Container(
      height: size,
      width: size,
      child: Stack(
        children: [
          // Glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.6),
                  blurRadius: size / 3,
                  spreadRadius: size / 10,
                ),
              ],
            ),
          ),

          // Icon
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                isPremiumGold
                    ? Icons.stars_rounded
                    : Icons.diamond_rounded,
                color: primaryColor,
                size: size,
              ),
            ),
          ),

          // Shine effect
          ClipOval(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcATop,
              child: Container(
                color: Colors.transparent,
                height: size,
                width: size,
              ),
            ),
          ),
        ],
      ),
    );
  }
}