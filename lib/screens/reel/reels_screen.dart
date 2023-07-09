import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/screens/widgets/user_avatar_profile.dart';
import 'package:talbna/utils/constants.dart';
import 'package:video_player/video_player.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;
  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  late UserProfileBloc _userProfileBloc;
  late VideoPlayerController _controller;
  final double iconSize = 30;
  @override
  void initState() {
    super.initState();
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _controller = VideoPlayerController.asset('assets/video_template01.mp4')
      ..initialize().then((_) {
        // Ensure the video is looped and started playing
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                color: AppTheme.primaryColor,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true, // Enable scrubbing
                        colors: const VideoProgressColors(
                          playedColor: Colors.white, // Customize played color
                          bufferedColor:
                              Colors.white54, // Customize buffered color
                          backgroundColor:
                              Colors.grey, // Customize background color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: -30,
                left: 5,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
            Positioned(
              right: 10,
              bottom: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocConsumer<UserProfileBloc, UserProfileState>(
                      bloc: _userProfileBloc,
                      listener: (context, state) {
                        if (state is UserProfileUpdateSuccess) {
                          BlocProvider.of<UserProfileBloc>(context)
                              .add(UserProfileRequested(id: widget.userId));
                        }
                      },
                      builder: (context, state) {
                        if (state is UserProfileLoadSuccess) {
                          final user = state.user;
                          return Column(
                            children: [
                              UserAvatarProfile(
                                imageUrl:
                                    '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
                                radius: 20,
                                toUser: user.id,
                                canViewProfile: false,
                                fromUser: user.id,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_rounded,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.mode_comment_rounded,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.card_giftcard,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.flag,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
