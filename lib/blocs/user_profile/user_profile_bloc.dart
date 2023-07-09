import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/repositories/user_profile_repository.dart';
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileBloc({required UserProfileRepository repository})
      : _repository = repository,
        super(UserProfileInitial()) {
    print('UserProfileBloc created: ${this.hashCode}');

    on<UserProfileRequested>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        final userProfile = await _repository.getUserProfileById(event.id);
        emit(UserProfileLoadSuccess(user: userProfile));
      } catch (e) {
        emit(UserProfileLoadFailure(error: e.toString()));
      }
    });
    on<UserProfileContactRequested>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        final userProfile = await _repository.getUserProfileById(event.id);
        emit(UserProfileLoadContactSuccess(user: userProfile));
      } catch (e) {
        emit(UserProfileLoadFailure(error: e.toString()));
      }
    });


    on<UserProfileUpdated>((event, emit) async {
      emit(const UserProfileUpdateInProgress());
      try {
        final user = await _repository.updateUserProfile(event.user);
        emit(UserProfileUpdateSuccess(user: user));
      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
      }
    });

    on<UpdateUserProfilePhoto>((event, emit) async {
      emit(const UserProfileUpdateInProgress());
      try {
        await _repository.updateUserProfilePhoto(event.user, event.photo);
        emit(UserProfileUpdateSuccess(user: event.user));
      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
      }
    });

    on<UpdateUserPassword>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        await _repository.updateUserPassword(
          event.user,
          event.oldPassword,
          event.newPassword,
        );
        emit(UserProfileUpdateSuccess(user: event.user));
        emit(UserProfileLoadSuccess(user: event.user));

      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
        emit(UserProfileLoadSuccess(user: event.user));

      }
    });
    on<UpdateUserEmail>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        await _repository.updateUserEmail(event.user, event.newEmail , event.password);
        emit(UserProfileUpdateSuccess(user: event.user));
        emit(UserProfileLoadSuccess(user: event.user));
      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
        emit(UserProfileLoadSuccess(user: event.user));
      }
    });
  }

}