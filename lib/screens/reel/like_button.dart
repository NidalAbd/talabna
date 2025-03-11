import 'dart:math';

import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final bool isFavorite;
  final int favoritesCount;
  final Future<bool> Function() onToggleFavorite;
  final double iconSize;
  final Color likedColor;
  final Color unlikedColor;
  final bool showBurstEffect;
  final bool showCountOnRight; // New parameter to control count position
  final bool showCount; // New parameter to control if count is shown

  const LikeButton({
    super.key,
    required this.isFavorite,
    required this.favoritesCount,
    required this.onToggleFavorite,
    this.iconSize = 40,
    this.likedColor = Colors.red,
    this.unlikedColor = Colors.white,
    this.showBurstEffect = true,
    this.showCountOnRight = false, // By default show count below (like Facebook mobile)
    this.showCount = true, // By default show the count
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _burstAnimation;
  late bool _isFavorite;
  late int _favoritesCount;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _favoritesCount = widget.favoritesCount;

    // Create animation controller with better curve for mobile
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Scale animation - smoother bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_animationController);

    // Burst animation - separate timing for particles
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    // If initially favorited, set animation to end state
    if (_isFavorite) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external state changes
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });

      // Only animate if the widget caused the change
      if (!_isProcessing) {
        if (_isFavorite) {
          _animationController.forward(from: 0.0);
        } else {
          _animationController.reverse(from: 1.0);
        }
      }
    }

    if (oldWidget.favoritesCount != widget.favoritesCount) {
      setState(() {
        _favoritesCount = widget.favoritesCount;
      });
    }
  }

  Future<void> _handleLikeToggle() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Optimistically update UI immediately for better responsiveness
      final wasLiked = _isFavorite;
      setState(() {
        _isFavorite = !_isFavorite;
        _favoritesCount += _isFavorite ? 1 : -1;
      });

      // Animate based on new state
      if (_isFavorite) {
        _animationController.forward(from: 0.0);
      } else {
        _animationController.reverse(from: 1.0);
      }

      // Call the toggle favorite function provided by the parent
      final success = await widget.onToggleFavorite();

      // If failed, revert the state
      if (!success) {
        setState(() {
          _isFavorite = wasLiked;
          _favoritesCount += _isFavorite ? 1 : -1;
        });
      }
    } catch (e) {
      // Handle errors and revert state
      debugPrint('Like toggle failed: $e');
      setState(() {
        _isFavorite = !_isFavorite;
        _favoritesCount += _isFavorite ? 1 : -1;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  // Heart icon builder with animation
  Widget _buildHeartIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.iconSize * 1.2,
          height: widget.iconSize * 1.2,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Particle/burst effect
              if (widget.showBurstEffect && _isFavorite)
                CustomPaint(
                  size: Size(widget.iconSize * 1.5, widget.iconSize * 1.5),
                  painter: HeartBurstPainter(
                    progress: _burstAnimation.value,
                    color: widget.likedColor,
                  ),
                ),

              // Scaled heart icon with smoother transitions
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: widget.iconSize,
                  color: _isFavorite ? widget.likedColor : widget.unlikedColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Count text with animation
  Widget _buildCountText() {
    if (!widget.showCount) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _formatCount(_favoritesCount),
        key: ValueKey<int>(_favoritesCount),
        style: TextStyle(
          color: _isFavorite ? widget.likedColor : widget.unlikedColor,
          fontSize: widget.iconSize * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Horizontal layout (count on right)
    if (widget.showCountOnRight) {
      return GestureDetector(
        onTap: _handleLikeToggle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeartIcon(),
            const SizedBox(width: 4),
            _buildCountText(),
          ],
        ),
      );
    }

    // Vertical layout (count below)
    return GestureDetector(
      onTap: _handleLikeToggle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeartIcon(),
          const SizedBox(height: 4),
          _buildCountText(),
        ],
      ),
    );
  }
}

class HeartBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int particleCount;
  final Random _random = Random();

  HeartBurstPainter({
    required this.progress,
    required this.color,
    this.particleCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.5;

    // Create more organic burst effect with varied particles
    for (int i = 0; i < particleCount; i++) {
      // Randomize particle angle
      final angle = (i * (360 / particleCount) + _random.nextDouble() * 30) * (pi / 180);

      // Randomize distance from center based on progress
      final distance = maxRadius * progress * (0.7 + _random.nextDouble() * 0.3);

      // Calculate position
      final particleX = center.dx + distance * cos(angle);
      final particleY = center.dy + distance * sin(angle);

      // Randomize opacity and size for more organic look
      final opacity = (1.0 - progress) * (0.6 + _random.nextDouble() * 0.4);
      final particleSize = (4.0 * (1.0 - progress)) * (0.5 + _random.nextDouble() * 0.5);

      // Create particle
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Randomly draw circles or heart-like shapes
      if (_random.nextBool()) {
        canvas.drawCircle(
            Offset(particleX, particleY),
            particleSize,
            paint
        );
      } else {
        // Draw small rectangle for variety
        canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(particleX, particleY),
                width: particleSize * 2,
                height: particleSize,
              ),
              Radius.circular(particleSize / 2),
            ),
            paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartBurstPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}