import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "تصفح تواصل تقدم",
                      style: GoogleFonts.cairo(  // Use Cairo font
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2.0, 2.0),
                            blurRadius: 3.0,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:Row(
                          children: [
                            Expanded(
                              child: ElevatedButton( // Changed to OutlinedButton
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor
                                      .withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10), // Adjust the radius as per your requirement
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, 'registerNew');
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor
                                      .withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10), // Adjust the radius as per your requirement
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, 'loginNew');
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                  const Positioned(
                    child:  LogoTitle(
                      fontSize: 40,
                      playAnimation: false,
                      logoSize: 60,
                    ),

                  ),
                  Positioned(
                    top: 30,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.brightness_6),
                      onPressed: () =>
                          BlocProvider.of<ThemeCubit>(context).toggleTheme(),
                    ),),
                ],
              ),
            ),
          );
        }
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 4.2);  // Start from the first fourth from the top

    var firstControlPoint = Offset(size.width / 4, size.height / 5);
    var firstEndPoint = Offset(size.width / 2, size.height / 4.2);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height / 3.5);
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
