import 'package:talbna/data/models/comment.dart';

// Events
abstract class CommentEvent {}

class LoadCommentsEvent extends CommentEvent {
  final int postId;
  final int page;

  LoadCommentsEvent({required this.postId, required this.page});
}

class AddCommentEvent extends CommentEvent {
  final Comments comment;
  final int page;

  AddCommentEvent({required this.comment, required this.page});
}

class LoadMoreCommentsEvent extends CommentEvent {
  final int postId;
  final int page;

  LoadMoreCommentsEvent({required this.postId, required this.page});
}


class UpdateCommentEvent extends CommentEvent {
  final Comments comment;
  final int page;

  UpdateCommentEvent({required this.comment, required this.page});
}

class DeleteCommentEvent extends CommentEvent {
  final int commentId;
  final Comments comment;

  final int page;

  DeleteCommentEvent( {required this.commentId, required this.page,required this.comment,});
}
