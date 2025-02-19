import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/notification/notifications_event.dart';
import 'package:talbna/blocs/notification/notifications_state.dart';

import 'package:talbna/data/models/notifications.dart';

import '../../main.dart';
import '../../provider/language.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  late ScrollController _scrollController;
  late talabnaNotificationBloc _talabnaNotificationBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<Notifications> _notification = [];
  final Language _language = Language();

  @override
  void initState() {
    super.initState();
    _talabnaNotificationBloc = BlocProvider.of<talabnaNotificationBloc>(context);
    _talabnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }
  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      _talabnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _notification.clear();
    _talabnaNotificationBloc.add(FetchNotifications(page: _currentPage , userId: widget.userID,));
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
        title:  Text(_language.getNotificationText()),
        actions: [
          IconButton(onPressed: (){
            BlocProvider.of<talabnaNotificationBloc>(context)
                .add(
              MarkALlNotificationAsRead(
                userId: widget.userID,
              ),
            );
            setState(() {
            });
          }, icon: const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Icon(Icons.mark_email_read_rounded),
          )),
        ],
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocListener<talabnaNotificationBloc, talabnaNotificationState>(
          bloc: _talabnaNotificationBloc,
          listener: (context, state) {
            if (state is NotificationLoaded) {
              _handleNotificationsLoadSuccess(state.notifications, state.hasReachedMax);
            }
            else if (state is AllNotificationMarkedRead) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All Notification Marked Read'),
                ),
              );
            }
          },
          child: BlocBuilder<talabnaNotificationBloc, talabnaNotificationState>(
            bloc: _talabnaNotificationBloc,
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
                        child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            child: Icon(
                              _notification[index].getIconData(),
                              color: _notification[index].getIconColor(),
                              size: 30,
                              semanticLabel: _notification[index].type,
                            ),
                          ),
                          title: Text(notification.getMessage(language)),
                          subtitle: Text(DateFormat('yyyy-MM-dd | HH:mm:ss').format(notification.createdAt)),
                          trailing: notification.read
                              ? null
                              :  const Icon(Icons.fiber_new,),
                          onTap: () {
                            BlocProvider.of<talabnaNotificationBloc>(context)
                                .add(
                              MarkNotificationAsRead(
                                notificationId: notification.id,
                                userId: widget.userID,
                              ),
                            );
                          },
                        ),
                        ),
                        );
                      },
                    )

                );
              } else if (state is NotificationError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
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

