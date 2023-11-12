// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:talbna/app_theme.dart';
// import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
// import 'package:talbna/blocs/user_profile/user_profile_event.dart';
// import 'package:talbna/blocs/user_profile/user_profile_state.dart';
// import 'package:talbna/data/models/comment.dart';
// import 'package:talbna/data/models/user.dart';
// import 'package:talbna/screens/widgets/user_avatar_profile.dart';
// import 'package:talbna/utils/constants.dart';
//
// import '../../provider/language.dart';
//
// class CommentModalBottomSheet extends StatefulWidget {
//   final double iconSize;
//   final int userId;
//   final UserProfileBloc userProfileBloc;
//
//   const CommentModalBottomSheet({super.key,
//     required this.iconSize,
//     required this.userId,
//     required this.userProfileBloc,
//   });
//
//   @override
//   State<CommentModalBottomSheet> createState() => _CommentModalBottomSheetState();
// }
//
// class _CommentModalBottomSheetState extends State<CommentModalBottomSheet> {
//   final Language _language = Language();
//
//   List<Comments> comments = [
//     Comment(
//       text: "Wow, this video is incredible!",
//       user: User(
//         id: 5,
//         name: "may",
//         photos: [
//           Photo(
//             src: "photos/avatar5.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user5@example.com',
//       ),
//     ),
//     Comment(
//       text: "I can't stop watching this video!",
//       user: User(
//         id: 6,
//         name: "monzer",
//         photos: [
//           Photo(
//             src: "photos/avatar4.png",
//             id: 55000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user6@example.com',
//       ),
//     ),
//     Comment(
//       text: "Absolutely mind-blowing! I love it.",
//       user: User(
//         id: 7,
//         name: "wael",
//         photos: [
//           Photo(
//             src: "photos/avatar3.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user7@example.com',
//       ),
//     ),
//     Comment(
//       text: "This video deserves all the awards!",
//       user: User(
//         id: 8,
//         name: "nidal",
//         photos: [
//           Photo(
//             src: "photos/avatar2.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user8@example.com',
//       ),
//     ),
//     Comment(
//       text: "Incredible work! I'm speechless.",
//       user: User(
//         id: 9,
//         name: "omar",
//         photos: [
//           Photo(
//             src: "photos/avatar5.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user9@example.com',
//       ),
//     ),
//     Comment(
//       text: "This video just made my day!",
//       user: User(
//         id: 10,
//         name: "ahmed",
//         photos: [
//           Photo(
//             src: "photos/avatar3.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user10@example.com',
//       ),
//     ),
//     Comment(
//       text: "I can't get enough of this video!",
//       user: User(
//         id: 11,
//         name: "mohammed",
//         photos: [
//           Photo(
//             src: "photos/avatar4.png",
//             id: 5000,
//             photoableType: 'App\Models\ServicePost',
//             photoableId: 4500,
//             createdAt: DateTime.parse('2023-06-19 22:45:26'),
//             updatedAt: DateTime.parse('2023-06-19 22:45:26'),
//           ),
//         ],
//         email: 'user11@example.com',
//       ),
//     ),
//   ];
//
//
//   @override
//   void initState() {
//     super.initState();
//     widget.userProfileBloc.add(UserProfileRequested(id: widget.userId));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true, // Enable scrolling within the modal
//           builder: (BuildContext context) {
//             return Container(
//               height: MediaQuery.of(context).size.height * 2 / 3, // Set the height to 2/3 of the screen height
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? AppTheme.darkPrimaryColor
//                   : AppTheme.lightPrimaryColor,
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Header
//                    Text(
//                     _language.getCommentsText(),
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     // Body - ListView of comments
//                     child: ListView.separated(
//                       itemCount: comments.length, // Replace with the actual list of comments
//                       separatorBuilder: (context, index) => Divider(
//                         color: Colors.white.withOpacity(0.2),
//                         thickness: 1,
//                         height: 16,
//                       ),
//                       itemBuilder: (BuildContext context, int index) {
//                         final comment = comments[index]; // Replace with your comment model
//                         return Container(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               UserAvatarProfile(
//                                 imageUrl: '${Constants.apiBaseUrl}/storage/${comment.user.photos?.first.src}',
//                                 radius: 20,
//                                 toUser: comment.user.id,
//                                 canViewProfile: false,
//                                 fromUser: comment.user.id,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       comment.text,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       comment.user.name!,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: Row(
//                       children: [
//                         BlocConsumer<UserProfileBloc, UserProfileState>(
//                           bloc: widget.userProfileBloc,
//                           listener: (context, state) {
//                             if (state is UserProfileUpdateSuccess) {
//                               BlocProvider.of<UserProfileBloc>(context).add(UserProfileRequested(id: widget.userId));
//                             }
//                           },
//                           builder: (context, state) {
//                             if (state is UserProfileLoadSuccess) {
//                               final user = state.user;
//                               return UserAvatarProfile(
//                                 imageUrl: '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
//                                 radius: 20,
//                                 toUser: user.id,
//                                 canViewProfile: false,
//                                 fromUser: user.id,
//                               );
//                             } else {
//                               return const Center(child: CircularProgressIndicator());
//                             }
//                           },
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               children: [
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: TextFormField(
//                                     decoration: const InputDecoration(
//                                       hintText: 'Add a comment',
//                                       border: InputBorder.none,
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () {
//                                     // Add your logic here to handle the comment submission
//                                   },
//                                   icon:  Icon(
//                                     Icons.send,
//                                     color: Theme.of(context).brightness == Brightness.dark
//                                         ? AppTheme.lightPrimaryColor
//                                         : AppTheme.darkPrimaryColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       icon:  Icon(
//         Icons.comment,
//         size: widget.iconSize,
//         color: Colors.white,
//         shadows: [
//           Shadow(
//             color: Colors.black
//                 .withOpacity(1), // Shadow color
//             offset: const Offset(0,
//                 0), // Shadow offset (vertical, horizontal)
//             blurRadius:
//             4, // Blur radius of the shadow
//           ),
//         ],
//       ),
//     );
//   }
// }
