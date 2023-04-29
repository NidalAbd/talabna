import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/point_balance.dart';
import 'package:talbna/data/models/user.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoadInProgress extends UserProfileState {}

class UserProfileLoadSuccess extends UserProfileState {
  final User user;

  const UserProfileLoadSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class UserProfileLoadContactSuccess extends UserProfileState {
  final User user;

  const UserProfileLoadContactSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class UserProfileLoadFailure extends UserProfileState {
  final String error;

  const UserProfileLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
class UserProfileUpdateInProgress extends UserProfileState {
  const UserProfileUpdateInProgress();
  @override
  List<Object> get props => [];
}
class UserProfileUpdateSuccess extends UserProfileState {
  final User user;
  const UserProfileUpdateSuccess({required this.user});
  @override
  List<Object> get props => [user];
}

class UserProfileUpdateFailure extends UserProfileState {
  final String error;
  const UserProfileUpdateFailure({required this.error});
  @override
  List<Object> get props => [error];
}
class UserProfilePhotoUpdateSuccess extends UserProfileState {
  final User user;

  const UserProfilePhotoUpdateSuccess({required this.user});
}

class UserProfilePhotoUpdateFailure extends UserProfileState {
  final String error;

  const UserProfilePhotoUpdateFailure({required this.error});
}

class UserPasswordUpdateSuccess extends UserProfileState {}

class UserPasswordUpdateFailure extends UserProfileState {
  final String error;

  const UserPasswordUpdateFailure({required this.error});
}

class UserEmailUpdateSuccess extends UserProfileState {
  final int userId;

  const UserEmailUpdateSuccess({required this.userId});
}

class UserEmailUpdateFailure extends UserProfileState {
  final String error;

  const UserEmailUpdateFailure({required this.error});
}

