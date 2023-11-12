import 'package:flutter/material.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/screens/widgets/comment_sheet.dart';
import 'package:talbna/screens/widgets/contact_sheet.dart';

class InteractionButtons extends StatelessWidget {
  final int favoritesCount;
  final int commentsCount;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onSharePressed;

  const InteractionButtons({
    Key? key,
    required this.favoritesCount,
    required this.commentsCount,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onCommentPressed,
    required this.onContactPressed,
    required this.onSharePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            Icons.favorite_rounded,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: onFavoritePressed,
        ),
        Text(
          '$favoritesCount',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(
            Icons.comment_rounded,
            color: Colors.white,
          ),
          onPressed: onCommentPressed,
        ),
        Text(
          '$commentsCount',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(
            Icons.phone_in_talk_rounded,
            color: Colors.white,
          ),
          onPressed: onContactPressed,
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(
            Icons.share_rounded,
            color: Colors.white,
          ),
          onPressed: onSharePressed,
        ),
      ],
    );
  }
}
