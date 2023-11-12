import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/comment.dart';

abstract class CommentState extends Equatable  {

  @override
  List<Object> get props => [];
}

class CommentInitialState extends CommentState {
}

class CommentLoadingState extends CommentState {}

class CommentLoadSuccessState extends CommentState {
  final List<Comments> comments;
  final bool hasMore;

  CommentLoadSuccessState(this.comments, {this.hasMore = true});

  @override
  List<Object> get props => [comments, hasMore];
}


class CommentErrorState extends CommentState {
   final String error;

    CommentErrorState(this.error);

   @override
   List<Object> get props => [error];
}