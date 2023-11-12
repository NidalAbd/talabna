import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/notifications.dart';

abstract class TalbnaNotificationState extends Equatable{
  const TalbnaNotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends TalbnaNotificationState {}

class NotificationLoading extends TalbnaNotificationState {}
class OneNotificationRead extends TalbnaNotificationState {
  final int notifications;

  const OneNotificationRead({required this.notifications});

  @override
  List<Object> get props => [notifications ];
}

class AllNotificationMarkedRead extends TalbnaNotificationState {}

class NotificationLoaded extends TalbnaNotificationState {
  final List<Notifications> notifications;
  final bool hasReachedMax;

   const NotificationLoaded({required this.notifications, this.hasReachedMax = false});

  @override
  List<Object> get props => [notifications, hasReachedMax];
}
class CountNotificationState extends TalbnaNotificationState {
  final int countNotification;

  const CountNotificationState({required this.countNotification,});

  @override
  List<Object> get props => [countNotification];
}

class NotificationError extends TalbnaNotificationState {
  final String message;
  const NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
class UserFollowerFollowingHasMaxReached extends TalbnaNotificationState {

}