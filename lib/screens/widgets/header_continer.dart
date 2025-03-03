import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  final double _height;

  const HeaderWidget(this._height, {super.key});

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 5, widget._height),
            Offset(width / 10 * 5, widget._height - 60),
            Offset(width / 5 * 4, widget._height + 20),
            Offset(width, widget._height - 18),
          ]),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColorDark.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: const [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 2, widget._height + 20),
            Offset(width / 10 * 8, widget._height - 60),
            Offset(width / 5 * 4, widget._height - 60),
            Offset(width, widget._height - 20),
          ]),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: const [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final List<Offset> points;

  ShapeClipper(this.points);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
