import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/theme_cubit.dart';

class ThemeToggleListTile extends StatefulWidget {
  final  Language language;

  const ThemeToggleListTile({super.key, required this.language});
  @override
  _ThemeToggleListTileState createState() => _ThemeToggleListTileState();
}

class _ThemeToggleListTileState extends State<ThemeToggleListTile> {
  bool isDarkMode = false;

  void _handleThemeChange(BuildContext context, Offset globalPosition) {
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    isDarkMode = themeCubit.state.brightness == Brightness.dark;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);

    _showCircularTransitionAnimation(context, localPosition);

    themeCubit.toggleTheme();
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    isDarkMode = themeCubit.state.brightness == Brightness.dark;

    return Builder(
      builder: (BuildContext innerContext) {
        return ListTile(
          leading: Icon(isDarkMode ? Icons.brightness_2 : Icons.brightness_7),
          title:  Text(widget.language.tDarkModeText()),
          trailing: Icon(isDarkMode ? Icons.toggle_on : Icons.toggle_off, color: isDarkMode ? Colors.blue : Colors.grey , size: 40,),
          onTap: () {
            final RenderBox box = innerContext.findRenderObject() as RenderBox;
            final Offset globalPosition = box.localToGlobal(Offset.zero);
            _handleThemeChange(innerContext, globalPosition);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          visualDensity: VisualDensity.compact,

        );
      },
    );
  }

  void _showCircularTransitionAnimation(BuildContext context, Offset localPosition) {
    final overlay = Overlay.of(context);
    final ThemeData currentTheme = Theme.of(context);

    final entry = OverlayEntry(builder: (context) {
      return CircularTransitionOverlay(
        tapPosition: localPosition,
        color: currentTheme.scaffoldBackgroundColor,
      );
    });

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 1000), () {
      entry.remove();
    });
  }
}

class CustomInkWell extends StatelessWidget {
  final Widget child;
  final void Function(Offset globalPosition) onTap;

  const CustomInkWell({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        onTap(details.globalPosition);
      },
    );
  }
}

class CircularTransitionOverlay extends StatefulWidget {
  final Offset tapPosition;
  final Color color;

  const CircularTransitionOverlay({super.key, required this.tapPosition, required this.color});

  @override
  _CircularTransitionOverlayState createState() => _CircularTransitionOverlayState();
}
class _CircularTransitionOverlayState extends State<CircularTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final radius = _calculateRadius(size);

    return Positioned.fill(
      child: Stack(
        children: [
          IgnorePointer(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: CustomPaint(
                painter: CircularTransitionPainter(
                  animationValue: _animation.value,
                  tapPosition: widget.tapPosition,
                  color: widget.color,
                  radius: radius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateRadius(Size size) {
    final double x = max(widget.tapPosition.dx, size.width - widget.tapPosition.dx);
    final double y = max(widget.tapPosition.dy, size.height - widget.tapPosition.dy);
    return sqrt(x * x + y * y);
  }
}

class CircularTransitionPainter extends CustomPainter {
  final double animationValue;
  final Offset tapPosition;
  final Color color;
  final double radius;

  CircularTransitionPainter(
      {required this.animationValue,
        required this.tapPosition,
        required this.color,
        required this.radius});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.5); // Change the opacity here
    final currentRadius = radius * animationValue;

    canvas.drawCircle(tapPosition, currentRadius, paint);
  }


  @override
  bool shouldRepaint(CircularTransitionPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
