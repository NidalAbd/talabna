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
}

class ServicePostLoadSuccess extends ServicePostState {
  final List<ServicePost> servicePosts;
  final bool hasReachedMax;
  final String event;

  const ServicePostLoadSuccess({required this.event, required this.servicePosts, this.hasReachedMax = false});

  ServicePostLoadSuccess copyWith({List<ServicePost>? servicePosts, bool? hasReachedMax, String? event}) {
    return ServicePostLoadSuccess(
      event: event ?? this.event,
      servicePosts: servicePosts ?? this.servicePosts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [event, servicePosts, hasReachedMax];
}



class ServicePostLoadFailure extends ServicePostState {
  final String errorMessage;
  final String event;
   const ServicePostLoadFailure({required this.event,required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class ServicePostOperationSuccess extends ServicePostState {
  final ServicePost? servicePost;
  final String event;

  const ServicePostOperationSuccess({required this.event, required this.servicePost});

  @override
  List<Object?> get props => [servicePost];
}

class ServicePostDeletingSuccess extends ServicePostState {
 final int servicePostId;
 const ServicePostDeletingSuccess({required this.servicePostId});

 @override
 List<Object?> get props => [servicePostId];
}
class ServicePostViewIncrementSuccess extends ServicePostState {
  final int servicePostId;
  const ServicePostViewIncrementSuccess({required this.servicePostId});

  @override
  List<Object?> get props => [servicePostId];
}

class ServicePostFavoriteInitialized extends ServicePostState {
  final bool isFavorite;
  final int servicePostId;

  const ServicePostFavoriteInitialized({required this.isFavorite, required this.servicePostId});

  @override
  List<Object?> get props => [isFavorite, servicePostId];
}

class ServicePostFavoriteToggled extends ServicePostState {
  final bool isFavorite;
  final int servicePostId;

  const ServicePostFavoriteToggled({required this.isFavorite, required this.servicePostId});

  @override
  List<Object?> get props => [isFavorite, servicePostId];
}


class ServicePostImageDeletingSuccess extends ServicePostState {
  final int servicePostImageId;
  const ServicePostImageDeletingSuccess({required this.servicePostImageId});

  @override
  List<Object?> get props => [servicePostImageId];
}
class ServicePostOperationFailure extends ServicePostState {
  final String errorMessage;
  final String event;

  const ServicePostOperationFailure({required this.event, required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
class ServicePostFormLoadSuccess extends ServicePostState {
  final ServicePost? servicePost;

  const ServicePostFormLoadSuccess({this.servicePost});

  @override
  List<Object?> get props => [servicePost];
}
