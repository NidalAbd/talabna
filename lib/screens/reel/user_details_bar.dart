import 'package:flutter/material.dart';
import 'package:talbna/utils/constants.dart';

class UserDetailsBar extends StatelessWidget {
  final String userPhotoUrl;
  final double radius;
  final Color backgroundColor;

  const UserDetailsBar({
    Key? key,
    required this.userPhotoUrl,
    this.radius = 25,
    this.backgroundColor = const Color.fromARGB(238, 249, 230, 248),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: CircleAvatar(
        radius: radius - 2,
        backgroundImage: NetworkImage(
          '${Constants.apiBaseUrl}/storage/$userPhotoUrl',
        ),
        onBackgroundImageError: (exception, stackTrace) {
          // Log the error or handle it appropriately
          // Don't return a widget here. It's just a callback to handle errors.
        },
        child: Image.asset('assets/avatar.png'), // Default image
      ),
    );
  }
}
