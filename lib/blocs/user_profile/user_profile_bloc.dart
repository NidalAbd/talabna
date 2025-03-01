import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/repositories/user_profile_repository.dart';


class UniqueConstraintException implements Exception {
  final String message;
  final String? field;

  UniqueConstraintException({required this.message, this.field});

  @override
  String toString() => message;
}

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository repository;

  UserProfileBloc({required this.repository})
      : super(UserProfileInitial()) {
    print('UserProfileBloc created: ${this.hashCode}');

    on<UserProfileRequested>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        final userProfile = await repository.getUserProfileById(event.id);
        emit(UserProfileLoadSuccess(user: userProfile));
      } catch (e) {
        emit(UserProfileLoadFailure(error: e.toString()));
      }
    });

    on<UserProfileContactRequested>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        final userProfile = await repository.getUserProfileById(event.id);
        emit(UserProfileLoadContactSuccess(user: userProfile));
      } catch (e) {
        emit(UserProfileLoadFailure(error: e.toString()));
      }
    });

    on<UserProfileUpdated>((event, emit) async {
      emit(const UserProfileUpdateInProgress());
      try {
        // Pass context to the repository if available for localization
        final user = await repository.updateUserProfile(event.user, event.context);
        emit(UserProfileUpdateSuccess(user: user));
      } catch (e) {
        // Check if this is a unique constraint violation
        if (e is UniqueConstraintException) {
          emit(UserProfileUniqueConstraintFailure(
            error: e.message,
            field: e.field,
          ));
        } else {
          emit(UserProfileUpdateFailure(error: e.toString()));
        }
      }
    });

    on<UpdateUserProfilePhoto>((event, emit) async {
      emit(const UserProfileUpdateInProgress());
      try {
        await repository.updateUserProfilePhoto(event.user, event.photo);
        emit(UserProfileUpdateSuccess(user: event.user));
      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
      }
    });

    on<UpdateUserPassword>((event, emit) async {
      emit(UserProfileLoadInProgress());
      try {
        await repository.updateUserPassword(
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
        await repository.updateUserEmail(event.user, event.newEmail, event.password);
        emit(UserProfileUpdateSuccess(user: event.user));
        emit(UserProfileLoadSuccess(user: event.user));
      } catch (e) {
        emit(UserProfileUpdateFailure(error: e.toString()));
        emit(UserProfileLoadSuccess(user: event.user));
      }
    });
  }
}