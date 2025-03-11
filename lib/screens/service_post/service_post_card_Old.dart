// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:talbna/app_theme.dart';
// import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
// import 'package:talbna/blocs/service_post/service_post_bloc.dart';
// import 'package:talbna/data/models/service_post.dart';
// import 'package:talbna/data/models/user.dart';
// import 'package:talbna/screens/service_post/service_post_card_header.dart';
// import 'package:talbna/screens/service_post/service_post_view.dart';
// import 'package:talbna/screens/widgets/image_grid.dart';
// import 'package:talbna/screens/widgets/service_post_action.dart';
// import 'package:talbna/screens/widgets/user_avatar.dart';
// import 'package:talbna/utils/constants.dart';
//
// import '../../provider/language.dart';
//
// class ServicePostCard extends StatefulWidget {
//   const ServicePostCard({
//     Key? key,
//     this.onPostDeleted,
//     required this.servicePost,
//     required this.canViewProfile,
//     required this.userProfileId, required this.user,
//   }) : super(key: key);
//   final ServicePost servicePost;
//   final Function? onPostDeleted;
//   final bool canViewProfile;
//   final int userProfileId;
//   final User user;
//
//   @override
//   State<ServicePostCard> createState() => _ServicePostCardState();
// }
//
// class _ServicePostCardState extends State<ServicePostCard> {
//   late ServicePostBloc _servicePostBloc;
//   late OtherUserProfileBloc _userProfileBloc;
//   late EdgeInsets padding;
//   final Language _language = Language();
//
//   late  String? description;
//   bool isTextMoreThanTwoLines(TextStyle style, String text, double maxWidth, int maxLines) {
//     final TextSpan span = TextSpan(text: text, style: style);
//     final TextPainter tp = TextPainter(
//       text: span,
//       maxLines: maxLines,
//       textDirection: TextDirection.rtl,
//     );
//     tp.layout(maxWidth: maxWidth);
//     return tp.didExceedMaxLines;
//   }
//   @override
//   void initState() {
//     super.initState();
//     _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
//     _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
//     if (widget.servicePost.haveBadge == 'عادي') {
//       padding = const EdgeInsets.fromLTRB(0, 0, 0, 0);
//     } else {
//       padding = const EdgeInsets.fromLTRB(0, 25, 0, 0);
//     }
//      description = widget.servicePost.description;
//
//   }
//
//   String formatTimeDifference(DateTime? postDate) {
//     if (postDate == null) {
//       return 'Unknown time';
//     }
//     Duration difference = DateTime.now().difference(postDate);
//     if (difference.inSeconds < 60) {
//       return '${difference.inSeconds}sec ago';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 30) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inDays < 365) {
//       return '${(difference.inDays / 30).round()}M ago';
//     } else {
//       return '${(difference.inDays / 365).round()}Y ago';
//     }
//   }
//
//   String formatNumber(int number) {
//     if (number >= 1000000000) {
//       final double formattedNumber = number / 1000000;
//       const String suffix = 'B';
//       return '${formattedNumber.toStringAsFixed(1)}$suffix';
//     } else if (number >= 1000000) {
//       final double formattedNumber = number / 1000000;
//       const String suffix = 'M';
//       return '${formattedNumber.toStringAsFixed(1)}$suffix';
//     } else if (number >= 1000) {
//       final double formattedNumber = number / 1000;
//       const String suffix = 'K';
//       return '${formattedNumber.toStringAsFixed(1)}$suffix';
//     } else {
//       return number.toString();
//     }
//   }
//
//   String getHaveBadgeText(String haveBadge) {
//     switch (haveBadge) {
//       case 'ماسي':
//         return 'Feature';
//       case 'ذهبي':
//         return 'Feature';
//       case 'عادي':
//         return 'عادي';
//       default:
//         return haveBadge;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const textStyle = TextStyle(fontSize: 14);
//
//     final isMoreThanTwoLines = isTextMoreThanTwoLines(
//       textStyle,
//       description!,
//       MediaQuery.of(context).size.width - 30, // Adjust the max width as needed
//       2, // Set the maximum number of lines you want to check
//     );
//     return Padding(
//       padding: padding,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           widget.servicePost.haveBadge == 'عادي'
//               ? Container()
//               : Positioned(
//                   top: -20,
//                   left: 0,
//                   child: Wrap(children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(2, 1, 0, 10),
//                       child: ServicePostHeaderContainer(
//                         haveBadge: widget.servicePost.haveBadge!,
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
//                           child: Text(
//                             getHaveBadgeText(widget.servicePost.haveBadge!),
//                             style: const TextStyle(
//                               color: Color.fromARGB(255, 255, 255, 255),
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ]),
//                 ),
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? AppTheme.lightForegroundColor
//                   : AppTheme.darkForegroundColor,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 18,
//                         backgroundColor: Theme.of(context).brightness == Brightness.dark
//                             ? AppTheme.lightPrimaryColor.withOpacity(0.8)
//                             : AppTheme.darkPrimaryColor.withOpacity(0.2),
//                         child: UserAvatar
//                           (
//                             imageUrl:'${Constants.apiBaseUrl}/${widget.servicePost.userPhoto}',
//                             radius: 16,
//                             fromUser: widget.userProfileId,
//                             toUser: widget.servicePost.userId!,
//                             canViewProfile: widget.canViewProfile, user: widget.user,
//                            ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const SizedBox(
//                               height: 11,
//                             ),
//                             Text(
//                               widget.servicePost.userName ??
//                                   'Unknown', // Display full username
//                               maxLines: 1, // Allow only one line of text
//                               overflow: TextOverflow
//                                   .ellipsis, // Display ellipsis if text overflows
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(
//                               formatTimeDifference(
//                                   widget.servicePost.createdAt),
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (widget.servicePost.categoriesId != 7)
//                         const Expanded(
//                           flex: 2,
//                           child: Row(
//                             children: [
//                             ],
//                           ),
//                         ),
//                       ServicePostAction(
//                         key: Key('servicePost_${widget.servicePost.id}'),
//                         servicePostUserId: widget.servicePost.userId,
//                         userProfileId: widget.userProfileId,
//                         servicePostId: widget.servicePost.id,
//                         onPostDeleted: widget.onPostDeleted!,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 0),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => ServicePostCardView(
//                             key: Key('servicePost_${widget.servicePost.id}'),
//                             onPostDeleted: widget.onPostDeleted,
//                             userProfileId: widget.userProfileId,
//                             servicePost: widget.servicePost,
//                             canViewProfile: widget.canViewProfile, user: widget.user,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 5),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           child: Text(
//                             description!,
//                             maxLines: isMoreThanTwoLines ? 2 : null,
//                             style: textStyle,
//                           ),
//                         ),
//                         if (isMoreThanTwoLines)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) => ServicePostCardView(
//                                       key: Key('servicePost_${widget.servicePost.id}'),
//                                       onPostDeleted: widget.onPostDeleted,
//                                       userProfileId: widget.userProfileId,
//                                       servicePost: widget.servicePost,
//                                       canViewProfile: widget.canViewProfile, user: widget.user,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Directionality(
//                                 textDirection: TextDirection.ltr,
//                                 child: Text(
//                                   _language.getMoreText(),
//                                   style: TextStyle(
//
//                                     color: Theme.of(context).brightness == Brightness.dark
//                                         ? AppTheme.darkForegroundColor.withOpacity(0.5)
//                                         : AppTheme.lightForegroundColor.withOpacity(0.5),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: GestureDetector(
//                             onTap: (){
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => ServicePostCardView(
//                                     key: Key('servicePost_${widget.servicePost.id}'),
//                                     onPostDeleted: widget.onPostDeleted,
//                                     userProfileId: widget.userProfileId,
//                                     servicePost: widget.servicePost,
//                                     canViewProfile: widget.canViewProfile,
//                                     user: widget.user,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: ImageGrid(
//                               imageUrls: widget.servicePost.photos
//                                       ?.map((photo) =>
//                                           '${photo.src}')
//                                       .toList() ??
//                                   [],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 ListTile(
//                   leading: SizedBox(
//                     width: 200,
//                     child: Row(
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.remove_red_eye,
//                               color: Theme.of(context).brightness == Brightness.dark
//                                   ? AppTheme.lightBackgroundColor
//                                   : AppTheme.lightForegroundColor,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               formatNumber(widget.servicePost.viewCount ?? 0),
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color:
//                                 Theme.of(context).brightness == Brightness.dark
//                                     ? AppTheme.lightBackgroundColor
//                                     : AppTheme.lightForegroundColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(width: 20,),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.comment,
//                               color: Theme.of(context).brightness == Brightness.dark
//                                   ? AppTheme.lightBackgroundColor
//                                   : AppTheme.lightForegroundColor,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               formatNumber(widget.servicePost.commentsCount ?? 0),
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color:
//                                 Theme.of(context).brightness == Brightness.dark
//                                     ? AppTheme.lightBackgroundColor
//                                     : AppTheme.lightForegroundColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(width: 20,),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.fmd_bad,
//                               color: Theme.of(context).brightness == Brightness.dark
//                                   ? AppTheme.lightBackgroundColor
//                                   : AppTheme.lightForegroundColor,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               formatNumber(widget.servicePost.reportCount ?? 0),
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color:
//                                 Theme.of(context).brightness == Brightness.dark
//                                     ? AppTheme.lightBackgroundColor
//                                     : AppTheme.lightForegroundColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   selected: true,
//                   selectedTileColor:
//                       Theme.of(context).brightness == Brightness.dark
//                           ? AppTheme.lightForegroundColor.withOpacity(0.5)
//                           : AppTheme.darkForegroundColor.withOpacity(0.5),
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => ServicePostCardView(
//                           key: Key('servicePost_${widget.servicePost.id}'),
//                           onPostDeleted: widget.onPostDeleted,
//                           userProfileId: widget.userProfileId,
//                           servicePost: widget.servicePost,
//                           canViewProfile: widget.canViewProfile, user: widget.user,
//                         ),
//                       ),
//                     );
//                   },
//                   title: widget.servicePost.categoriesId != 7
//                       ? Directionality(
//                           textDirection: TextDirection.rtl,
//                           child: Text(
//                             widget.servicePost.distance.toString(),
//                             style: TextStyle(
//                               color: Theme.of(context).brightness ==
//                                       Brightness.dark
//                                   ? AppTheme.lightDisabledColor
//                                   : AppTheme.darkDisabledColor,
//                             ),
//                           ),
//                         )
//                       : null,
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? AppTheme.lightDisabledColor
//                         : AppTheme.darkDisabledColor,
//                   ),
//                 ),
//                 Divider(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
