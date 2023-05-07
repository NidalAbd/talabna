import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/data/models/notifications.dart';
import 'package:talbna/data/repositories/notification_repository.dart';

import 'notifications_event.dart';
import 'notifications_state.dart';

class TalbnaNotificationBloc
    extends Bloc<TalbnaNotificationEvent, TalbnaNotificationState> {
  final NotificationRepository notificationRepository;

  TalbnaNotificationBloc({required this.notificationRepository})
      : super(NotificationInitial()) {
    on<FetchNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notifications = await notificationRepository.getUserNotifications(userId: event.userId , page: event.page);
        bool hasReachedMax = notifications.length < 10; // Assuming 10 is the maximum number of items you fetch in one request
        emit(NotificationLoaded(notifications: notifications , hasReachedMax: hasReachedMax));
      } catch (e) {
        emit(NotificationError(message: e.toString()));
      }
    });
    on<MarkNotificationAsRead>((event, emit) async {
      emit(NotificationLoading());
      try {
        await notificationRepository.markNotificationAsRead(
            notificationId: event.notificationId, userId: event.userId);
      } catch (e) {
        emit(NotificationError(message: e.toString()));
      }
    });
    on<CountNotificationEvent>((event, emit) async {
      emit(NotificationLoading());
      try {
       final countNotification  =  await notificationRepository.countNotification(userId: event.userId);
        emit(CountNotificationState(countNotification: countNotification));
      } catch (e) {
        emit(NotificationError(message: e.toString()));
      }
    });
  }
}
