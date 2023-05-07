import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/user.dart';

abstract class UserActionState extends Equatable {
  const UserActionState();

  @override
  List<Object> get props => [];
}

class UserActionInitial extends UserActionState {}

class UserActionInProgress extends UserActionState {}

class UserMakeFollowSuccess extends UserActionState {}

class UserMakeUnFollowSuccess extends UserActionState {}
class UserFollowUnFollowToggled extends UserActionState {
  final bool isFollower;
  final int userId;

  const UserFollowUnFollowToggled({required this.isFollower , required this.userId, });

  @override
  List<Object> get props => [isFollower, userId];
}

class UserPasswordUpdateSuccess extends UserActionState {}


class UserEmailUpdateSuccess extends UserActionState {
  final int userId;

  const UserEmailUpdateSuccess({required this.userId});
}
class UserActionFailure extends UserActionState {
  final String error;

  const UserActionFailure({required this.error});

  @override
  List<Object> get props => [error];
}
