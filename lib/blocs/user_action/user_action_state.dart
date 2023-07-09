import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/service_post.dart';
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
class UserFollowUnFollowFromListToggled extends UserActionState {
  final bool isFollower;
  final int userId;

  const UserFollowUnFollowFromListToggled({required this.isFollower , required this.userId, });

  @override
  List<Object> get props => [isFollower, userId];
}
class UserPasswordUpdateSuccess extends UserActionState {}

class UserMakeFollowSubcategoriesSuccess extends UserActionState {
  final bool followSuccess;

  const UserMakeFollowSubcategoriesSuccess(this.followSuccess);

  @override
  List<Object> get props => [followSuccess];
}
class GetFollowSubcategoriesSuccess extends UserActionState {
  final bool followSuccess;

  const GetFollowSubcategoriesSuccess(this.followSuccess);

  @override
  List<Object> get props => [followSuccess];
}
class GetFollowUserSuccess extends UserActionState {
  final bool followSuccess;

  const GetFollowUserSuccess(this.followSuccess);

  @override
  List<Object> get props => [followSuccess];
}
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

class UserSearchActionResult extends UserActionState {
  final List<User> users;
  final List<ServicePost> servicePosts;
  final bool usersHasReachedMax;
  final bool servicePostsHasReachedMax;

  const UserSearchActionResult(  {
    required this.users,
    required this.servicePosts,
    this.usersHasReachedMax = false,
    this.servicePostsHasReachedMax= false,
  });

  @override
  List<Object> get props => [users, servicePosts, usersHasReachedMax, servicePostsHasReachedMax];
}
class UserFollowerFollowingHasMaxReached extends UserActionState {}
