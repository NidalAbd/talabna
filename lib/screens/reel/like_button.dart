import 'dart:math';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final bool isFavorite;
  final int favoritesCount;
  final Function(bool) onPressed;
  final Function(int) onFavoritesCountChanged;

  const LikeButton({
    super.key,
    required this.isFavorite,
    required this.favoritesCount,
    required this.onPressed,
    required this.onFavoritesCountChanged,
  });

  @override
  LikeButtonState createState() => LikeButtonState();
}

class LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
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
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if widget's props change
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
    if (oldWidget.favoritesCount != widget.favoritesCount) {
      setState(() {
        _favoritesCount = widget.favoritesCount;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() async {
    // Determine the new favorite state
    bool newFavoriteState = !_isFavorite;

    // Determine the new favorites count
    int newFavoritesCount = _favoritesCount;
    if (newFavoriteState != _isFavorite) {
      newFavoritesCount += newFavoriteState ? 1 : -1;
    }

    // Animate the button
    if (newFavoriteState) {
      await _controller.forward(); // Play animation forward for like
    } else {
      await _controller.reverse(); // Play animation backward for unlike
    }

    setState(() {
      _isFavorite = newFavoriteState;
      _favoritesCount = newFavoritesCount;
    });

    // Notify parent about the new state and count
    widget.onPressed(_isFavorite);
    widget.onFavoritesCountChanged(_favoritesCount);
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
              // Heart icon with scaling
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