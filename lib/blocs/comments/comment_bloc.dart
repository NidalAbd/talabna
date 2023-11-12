import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/data/repositories/comment_repository.dart'; // Import your Comment repository

import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository; // Replace with your repository
  bool isFetching = false; // Add this line

  CommentBloc({required this.commentRepository}) : super(CommentInitialState()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<LoadMoreCommentsEvent>(_onLoadMoreComments);
    on<AddCommentEvent>(_onAddComment);
    on<UpdateCommentEvent>(_onUpdateComment);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<CommentState> emit) async {
    if (isFetching) return; // Prevent fetching if an operation is already in progress
    isFetching = true; // Set the flag to true when fetching starts
    emit(CommentLoadingState());
    try {
      final comments = await commentRepository.fetchComments(postId: event.postId, page: event.page);
      emit(CommentLoadSuccessState(comments));
      isFetching = false; // Set the flag to false when fetching is done
    } catch (e) {
      emit(CommentErrorState("Failed to load comments: $e"));
      isFetching = false; // Set the flag to false if fetching fails
    }
  }

  Future<void> _onLoadMoreComments(LoadMoreCommentsEvent event, Emitter<CommentState> emit) async {
    if (isFetching) return;
    isFetching = true;
    if (state is CommentLoadSuccessState && (state as CommentLoadSuccessState).hasMore) {
      try {
        final newComments = await commentRepository.fetchComments(postId: event.postId, page: event.page);
        final currentState = state as CommentLoadSuccessState;
        final allComments = currentState.comments + newComments;
        final hasMore = newComments.isNotEmpty; // or determine based on the API response if there are more pages
        emit(CommentLoadSuccessState(allComments, hasMore: hasMore));
        isFetching = false;

      } catch (e) {
        emit(CommentErrorState("Failed to load more comments: $e"));
        isFetching = false;

      }
    }

  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.addComment(event.comment, event.page);
      final comments = await commentRepository.fetchComments(  postId: event.comment.servicePostId, page: event.page,);
      emit(CommentLoadSuccessState(comments));
    } catch (e) {
      emit(CommentErrorState("Failed to add comment: $e"));
    }
  }

  Future<void> _onUpdateComment(UpdateCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.updateComment(event.comment, event.page);
      final comments = await commentRepository.fetchComments(  postId: event.comment.servicePostId, page: event.page,);
      emit(CommentLoadSuccessState(comments));
    } catch (e) {
      emit(CommentErrorState("Failed to update comment: $e"));
    }
  }

  Future<void> _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.deleteComment(event.commentId);
      final comments = await commentRepository.fetchComments(  postId: event.comment.servicePostId, page: event.page,);
      emit(CommentLoadSuccessState(comments));
    } catch (e) {
      emit(CommentErrorState("Failed to delete comment: $e"));
    }
  }
}
