import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';

class LogoTitle extends StatefulWidget {
  const LogoTitle({
    super.key,
    required this.fontSize,
    required this.playAnimation,
    required this.logoSize,
  });

  final double fontSize;
  final bool playAnimation;
  final double logoSize;

  @override
  State<LogoTitle> createState() => _LogoTitleState();
}

class _LogoTitleState extends State<LogoTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double logoTopMargin = 100.0; // Default value

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 100, end: 20).animate(_animationController)
      ..addListener(() {
        setState(() {
          logoTopMargin = _animation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom != 0 && !_animationController.isAnimating) {
      // If keyboard is open and animation is not playing, animate the logo position
      _animationController.forward();
    } else if (MediaQuery.of(context).viewInsets.bottom == 0 && !_animationController.isAnimating) {
      // If keyboard is closed and animation is not playing, animate the logo position back to initial
      _animationController.reverse();
    }

    return Stack(
      children: [
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkPrimaryColor.withOpacity(0.99)
                : AppTheme.lightPrimaryColor.withOpacity(0.99),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - widget.logoSize, // To center the logo horizontally
          top: logoTopMargin, // Adjusted when keyboard is opened/closed
          child: CircleAvatar(
            radius: widget.logoSize,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkPrimaryColor.withOpacity(0.5)
                : AppTheme.lightPrimaryColor.withOpacity(0.5),
            backgroundImage: const AssetImage('assets/talabnaLogo.png'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 4.2);

    var firstControlPoint = Offset(size.width / 4, size.height / 5);
    var firstEndPoint = Offset(size.width / 2, size.height / 4.2);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 4), size.height / 3.5);
    var secondEndPoint = Offset(size.width, size.height / 4.2);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
