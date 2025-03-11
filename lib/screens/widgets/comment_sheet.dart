import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/comments/comment_bloc.dart';
import 'package:talbna/blocs/comments/comment_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/comment.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/user_avatar_profile.dart';

import '../../blocs/comments/comment_event.dart';
import '../../provider/language.dart';
import '../../utils/constants.dart';

class CommentModalBottomSheet extends StatefulWidget {
  final double iconSize;
  final User user;
  final UserProfileBloc userProfileBloc;
  final CommentBloc commentBloc;
  final ServicePost? servicePost;
  final bool showCountOnRight; // New parameter to control count position
  final bool showCount; // New parameter to control if count is shown
  final Color? iconColor; // Allow customizing icon color

  const CommentModalBottomSheet({
    super.key,
    required this.iconSize,
    required this.userProfileBloc,
    required this.commentBloc,
    required this.servicePost,
    required this.user,
    this.showCountOnRight = false, // By default, count is shown as a badge
    this.showCount = true, // By default, show the count
    this.iconColor,
  });

  @override
  State<CommentModalBottomSheet> createState() => _CommentModalBottomSheetState();
}

class _CommentModalBottomSheetState extends State<CommentModalBottomSheet> {
  final Language _language = Language();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isDeleting = false;
  bool _isAdding = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _commentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _commentController.removeListener(_onTextChanged);
    _scrollController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // This will trigger a rebuild when text changes to update the send button
  void _onTextChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (!widget.commentBloc.isFetching &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final currentState = widget.commentBloc.state;
      if (currentState is CommentLoadSuccessState && currentState.hasMore) {
        widget.commentBloc.add(
          LoadMoreCommentsEvent(
            postId: widget.servicePost!.id!,
            page: currentState.comments.length ~/ 10 + 1,
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      final newComment = Comments(
        content: text,
        userId: widget.user.id,
        servicePostId: widget.servicePost!.id!,
        user: widget.user,
      );

      widget.commentBloc.add(AddCommentEvent(
        comment: newComment,
        page: _page,
      ));

      _commentController.clear();

      // Auto-scroll to see the new comment
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteComment(int commentId, Comments comment) async {
    setState(() => _isDeleting = true);

    try {
      widget.commentBloc.add(DeleteCommentEvent(
        commentId: commentId,
        page: _page,
        comment: comment,
      ));
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  // Build horizontal layout with count on right
  Widget _buildHorizontalLayout() {
    final commentsCount = widget.servicePost?.commentsCount ?? 0;

    return GestureDetector(
      onTap: _showCommentsBottomSheet,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.comment,
            size: widget.iconSize,
            color: widget.iconColor ?? Colors.white,
          ),
          if (widget.showCount && commentsCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(commentsCount),
              style: TextStyle(
                color: widget.iconColor ?? Colors.white,
                fontSize: widget.iconSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build vertical layout with count below
  Widget _buildVerticalLayout() {
    final commentsCount = widget.servicePost?.commentsCount ?? 0;

    return GestureDetector(
      onTap: _showCommentsBottomSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.comment,
            size: widget.iconSize,
            color: widget.iconColor ?? Colors.white,
          ),
          if (widget.showCount && commentsCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(commentsCount),
              style: TextStyle(
                color: widget.iconColor ?? Colors.white,
                fontSize: widget.iconSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build badge style (original implementation)
  Widget _buildBadgeStyle() {
    final commentsCount = widget.servicePost?.commentsCount ?? 0;

    return IconButton(
      onPressed: _showCommentsBottomSheet,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.comment,
            size: widget.iconSize,
            color: widget.iconColor ?? Colors.white,
          ),

          // Comment count badge
          if (widget.showCount && commentsCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _formatCount(commentsCount),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      bloc: widget.userProfileBloc,
      listener: (context, state) {
        // You can use this listener to react to specific state changes
      },
      child: widget.showCountOnRight
          ? _buildHorizontalLayout()
          : _buildVerticalLayout(),
    );
  }

  void _showCommentsBottomSheet() {
    // Always load fresh comments when opening the sheet
    if (widget.servicePost != null) {
      widget.commentBloc.add(LoadCommentsEvent(
        postId: widget.servicePost!.id!,
        page: _page,
      ));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,     // Enable tap-to-dismiss
      enableDrag: true,        // Enable drag-to-dismiss
      builder: (context) => GestureDetector(
        // This prevents taps outside the content area from being ignored
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            // This prevents taps inside the sheet from dismissing it
            onTap: () {
              // Don't propagate the tap event
              FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside text field
            },
            behavior: HitTestBehavior.opaque,
            child: _buildCommentsSheetContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSheetContent(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.7, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkPrimaryColor
                : AppTheme.lightPrimaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              _buildSheetHeader(),

              // Comments List - Expanded to take available space
              Expanded(
                child: BlocBuilder<CommentBloc, CommentState>(
                  bloc: widget.commentBloc,
                  builder: (context, state) {
                    return _buildCommentsList(state);
                  },
                ),
              ),

              // Input box - Automatically sits above keyboard
              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            margin: const EdgeInsets.only(bottom: 10),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 40),
              Text(
                _language.getCommentsText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Close button
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(maxWidth: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(CommentState state) {
    if (state is CommentLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is CommentErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Failed to load comments. Please try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.servicePost != null) {
                  widget.commentBloc.add(LoadCommentsEvent(
                    postId: widget.servicePost!.id!,
                    page: _page,
                  ));
                }
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else if (state is CommentLoadSuccessState) {
      final comments = state.comments;

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: comments.length + (widget.commentBloc.isFetching ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == comments.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildCommentItem(comments[index]);
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildCommentItem(Comments comment) {
    final isMyComment = comment.userId == widget.user.id;
    final timeAgo = _formatTimeAgo(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatarProfile(
            imageUrl: comment.user.photos?.isNotEmpty == true
                ? '${Constants.apiBaseUrl}/${comment.user.photos?.first.src}'
                : '',
            radius: 20,
            toUser: comment.user.id,
            canViewProfile: true,
            fromUser: comment.user.id,
            user: widget.user,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.user.name ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timeAgo != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isMyComment
                        ? Colors.blue.withOpacity(0.1)
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isMyComment)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _deleteComment(comment.id!, comment),
                      icon: _isDeleting
                          ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Icon(Icons.delete_outline, size: 16),
                      label: Text(
                        'Delete',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      // Use padding that accounts for the keyboard
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 16.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom for multi-line input
        children: [
          UserAvatarProfile(
            imageUrl: widget.user.photos?.isNotEmpty == true
                ? '${Constants.apiBaseUrl}/${widget.user.photos?.first.src}'
                : '',
            radius: 16,
            toUser: widget.user.id,
            canViewProfile: false,
            fromUser: widget.user.id,
            user: widget.user,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      maxLines: 4, // Allow multiple lines but with a limit
                      minLines: 1,
                      style: TextStyle(fontSize: 14),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) {
                        if (_commentController.text.trim().isNotEmpty) {
                          _addComment();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    constraints: BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: _isAdding
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(
                      Icons.send_rounded,
                      color: _commentController.text.trim().isEmpty
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: _isAdding || _commentController.text.trim().isEmpty
                        ? null
                        : _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}