import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/notification/notifications_event.dart';
import 'package:talbna/blocs/notification/notifications_state.dart';

import 'package:talbna/data/models/notifications.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  late ScrollController _scrollController;
  late TalbnaNotificationBloc _talbnaNotificationBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<Notifications> _notification = [];

  @override
  void initState() {
    super.initState();
    _talbnaNotificationBloc = BlocProvider.of<TalbnaNotificationBloc>(context);
    _talbnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }
  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      _talbnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _notification.clear();
    _talbnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
  }

  void _handleNotificationsLoadSuccess(
      List<Notifications> notifications, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _notification = [..._notification, ...notifications];
    });
  }
  Future<bool> _onWillPop() async {
    if (_scrollController.offset > 0) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleRefresh();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocListener<TalbnaNotificationBloc, TalbnaNotificationState>(
          bloc: _talbnaNotificationBloc,
          listener: (context, state) {
            if (state is NotificationLoaded) {
              _handleNotificationsLoadSuccess(state.notifications, state.hasReachedMax);
            }
          },
          child: BlocBuilder<TalbnaNotificationBloc, TalbnaNotificationState>(
            bloc: _talbnaNotificationBloc,
            builder: (context, state) {
              if (state is NotificationLoading && _notification.isEmpty) {
                // show loading indicator
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (_notification.isNotEmpty) {
                // show list of service posts
                return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      controller: _scrollController, // add this line
                      itemCount: _hasReachedMax
                          ? _notification.length
                          : _notification.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= _notification.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final notification = _notification[index];
                        return Card(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? (notification.read
                              ? AppTheme.lightForegroundColor: AppTheme.lightForegroundColor.withOpacity(0.3))
                              : (notification.read
                              ? AppTheme.darkForegroundColor:AppTheme.darkForegroundColor.withOpacity(0.3)),
                        child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.lightForegroundColor,
                            radius: 25,
                            child: Icon(
                              _notification[index].getIconData(),
                              color: _notification[index].getIconColor(),
                              size: 30,
                              semanticLabel: _notification[index].type,
                            ),
                          ),
                          title: Text(notification.message),
                          subtitle: Text(DateFormat('yyyy-MM-dd | HH:mm:ss').format(notification.createdAt)),
                          trailing: notification.read
                              ? null
                              :  const Icon(Icons.fiber_new,),
                          onTap: () {
                            BlocProvider.of<TalbnaNotificationBloc>(context)
                                .add(
                              MarkNotificationAsRead(
                                notificationId: notification.id,
                                userId: widget.userID,
                              ),
                            );
                            setState(() {

                            });
                          },
                        ),
                        ),
                        );
                      },
                    )

                );
              } else if (state is NotificationError) {
// show error message
                return Center(
                  child: Text(state.message),
                );
              } else {
// show empty state
                return const Center(
                  child: Text('No Notifications found.'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

