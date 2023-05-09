import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/screens/profile/other_profile_screen.dart';
import 'package:talbna/screens/profile/profile_screen.dart';
import 'package:talbna/utils/constants.dart';

class UserAvatarProfile extends StatefulWidget {
  final int toUser;
  final bool canViewProfile;
  final String? imageUrl;
  final double? radius;
  final int fromUser;
  const UserAvatarProfile({Key? key, this.imageUrl,  this.radius,  required this.toUser, required this.canViewProfile, required this.fromUser})
      : super(key: key);

  @override
  _UserAvatarProfileState createState() => _UserAvatarProfileState();
}

class _UserAvatarProfileState extends State<UserAvatarProfile> {
  late UserProfileBloc _userProfileBloc;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = (widget.imageUrl!.isNotEmpty
        ? widget.imageUrl
        : '${Constants.apiBaseUrl}/storage/photos/avatar3.png')!;
    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _userProfileBloc.stream.listen((state) {
      if (state is UserProfilePhotoUpdateSuccess && state.user.id == widget.fromUser) {
        setState(() {
          _imageUrl = (state.user.photos?.first.src ?? widget.imageUrl)!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherProfileScreen(fromUser: widget.fromUser, toUser: widget.toUser, isOtherProfile: true,),
          ),
        );
      },
      child: CircleAvatar(
        backgroundColor: const Color.fromARGB(238, 249, 230, 248),
        radius:  widget.radius! + 2,
        child: CircleAvatar(
          radius: widget.radius,
          backgroundImage: Image.network(
            _imageUrl,
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return CircleAvatar(
                radius: widget.radius,
                backgroundImage: const AssetImage('assets/avatar.png'),
              );
            },
          ).image,
        ),
      ),
    );
  }
}
