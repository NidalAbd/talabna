import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/point_balance.dart';
import 'package:talbna/data/models/user.dart';

abstract class OtherUserProfileState extends Equatable {
  const OtherUserProfileState();

  @override
  List<Object> get props => [];
}

class OtherUserProfileInitial extends OtherUserProfileState {}

class OtherUserProfileLoadInProgress extends OtherUserProfileState {}

class OtherUserProfileLoadSuccess extends OtherUserProfileState {
  final User user;

  const OtherUserProfileLoadSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class OtherUserProfileLoadContactSuccess extends OtherUserProfileState {
  final User user;

  const OtherUserProfileLoadContactSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class OtherUserProfileLoadFailure extends OtherUserProfileState {
  final String error;

  const OtherUserProfileLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}


class OtherUserFollowerFollowingSuccess extends OtherUserProfileState {
  final List<User> users;
  final bool hasReachedMax;

  const OtherUserFollowerFollowingSuccess({required this.users, this.hasReachedMax = false});

  @override
  List<Object> get props => [users, hasReachedMax];
}

class OtherUserFollowerFollowingHasMaxReached extends OtherUserProfileState {}

class OtherUserProfileUpdateFailure extends OtherUserProfileState {
  final String error;
  const OtherUserProfileUpdateFailure({required this.error});
  @override
  List<Object> get props => [error];
}

