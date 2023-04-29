import 'package:equatable/equatable.dart';

abstract class UserContactEvent extends Equatable {
  const UserContactEvent();

  @override
  List<Object> get props => [];
}

class UserContactRequested extends UserContactEvent {
  final int user;

  const UserContactRequested({required this.user});
}

