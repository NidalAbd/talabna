import 'package:equatable/equatable.dart';

abstract class OtherUserProfileEvent extends Equatable {
  const OtherUserProfileEvent();

  @override
  List<Object> get props => [];
}

class OtherUserProfileRequested extends OtherUserProfileEvent {
  final int id;

  const OtherUserProfileRequested({required this.id});

  @override
  List<Object> get props => [id];
}
class OtherUserProfileContactRequested extends OtherUserProfileEvent {
  final int id;

  const OtherUserProfileContactRequested({required this.id});

  @override
  List<Object> get props => [id];
}


class OtherUserFollowerRequested extends OtherUserProfileEvent {
  final int user;
  final int page;

  const OtherUserFollowerRequested({required this.user, this.page = 1});
}

class OtherUserFollowingRequested extends OtherUserProfileEvent {
  final int user;
  final int page;

  const OtherUserFollowingRequested({required this.user, this.page = 1});
}

