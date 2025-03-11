import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/repositories/user_profile_repository.dart';

import '../../data/models/user.dart';
import '../../screens/profile/profile_completion_service.dart';


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
    print('UserProfileBloc created: $hashCode');

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
// Add this helper method to your UserProfileBloc class
    Future<bool> _checkProfileCompleteness(User user) async {
      // Check if all required fields are filled
      final bool hasPhones = user.phones != null && user.phones!.isNotEmpty;
      final bool hasWhatsApp = user.watsNumber != null && user.watsNumber!.isNotEmpty;
      final bool hasGender = user.gender != null && user.gender!.isNotEmpty;
      final bool hasDate = user.dateOfBirth != null;
      final bool hasCountry = user.country != null;
      final bool hasCity = user.city != null;

      // Check if all required fields are complete
      return hasPhones && hasWhatsApp && hasGender && hasDate && hasCountry && hasCity;
    }
    on<UserProfileUpdated>((event, emit) async {
      emit(const UserProfileUpdateInProgress());
      try {
        // Pass context to the repository if available for localization
        final user = await repository.updateUserProfile(event.user, event.context);
        emit(UserProfileUpdateSuccess(user: user));
        final isProfileComplete = await _checkProfileCompleteness(user);

        // Add profile completion logic here
        // Check if profile is complete using the validation logic

        // Get the ProfileCompletionService
        final profileCompletionService = ProfileCompletionService();

        // Update the profile completion status
        await profileCompletionService.setProfileComplete(isProfileComplete);

        // Notify listeners
        await profileCompletionService.updateProfileCompletionStatus();

        print('UserProfileBloc: Profile updated, completion status: $isProfileComplete');

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