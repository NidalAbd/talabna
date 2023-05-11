import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/screens/interaction_widget/report_tile.dart';
import 'package:talbna/screens/service_post/change_badge.dart';
import 'package:talbna/screens/service_post/change_category_subcategory.dart';
import 'package:talbna/screens/service_post/update_service_post_form.dart';

class ServicePostAction extends StatefulWidget {
  const ServicePostAction({
    Key? key,
    required this.servicePostUserId,
    this.userProfileId,
    this.servicePostId,
    required this.onPostDeleted,
  }) : super(key: key);
  final int? servicePostUserId;
  final int? servicePostId;
  final int? userProfileId;
  final Function onPostDeleted;
  @override
  State<ServicePostAction> createState() => _ServicePostActionState();
}

class _ServicePostActionState extends State<ServicePostAction>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void _deletePost(BuildContext context) async {
    BlocProvider.of<ServicePostBloc>(context)
        .add(DeleteServicePostEvent(servicePostId: widget.servicePostId!));
    // Add a listener to check for successful deletion
    StreamSubscription<ServicePostState>? listenerSubscription;
    listenerSubscription =
        context.read<ServicePostBloc>().stream.listen((state) {
      if (state is ServicePostDeletingSuccess) {
        listenerSubscription?.cancel(); // Cancel the subscription
        if (mounted) {
          widget.onPostDeleted(
              widget.servicePostId!); // Pass the servicePostId here
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicePostBloc, ServicePostState>(
      listenWhen: (previous, current) {
        return current is ServicePostDeletingSuccess &&
            current.servicePostId == widget.servicePostId;
      },
      listener: (context, state) {
        if (state is ServicePostDeletingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service Post Operation Success'),
            ),
          );
          setState(() {});
          widget.onPostDeleted(state
              .servicePostId); // Add the ! to ensure a non-nullable value is passed
        } else if (state is ServicePostOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Service Post Operation Error: ${state.errorMessage}'),
            ),
          );
        }
      },
      child: BlocBuilder<ServicePostBloc, ServicePostState>(
          builder: (context, state) {
        return IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Wrap(
                  children: [
                    if (widget.userProfileId == widget.servicePostUserId)
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit'),
                        onTap: () {
                          Navigator.pop(context); // Dismiss the bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UpdatePostScreen(
                                userId: widget.userProfileId!,
                                servicePostId: widget.servicePostId!,
                              ),
                            ),
                          );
                        },
                      ),
                    if (widget.userProfileId == widget.servicePostUserId)
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text('Change Category'),
                        onTap: () {
                          Navigator.pop(context); // Dismiss the bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChangeCategoryScreen(
                                    userId: widget.userProfileId!,
                                    servicePostId: widget.servicePostId!)),
                          );
                        },
                      ),
                    if (widget.userProfileId == widget.servicePostUserId)
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('Make Badge'),
                        onTap: () {
                          Navigator.pop(context); // Dismiss the bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChangeBadge(
                                    userId: widget.userProfileId!,
                                    servicePostId: widget.servicePostId!)),
                          );
                        },
                      ),
                    if (widget.userProfileId == widget.servicePostUserId)
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
                        onTap: () async {
                          bool? result = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text(
                                  'Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          if (result == true) {
                            _deletePost(context);
                          }
                          Navigator.pop(context); // Dismiss the bottom sheet
                        },
                      ),
                    ListTile(
                        leading: const Icon(Icons.report),
                        title: const Text('Report'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return ReportTile(
                                  type: 'service_post',
                                  userId: widget.servicePostId!,
                                );
                              });
                        })
                  ],
                );
              },
            );
          },
        );
      }),
    );
  }
}
