import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_event.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/data/repositories/user_follow_repository.dart';
class UserFollowBloc extends Bloc<UserFollowEvent, UserFollowState> {
  final UserFollowRepository _repository;

  UserFollowBloc({required UserFollowRepository repository})
      : _repository = repository,
        super(UserFollowInitial()) {
    print('UserFollowBloc created: $hashCode');

    on<UserFollowerRequested>((event, emit) async {
      emit(UserFollowLoadInProgress());
      try {
        final users = await _repository.getFollowerByUserId(userId: event.user, page: event.page);
        bool hasReachedMax = users.length < 10; // Assuming 10 is the maximum number of items you fetch in one request
        emit(UserFollowerFollowingSuccess(users: users, hasReachedMax: hasReachedMax));
      } catch (e) {
        emit(UserFollowLoadFailure(error: e.toString()));
      }
    });
    on<UserFollowingRequested>((event, emit) async {
      emit(UserFollowLoadInProgress());
      try {
        final users = await _repository.getFollowingByUserId(userId: event.user, page: event.page);
        bool hasReachedMax = users.length < 10; // Assuming 10 is the maximum number of items you fetch in one request
        emit(UserFollowerFollowingSuccess(users: users, hasReachedMax: hasReachedMax));
      } catch (e) {
        emit(UserFollowLoadFailure(error: e.toString()));
      }
    });

  }

}