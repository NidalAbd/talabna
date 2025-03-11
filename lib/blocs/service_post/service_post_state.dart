import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/service_post.dart';

abstract class ServicePostState extends Equatable {
  const ServicePostState();

  @override
  List<Object?> get props => [];
}

class ServicePostInitial extends ServicePostState {}

class ServicePostLoading extends ServicePostState {
  final String event;

  const ServicePostLoading({required this.event});

  @override
  List<Object> get props => [event];
}

class ServicePostCachesInitialized extends ServicePostState {
  const ServicePostCachesInitialized();
}

class ServicePostLoadSuccess extends ServicePostState {
  final List<ServicePost> servicePosts;
  final bool hasReachedMax;
  final String event;

  const ServicePostLoadSuccess({
    required this.servicePosts,
    required this.hasReachedMax,
    required this.event,
  });

  ServicePostLoadSuccess copyWith({
    List<ServicePost>? servicePosts,
    bool? hasReachedMax,
  }) {
    return ServicePostLoadSuccess(
      servicePosts: servicePosts ?? this.servicePosts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      event: this.event,
    );
  }

  @override
  List<Object> get props => [servicePosts, hasReachedMax, event];
}

class ServicePostFormLoadSuccess extends ServicePostState {
  final ServicePost? servicePost;

  const ServicePostFormLoadSuccess({this.servicePost});

  @override
  List<Object?> get props => [servicePost];
}

class ServicePostLoadFailure extends ServicePostState {
  final String errorMessage;
  final String event;

  const ServicePostLoadFailure({
    required this.errorMessage,
    required this.event,
  });

  @override
  List<Object> get props => [errorMessage, event];
}

class ServicePostOperationSuccess extends ServicePostState {
  final bool servicePost;
  final String event;

  const ServicePostOperationSuccess({
    required this.servicePost,
    required this.event,
  });

  @override
  List<Object> get props => [servicePost, event];
}

class ServicePostOperationFailure extends ServicePostState {
  final String errorMessage;
  final String event;

  const ServicePostOperationFailure({
    required this.errorMessage,
    required this.event,
  });

  @override
  List<Object> get props => [errorMessage, event];
}

class ServicePostDeletingSuccess extends ServicePostState {
  final int servicePostId;

  const ServicePostDeletingSuccess({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class ServicePostFavoriteToggled extends ServicePostState {
  final int servicePostId;
  final bool isFavorite;

  const ServicePostFavoriteToggled({
    required this.servicePostId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [servicePostId, isFavorite];
}

class ServicePostFavoriteInitialized extends ServicePostState {
  final int servicePostId;
  final bool isFavorite;

  const ServicePostFavoriteInitialized({
    required this.servicePostId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [servicePostId, isFavorite];
}

class ServicePostViewIncrementSuccess extends ServicePostState {
  final int servicePostId;

  const ServicePostViewIncrementSuccess({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class ServicePostImageUpdatingSuccess extends ServicePostState {
  final bool imageUpdated;

  const ServicePostImageUpdatingSuccess({
    required this.imageUpdated,
  });

  @override
  List<Object> get props => [imageUpdated];
}

class ServicePostImageDeletingSuccess extends ServicePostState {
  final int servicePostImageId;

  const ServicePostImageDeletingSuccess({
    required this.servicePostImageId,
  });

  @override
  List<Object> get props => [servicePostImageId];
}

class ServicePostCacheCleared extends ServicePostState {
  const ServicePostCacheCleared();
}