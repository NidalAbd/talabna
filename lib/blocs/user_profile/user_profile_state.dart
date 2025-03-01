import 'package:equatable/equatable.dart';
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
}

class UserProfileUpdateSuccess extends UserProfileState {
  final User user;

  const UserProfileUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

// Add the missing state for photo update success
class UserProfilePhotoUpdateSuccess extends UserProfileState {
  final User user;

  const UserProfilePhotoUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class UserProfileUpdateFailure extends UserProfileState {
  final String error;

  const UserProfileUpdateFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// New state for unique constraint violations
class UserProfileUniqueConstraintFailure extends UserProfileState {
  final String error;
  final String? field;

  const UserProfileUniqueConstraintFailure({
    required this.error,
    this.field,
  });

  @override
  List<Object> get props => [error, field ?? ''];
}