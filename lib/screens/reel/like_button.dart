import 'dart:math';

import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final bool isFavorite;
  final int favoritesCount;
  final Function(bool) onPressed;
  final Function(int) onFavoritesCountChanged; // Callback for count change

  const LikeButton({
    Key? key,
    required this.isFavorite,
    required this.favoritesCount,
    required this.onPressed,
    required this.onFavoritesCountChanged,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late bool _isFavorite;
  late int _favoritesCount;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _favoritesCount = widget.favoritesCount;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);

    _colorAnimation = ColorTween(begin: Colors.grey, end: Colors.red)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() async {
    // Toggle favorite state
    if (!_isFavorite) {
      await _controller.forward(); // Play animation forward for like
    } else {
      await _controller.reverse(); // Play animation backward for unlike
    }
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the state
      if (_isFavorite) {
        _favoritesCount++; // Increment favorites count when liked
      } else {
        _favoritesCount--; // Decrement favorites count when unliked
      }
    });
    widget.onPressed(_isFavorite); // Notify parent about the new state
    widget.onFavoritesCountChanged(_favoritesCount); // Notify parent about the updated count
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handlePressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Particle effect for "like" state
              if (_isFavorite)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParticleEffectPainter(_controller.value),
                  ),
                ),
              // Heart icon with scaling and color animation
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 40,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ParticleEffectPainter extends CustomPainter {
  final double progress;

  ParticleEffectPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.red.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;

    final int particleCount = 10;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * (360 / particleCount)) * pi / 180;
      final radius = size.width * 0.5 * progress;
      final dx = size.width / 2 + radius * cos(angle);
      final dy = size.height / 2 + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 4.0, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
