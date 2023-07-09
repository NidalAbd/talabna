import 'package:equatable/equatable.dart';

abstract class UserFollowEvent extends Equatable {
  const UserFollowEvent();

  @override
  List<Object> get props => [];
}

class UserFollowerRequested extends UserFollowEvent {
  final int user;
  final int page;

  const UserFollowerRequested({required this.user, this.page = 1});

}
class UserSellerRequested extends UserFollowEvent {
  final int page;

  const UserSellerRequested({ this.page = 1});

}
class UserFollowingRequested extends UserFollowEvent {
  final int user;
  final int page;

  const UserFollowingRequested({required this.user, this.page = 1});
}

