import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';
import 'package:geocoding/geocoding.dart';

class UserCard extends StatefulWidget {
  final User follower;
  final bool isFollower;
  final int userId;
  final UserActionBloc userActionBloc;
  const UserCard({Key? key, required this.follower, required this.userActionBloc, required this.isFollower, required this.userId,})
      : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String? city;

  @override
  void initState() {
    super.initState();
    _getCityName();
  }

  Future<void> _getCityName() async {
    if (widget.follower.locationLatitudes != null &&
        widget.follower.locationLongitudes != null) {
      double lat =
          double.tryParse(widget.follower.locationLatitudes.toString()) ?? 0.0;
      double lng =
          double.tryParse(widget.follower.locationLongitudes.toString()) ?? 0.0;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final Placemark placemark = placemarks.first;
          setState(() {
            city = placemark.locality ?? placemark.administrativeArea;
            print(city);
          });
        } else {}
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl =
        'https://example.com/default-avatar.png'; // Provide a default avatar URL
    if (widget.follower.photos!.isNotEmpty) {
      avatarUrl = widget.follower.photos![0].src;
    }
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.lightForegroundColor
          : AppTheme.darkForegroundColor,
      child: ListTile(
        title: Text(widget.follower.userName!),
        subtitle: Text(city ?? widget.follower.city!,),
        leading: UserAvatar(
          imageUrl:
          '${Constants.apiBaseUrl}/storage/${widget.follower.photos![0].src}',
          radius: 16,  toUser: widget.follower.id, canViewProfile: true, fromUser: widget.userId,
        ),
        trailing: BlocConsumer<UserActionBloc, UserActionState>(
        bloc: widget.userActionBloc,
          listener: (context, state) {},
          builder: (context , state){
        bool isFollower = widget.isFollower;
        if(state is UserFollowUnFollowToggled && state.userId == widget.follower.id){
          isFollower = state.isFollower;
        }
        return TextButton(
            onPressed: () {
              widget.userActionBloc.add(ToggleUserMakeFollowEvent(user: widget.follower.id));
            },
            child:   Text(isFollower? 'unfollow' :'follow' , style: const TextStyle(fontSize: 16),) );
      },
      )
      ),
    );

  }
}
