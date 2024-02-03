import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/notifications.dart';

abstract class talabnaNotificationState extends Equatable{
  const talabnaNotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends talabnaNotificationState {}

class NotificationLoading extends talabnaNotificationState {}
class OneNotificationRead extends talabnaNotificationState {
  final int notifications;

  const OneNotificationRead({required this.notifications});

  @override
  List<Object> get props => [notifications ];
}

class AllNotificationMarkedRead extends talabnaNotificationState {}

class NotificationLoaded extends talabnaNotificationState {
  final List<Notifications> notifications;
  final bool hasReachedMax;

   const NotificationLoaded({required this.notifications, this.hasReachedMax = false});

  @override
  List<Object> get props => [notifications, hasReachedMax];
}
class CountNotificationState extends talabnaNotificationState {
  final int countNotification;

  const CountNotificationState({required this.countNotification,});

  @override
  List<Object> get props => [countNotification];
}

class NotificationError extends talabnaNotificationState {
  final String message;
  const NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
class UserFollowerFollowingHasMaxReached extends talabnaNotificationState {

}