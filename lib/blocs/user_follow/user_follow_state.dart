import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/user.dart';

abstract class UserFollowState extends Equatable {
  const UserFollowState();

  @override
  List<Object> get props => [];
}

class UserFollowInitial extends UserFollowState {}

class UserFollowLoadInProgress extends UserFollowState {}


class UserFollowLoadFailure extends UserFollowState {
  final String error;

  const UserFollowLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UserFollowerFollowingSuccess extends UserFollowState {

  final List<User> users;
  final bool hasReachedMax;

  const UserFollowerFollowingSuccess({required this.users, this.hasReachedMax = false});

  @override
  List<Object> get props => [users, hasReachedMax];
}

class UserSellerSuccessState extends UserFollowState {

  final List<User> users;
  final bool hasReachedMax;
  const UserSellerSuccessState({required this.users, this.hasReachedMax = false});

  @override
  List<Object> get props => [users, hasReachedMax];
}
class UserFollowerFollowingHasMaxReached extends UserFollowState {}

