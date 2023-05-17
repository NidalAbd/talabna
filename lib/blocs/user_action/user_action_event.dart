import 'package:equatable/equatable.dart';

abstract class UserActionEvent extends Equatable {
  const UserActionEvent();

  @override
  List<Object> get props => [];
}

class UserActionEventStarted extends UserActionEvent {}

class ToggleUserMakeFollowEvent extends UserActionEvent {
  final int user;
  const ToggleUserMakeFollowEvent({required this.user});

  @override
  List<Object> get props => [user];
}
class UpdateUserPassword extends UserActionEvent {
  final int userId;
  final String oldPassword;
  final String newPassword;

  const UpdateUserPassword({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
  });
}

class UpdateUserEmail extends UserActionEvent {
  final int userId;
  final String newEmail;
  final String password;

  const UpdateUserEmail({required this.userId, required this.newEmail, required this.password});
}
class UserMakeFollowSubcategories extends UserActionEvent {
  final int subCategoryId;

  const UserMakeFollowSubcategories({required this.subCategoryId});

  @override
  List<Object> get props => [subCategoryId];
}
class GetUserFollowSubcategories extends UserActionEvent {
  final int subCategoryId;

  const GetUserFollowSubcategories({required this.subCategoryId});
  @override
  List<Object> get props => [subCategoryId];
}
class UserSearchAction extends UserActionEvent {
  final String search;
  final int page;

  const UserSearchAction({required this.search,this.page = 1});
}
class UserFollowerFollowingHasMaxReached extends UserActionEvent {}
