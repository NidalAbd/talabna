import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';

class LogoTitle extends StatefulWidget {
  const LogoTitle({Key? key, required this.fontSize, required this.playAnimation, required this.logoSize}) : super(key: key);
 final double fontSize;
 final bool playAnimation;
 final double logoSize;
  @override
  State<LogoTitle> createState() => _LogoTitleState();
}

class _LogoTitleState extends State<LogoTitle> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose(); // Add this line to dispose of the Ticker object
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return widget.playAnimation?  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity:  _animation,
          child: Text(
            'T',
            style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                ],
                decoration: TextDecoration.none,
                fontFamily: GoogleFonts.acme().fontFamily,
                color: AppTheme.primaryColor
            ),
          ),
        ),
        FadeTransition(
          opacity: _animation,
          child: Text(
            'ALB',
            style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                ],
                decoration: TextDecoration.none,
                fontFamily: GoogleFonts.acme().fontFamily,
                color: AppTheme.primaryColor
            ),
          ),
        ),
        FadeTransition(
          opacity: _animation,
          child: Text(
            'NA',
            style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                ],
                decoration: TextDecoration.none,
                fontFamily: GoogleFonts.acme().fontFamily,
                color: Colors.white
            ),
          ),
        ),
      ],
    ) : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset('assets/talabnaLogo.png',width: widget.logoSize, height: widget.logoSize,),
      ],
    );
  }
}
