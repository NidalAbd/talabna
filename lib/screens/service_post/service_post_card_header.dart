import 'dart:math';

import 'package:flutter/material.dart';

class ServicePostHeaderContainer extends StatefulWidget {
  final String haveBadge;
  final Widget child;

  ServicePostHeaderContainer({required this.haveBadge, required this.child});

  @override
  _ServicePostHeaderContainerState createState() =>
      _ServicePostHeaderContainerState();
}

class _ServicePostHeaderContainerState extends State<ServicePostHeaderContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationValue = _animationController.value;
    final glowingGradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.transparent,
        widget.haveBadge == 'ذهبي'
            ? Colors.yellow.withOpacity(0.9)
            : Colors.blueAccent.withOpacity(0.9),
        Colors.transparent,
        Colors.transparent,
      ],
      stops: [
        animationValue - 0.5,
        animationValue - 0.3,
        animationValue,
        animationValue + 0.3,
        animationValue + 0.5,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );



    return Stack(
      children: [
        Material(
          elevation: 4.0,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: widget.haveBadge == 'ذهبي' || widget.haveBadge == 'ماسي'
              ? ShaderMask(
            shaderCallback: (bounds) =>
                glowingGradient.createShader(bounds),
            blendMode: BlendMode.srcATop,
            child: buildContainer(),
          )
              : buildContainer(),
        ),
        widget.child,
      ],
    );
  }

  Center buildContainer() {
    return Center(
      child: Container(
        height: 25,
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
        decoration: BoxDecoration(
          color: widget.haveBadge == 'ذهبي'
              ? const Color.fromRGBO(242, 195, 27, 0.862)
              : widget.haveBadge == 'ماسي'
              ? const Color.fromRGBO(66, 165, 245, 0.862)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
