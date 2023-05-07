
import 'package:equatable/equatable.dart';

abstract class TalbnaNotificationEvent  extends Equatable {
  const TalbnaNotificationEvent();
  @override
  List<Object> get props => [];
}

class FetchNotifications extends TalbnaNotificationEvent {
  final int userId;
  final int page;

  const FetchNotifications({required this.userId, this.page = 1});
}

class MarkNotificationAsRead extends TalbnaNotificationEvent {
  final int notificationId;
  final int userId;

  const MarkNotificationAsRead({required this.userId, required this.notificationId});
}
class CountNotificationEvent extends TalbnaNotificationEvent {
  final int userId;

  const CountNotificationEvent({required this.userId,});
}