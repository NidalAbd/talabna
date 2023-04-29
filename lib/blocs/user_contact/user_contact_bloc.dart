import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_event.dart';
import 'package:talbna/blocs/user_contact/user_contact_state.dart';
import 'package:talbna/data/repositories/user_contact_repository.dart';


class UserContactBloc extends Bloc<UserContactEvent, UserContactState> {
  final UserContactRepository _repository;

  UserContactBloc({required UserContactRepository repository})
      : _repository = repository,
        super(UserContactInitial()) {
    on<UserContactRequested>((event, emit) async {
      emit(UserContactLoadInProgress());
      try {
        final users = await _repository.getUserProfileById(id : event.user);
        emit(UserContactLoadSuccess(user: users));
      } catch (e) {
        emit(UserContactLoadFailure(error: e.toString()));
      }
    });

  }

}