import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/user.dart';

abstract class UserContactState extends Equatable {
  const UserContactState();

  @override
  List<Object> get props => [];
}

class UserContactInitial extends UserContactState {}

class UserContactLoadInProgress extends UserContactState {}

class UserContactLoadSuccess extends UserContactState {
  final User user;

  const UserContactLoadSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class UserContactLoadFailure extends UserContactState{
  final String error;
  const UserContactLoadFailure({ required this.error});
  @override
  List<Object> get props => [error];
}



