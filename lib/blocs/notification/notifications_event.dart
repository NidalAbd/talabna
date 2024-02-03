
import 'package:equatable/equatable.dart';

abstract class talabnaNotificationEvent  extends Equatable {
  const talabnaNotificationEvent();
  @override
  List<Object> get props => [];
}

class FetchNotifications extends talabnaNotificationEvent {
  final int userId;
  final int page;

  const FetchNotifications({required this.userId, this.page = 1});
}

class MarkNotificationAsRead extends talabnaNotificationEvent {
  final int notificationId;
  final int userId;

  const MarkNotificationAsRead({required this.userId, required this.notificationId});
}
class MarkALlNotificationAsRead extends talabnaNotificationEvent {
  final int userId;
  const MarkALlNotificationAsRead({required this.userId});
}
class CountNotificationEvent extends talabnaNotificationEvent {
  final int userId;

  const CountNotificationEvent({required this.userId,});
}