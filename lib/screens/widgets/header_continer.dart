import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  final double _height;

  const HeaderWidget(this._height, {Key? key}) : super(key: key);
  //static const primaryColor = Colors.black;
  @override
  _HeaderWidgetState createState() => _HeaderWidgetState(
    _height,
  );
}

class _HeaderWidgetState extends State<HeaderWidget> with SingleTickerProviderStateMixin {
  final double _height;
  late Animation<double> _animation;
  late AnimationController _animationController;

  _HeaderWidgetState(this._height);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
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
    double width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 5, _height),
            Offset(width / 10 * 5, _height - 60),
            Offset(width / 5 * 4, _height + 20),
            Offset(width, _height - 18)
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
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 2, _height + 20),
            Offset(width / 10 * 8, _height - 60),
            Offset(width / 5 * 4, _height - 60),
            Offset(width, _height - 20)
          ]),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ],
                  begin: const FractionalOffset(0.0, 1.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 2, _height + 20),
            Offset(width / 10 * 8, _height - 60),
            Offset(width / 5 * 4, _height - 60),
            Offset(width, _height - 20)
          ]),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.4),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
        ClipPath(
          clipper: ShapeClipper([
            Offset(width / 5, _height),
            Offset(width / 2, _height - 40),
            Offset(width / 5 * 4, _height - 80),
            Offset(width, _height - 20)
          ]),
          child: Center(
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                "assets/talabnaLogo.png",
                height: 150,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  List<Offset> _offsets = [];
  ShapeClipper(this._offsets);
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 20);
    path.quadraticBezierTo(
        _offsets[0].dx, _offsets[0].dy, _offsets[1].dx, _offsets[1].dy);
    path.quadraticBezierTo(
        _offsets[2].dx, _offsets[2].dy, _offsets[3].dx, _offsets[3].dy);

    path.lineTo(size.width, size.height-20);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}