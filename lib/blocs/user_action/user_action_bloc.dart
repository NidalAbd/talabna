import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
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

    on<UserSearchAction>((event, emit) async {
      emit(UserActionInProgress());
      try {
        final results = await _repository.searchUserOrPost(searchAction: event.search, page: event.page);
        bool postsHasReachedMax = results["posts"].length < 10; // Using square bracket notation to access the "posts" value
        bool usersHasReachedMax = results["users"].length < 10; // Using square bracket notation to access the "posts" value
        List<User> users = [];
        List<ServicePost> servicePosts = [];
        for (var result in results["users"]) {
          if (result.runtimeType == User) {
            users.add(result as User);
          } else if (result.runtimeType == ServicePost) {
            servicePosts.add(result as ServicePost);
          }
        }
        for (var result in results["posts"]) {
          if (result.runtimeType == User) {
            users.add(result as User);
          } else if (result.runtimeType == ServicePost) {
            servicePosts.add(result as ServicePost);
          }
        }
        emit(UserSearchActionResult(users: users, servicePosts: servicePosts,usersHasReachedMax: usersHasReachedMax,servicePostsHasReachedMax: postsHasReachedMax));
      } catch (e) {
        emit(UserActionFailure(error: e.toString()));
      }
    });



  }

}