import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/repositories/user_follow_repository.dart';
class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  final UserFollowRepository _repository;

  UserActionBloc({required UserFollowRepository repository})
      : _repository = repository,
        super(UserActionInitial()) {
    print('UserActionBloc created: $hashCode');

    on<ToggleUserMakeFollowEvent>((event, emit) async {
      emit(UserActionInProgress());
      try {
        bool newFollowerStatus =  await _repository.toggleUserActionFollow(userId: event.user);
        emit(UserFollowUnFollowToggled(isFollower: newFollowerStatus, userId: event.user));
      } catch (e) {
        emit(UserActionFailure(error: e.toString()));
      }
    });
    on<UserMakeFollowSubcategories>((event, emit) async {
      emit(UserActionInProgress());
      try {
        final bool subcategories = await _repository.toggleFollowSubcategories(event.subCategoryId);
        emit(UserMakeFollowSubcategoriesSuccess(subcategories));
      } catch (e) {
        emit(UserActionFailure(error: e.toString()));
      }
    });

    on<GetUserFollowSubcategories>((event, emit) async {
      emit(UserActionInProgress());
      try {
        final bool subCategoryMenu = await _repository.getUserFollowSubcategories(event.subCategoryId);
        emit(GetFollowSubcategoriesSuccess(subCategoryMenu));
      } catch (e) {
        emit(UserActionFailure(error: e.toString()));
      }
    });
  }

}