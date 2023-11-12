import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/notification/notifications_event.dart';
import 'package:talbna/blocs/notification/notifications_state.dart';

import 'notification_screen.dart';

class NotificationsAlert extends StatefulWidget {
  const NotificationsAlert({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  State<NotificationsAlert> createState() => _NotificationsAlertState();
}

class _NotificationsAlertState extends State<NotificationsAlert> {
  late TalbnaNotificationBloc _talbnaNotificationBloc;

  @override
  void initState() {
    super.initState();
    _talbnaNotificationBloc = BlocProvider.of<TalbnaNotificationBloc>(context);
    _talbnaNotificationBloc.add(CountNotificationEvent(userId: widget.userID));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TalbnaNotificationBloc, TalbnaNotificationState>(
      bloc: _talbnaNotificationBloc,
      builder: (context, state) {
        late int countNotifications = 0;
        bool haveUnreadNotification = false;
        if (state is CountNotificationState) {
          countNotifications = state.countNotification;
          if(countNotifications > 0){
            haveUnreadNotification = true;
          }else{
            haveUnreadNotification = false;
          }
        }
        return Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(userID: widget.userID),
                  ),
                );
              },
              icon: haveUnreadNotification
                  ? Stack(
                children: [
                  const Icon(Icons.notifications),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        countNotifications.toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
                  : const Icon(Icons.notifications),
            );
          }
        );
      },
    );
  }
}
