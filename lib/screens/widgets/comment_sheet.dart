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

  const CommentModalBottomSheet({
    super.key,
    required this.iconSize,
    required this.userProfileBloc,
    required this.commentBloc,
    required this.servicePost,
    required this.user,
  });

  @override
  State<CommentModalBottomSheet> createState() =>
      _CommentModalBottomSheetState();
}

class _CommentModalBottomSheetState extends State<CommentModalBottomSheet> {
  final Language _language = Language();
  final ScrollController _scrollController = ScrollController();
  bool isDeleting = false;
  bool isAdding = false;
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _commentController = TextEditingController();
  int page = 1; // Initialize the page

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.servicePost != null) {
      widget.commentBloc
          .add(LoadCommentsEvent(postId: widget.servicePost!.id!, page: page));
    }
  }

  void _onScroll() {
    final commentBloc = BlocProvider.of<CommentBloc>(context);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !commentBloc.isFetching) {
      final currentState = commentBloc.state;
      if (currentState is CommentLoadSuccessState && currentState.hasMore) {
        commentBloc.add(
          LoadMoreCommentsEvent(
              postId: widget.servicePost!.id!,
              page: currentState.comments.length ~/ 10 + 1),
        );
      }
    }
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        isAdding = true;
      });
      final newComment = Comments(
        content: _commentController.text,
        userId: widget.user.id,
        servicePostId: widget.servicePost!.id!,
        user: widget.user,
      );
      widget.commentBloc.add(AddCommentEvent(
          comment: newComment,
          page: page)); // Assuming this is an async operation
      _commentController.clear();
      setState(() {
        isAdding = false;
      });
    }
  }

  void _deleteComment(int commentId, Comments comment) async {
    setState(() {
      isDeleting = true;
    });
    widget.commentBloc.add(DeleteCommentEvent(
        commentId: commentId,
        page: page,
        comment: comment)); // Assuming this is an async operation
    setState(() {
      isDeleting = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose(); // This should be at the end
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      bloc: widget.userProfileBloc,
      listener: (context, state) {
        // You can use this listener to react to specific state changes
      },
      child: IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: BlocBuilder<CommentBloc, CommentState>(
                    bloc: widget.commentBloc,
                    builder: (context, state) {
                      if (state is CommentLoadSuccessState) {
                        return _buildCommentsSheet(context, state.comments,
                            widget.commentBloc.isFetching);
                      } else if (state is CommentInitialState) {
                        widget.commentBloc.add(LoadCommentsEvent(
                            postId: widget.servicePost!.id!, page: page));
                        return const Center(child: Text('Loading . .'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        icon: Icon(
          Icons.comment,
          size: widget.iconSize,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(1),
              offset: const Offset(0, 0),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSheet(
      BuildContext context, List<Comments> comments, bool isFetchingMore) {
    return Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkPrimaryColor
          : AppTheme.lightPrimaryColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _language.getCommentsText(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: comments.isEmpty
                ? const Center(
                    child: Text(
                        "No comments available."), // Display a message when no comments are available
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: comments.length + (isFetchingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= comments.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final comment = comments[index];
                      return _buildCommentItem(context, comment);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildAddCommentSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Comments comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatarProfile(
            imageUrl: '${Constants.apiBaseUrl}/storage/${comment.user.photos?.first.src}',
            radius: 20,
            toUser: comment.user.id,
            canViewProfile: false,
            fromUser: comment.user.id,
            user: widget.user,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.user.name!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (comment.userId == widget.user.id) ...[
                      isDeleting
                          ? const CircularProgressIndicator()
                          : IconButton(
                              onPressed: () =>
                                  _deleteComment(comment.id!, comment),
                              icon: const Icon(Icons.delete),
                            ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                      focusNode: _focusNode,
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onTap: () {
                        Future.delayed(Duration(milliseconds: 300), () {
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent);
                        });
                      }),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: isAdding
                        ? null
                        : _addComment, // Disable the button while adding
                    icon: isAdding
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.lightPrimaryColor
                                    : AppTheme.darkPrimaryColor,
                          ),
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
