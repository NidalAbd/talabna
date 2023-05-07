import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/user.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileRequested extends UserProfileEvent {
  final int id;

  const UserProfileRequested({required this.id});

  @override
  List<Object> get props => [id];
}
class UserProfileContactRequested extends UserProfileEvent {
  final int id;

  const UserProfileContactRequested({required this.id});

  @override
  List<Object> get props => [id];
}


class UserProfileUpdated extends UserProfileEvent {
  final User user;

  const UserProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}
class UpdateUserProfilePhoto extends UserProfileEvent {
  final User user;
  final File photo;

  const UpdateUserProfilePhoto({required this.user, required this.photo});
}


class UpdateUserPassword extends UserProfileEvent {
  final User user;
  final String oldPassword;
  final String newPassword;

  const UpdateUserPassword({
    required this.user,
    required this.oldPassword,
    required this.newPassword,
  });
}

class UpdateUserEmail extends UserProfileEvent {
  final User user;
  final String newEmail;
  final String password;

  const UpdateUserEmail({required this.user, required this.newEmail, required this.password});
}