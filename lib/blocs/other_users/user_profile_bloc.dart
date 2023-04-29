import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';

import 'package:talbna/data/repositories/user_profile_repository.dart';
class OtherUserProfileBloc extends Bloc<OtherUserProfileEvent, OtherUserProfileState> {
  final UserProfileRepository _repository;

  OtherUserProfileBloc({required UserProfileRepository repository})
      : _repository = repository,
        super(OtherUserProfileInitial()) {
    print('OtherUserProfileBloc created: ${this.hashCode}');

    on<OtherUserProfileRequested>((event, emit) async {
      emit(OtherUserProfileLoadInProgress());
      try {
        final userProfile = await _repository.getUserProfileById(event.id);
        emit(OtherUserProfileLoadSuccess(user: userProfile));
      } catch (e) {
        emit(OtherUserProfileLoadFailure(error: e.toString()));
      }
    });
    on<OtherUserProfileContactRequested>((event, emit) async {
      emit(OtherUserProfileLoadInProgress());
      try {
        final userProfile = await _repository.getUserProfileById(event.id);
        emit(OtherUserProfileLoadContactSuccess(user: userProfile));
      } catch (e) {
        emit(OtherUserProfileLoadFailure(error: e.toString()));
      }
    });


    on<OtherUserFollowerRequested>((event, emit) async {
      emit(OtherUserProfileLoadInProgress());
      try {
        final users = await _repository.getFollowerByUserId(userId: event.user, page: event.page);
        bool hasReachedMax = users.length < 10; // Assuming 10 is the maximum number of items you fetch in one request
        emit(OtherUserFollowerFollowingSuccess(users: users, hasReachedMax: hasReachedMax));
      } catch (e) {
        emit(OtherUserProfileLoadFailure(error: e.toString()));
      }
    });

    on<OtherUserFollowingRequested>((event, emit) async {
      emit(OtherUserProfileLoadInProgress());
      try {
        final users = await _repository.getFollowingByUserId(userId: event.user, page: event.page);
        bool hasReachedMax = users.length < 10; // Assuming 10 is the maximum number of items you fetch in one request
        emit(OtherUserFollowerFollowingSuccess(users: users, hasReachedMax: hasReachedMax));
      } catch (e) {
        emit(OtherUserProfileLoadFailure(error: e.toString()));
      }
    });


  }

}