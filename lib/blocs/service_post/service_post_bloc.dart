
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';

class ServicePostBloc extends Bloc<ServicePostEvent, ServicePostState> {
  final ServicePostRepository servicePostRepository;

  ServicePostBloc({required this.servicePostRepository})
      : super(ServicePostInitial()) {
    // print('ServicePostBloc created: ${this.hashCode}');

    // Add a Set to store deleted post IDs
    on<GetAllServicePostsEvent>((event, emit) async {
      await for (var state in _mapGetAllServicePostsEventToState()) {
        emit(state);
      }
    });

    on<GetServicePostByIdEvent>((event, emit) async {
      await for (var state in _mapGetServicePostByIdEventToState(event.id)) {
        emit(state);
      }
    });
    on<LoadOldOrNewFormEvent>((event, emit) async {
      await for (var state in _mapLoadOldOrNewFormToState(event.servicePostId)) {
        emit(state);
      }
    });
    on<GetServicePostsByUserFavouriteEvent>((event, emit) async {
      await for (var state in _mapGetServicePostByFavouriteEventToState(event.userId, event.page)) {
        emit(state);
      }
    });
    on<GetServicePostsByCategoryEvent>((event, emit) async {
      await for (var state in _mapGetServicePostsByCategoryEventToState(event.category, event.page)) {
        emit(state);
      }
    });
    on<GetServicePostsRealsEvent>((event, emit) async {
      await for (var state in _mapGetServicePostsRealsEventToState( event.page)) {
        emit(state);
      }
    });
    on<GetServicePostsByCategorySubCategoryEvent>((event, emit) async {
      await for (var state in _mapGetServicePostsByCategorySubCategoryEventToState(event.category, event.subCategory, event.page)) {
        emit(state);
      }
    });
    on<GetServicePostsByUserIdEvent>((event, emit) async {
      await for (var state in _mapGetServicePostsByUserIdEventToState(event.userId, event.page)) {
        emit(state);
      }
    });
    on<CreateServicePostEvent>((event, emit) async {
      await for (var state in _mapCreateServicePostEventToState(event)) {
        emit(state);
      }
    });
    
    on<UpdateServicePostEvent>((event, emit) async {
      await for (var state in _mapUpdateServicePostEventToState(event)) {
        emit(state);
      }
    });
    on<UpdatePhotoServicePostEvent>((event, emit) async {
    await for (var state in _mapUpdatePhotoServicePostEventToState(event)) {
    emit(state);
    }
    });
    on<ServicePostCategoryUpdateEvent>((event, emit) async {
      await for (var state in _mapServicePostCategoryUpdateEventToState(event)) {
        emit(state);
      }
    });
    on<ServicePostBadgeUpdateEvent>((event, emit) async {
      await for (var state in _mapServicePostBadgeUpdateEventToState(event)) {
        emit(state);
      }
    });
    on<DeleteServicePostEvent>((event, emit) async {
      await for (var state in _mapDeleteServicePostEventToState(event.servicePostId)) {
        emit(state);
      }
    });
    on<ViewIncrementServicePostEvent>((event, emit) async {
      await for (var state in _mapViewIncrementServicePostEventToState(event.servicePostId)) {
        emit(state);
      }
    });
    on<ToggleFavoriteServicePostEvent>((event, emit) async {
      await for (var state in _mapToggleFavoriteServicePostEventToState(event.servicePostId)) {
        emit(state);
      }
    });
    on<InitializeFavoriteServicePostEvent>(
            (event, emit) async {
          await for (var state
          in _mapInitializeFavoriteServicePostEventToState(event.servicePostId)) {
            emit(state);
          }
        }
    );
    on<DeleteServicePostImageEvent>((event, emit) async {
    await for (var state in _mapDeleteServicePostImageEventToState(event.servicePostImageId)) {
    emit(state);
    }
    });
  }

  Stream<ServicePostState> _mapGetAllServicePostsEventToState() async* {
    yield const ServicePostLoading(event: 'GetAllServicePostsEvent' );
    if (state is ServicePostLoadSuccess && (state as ServicePostLoadSuccess).hasReachedMax) {
      return;
    }
    try {
      if (state is! ServicePostLoadSuccess) {
        final servicePosts = await servicePostRepository.getAllServicePosts();
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetAllServicePostsEvent');
        return;
      }
      final currentState = state as ServicePostLoadSuccess;
      final servicePosts = await servicePostRepository.getAllServicePosts();
      yield servicePosts.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : currentState.copyWith(
        servicePosts: currentState.servicePosts + servicePosts,
        hasReachedMax: false,
      );
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetAllServicePostsEvent');
    }
  }

  Stream<ServicePostState> _mapGetServicePostByIdEventToState(int id) async* {
    yield const ServicePostLoading(event: 'GetServicePostByIdEven');
    try {
      final ServicePost servicePost = await servicePostRepository.getServicePostById(id);
      yield ServicePostLoadSuccess(servicePosts: [servicePost], hasReachedMax: true, event: 'GetServicePostByIdEven');
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostByIdEven');
    }
  }


  Stream<ServicePostState> _mapGetServicePostsRealsEventToState(int page) async* {
    yield const ServicePostLoading(event: 'GetServicePostsByCategoryEvent');

    try {
      final currentState = state;
      if (currentState is ServicePostLoadSuccess && currentState.hasReachedMax) {
        // If we have reached the maximum, no need to fetch more posts.
        return;
      }

      // Fetch the service posts.
      final servicePosts = await servicePostRepository.getServicePostsForReals(page: page);
      final isLastPage = servicePosts.length < 3; // Assuming 3 is the number of posts per page set in the backend.

      if (currentState is! ServicePostLoadSuccess) {
        // If it's the first time loading posts.
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetServicePostsForReals');
      } else {
        // If we are appending new posts to the already loaded ones.
        yield servicePosts.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : currentState.copyWith(
          servicePosts: currentState.servicePosts + servicePosts,
          hasReachedMax: false,
        );
      }
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostsForReals');
    }
  }

  Stream<ServicePostState> _mapGetServicePostsByCategoryEventToState(
      int category, int page) async* {
    yield const ServicePostLoading(event: 'GetServicePostsByCategoryEvent');
    if (state is ServicePostLoadSuccess && (state as ServicePostLoadSuccess).hasReachedMax) {
      return;
    }
    try {
      if (state is! ServicePostLoadSuccess) {
        final servicePosts = await servicePostRepository.getServicePostsByCategory(page: page,categories: category);
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetServicePostsByCategoryEvent');
        return;
      }
      final currentState = state as ServicePostLoadSuccess;
      final servicePosts = await servicePostRepository.getServicePostsByCategory(page:page, categories:category);
      yield servicePosts.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : currentState.copyWith(
        servicePosts: currentState.servicePosts + servicePosts,
        hasReachedMax: false,
      );
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostsByCategoryEvent', );
    }
  }

  Stream<ServicePostState> _mapGetServicePostsByCategorySubCategoryEventToState(
      int category, int subCategory, int page) async* {
    yield const ServicePostLoading(event: 'GetServicePostsByCategorySubCategory');
    if (state is ServicePostLoadSuccess && (state as ServicePostLoadSuccess).hasReachedMax) {
      return;
    }
    try {
      if (state is! ServicePostLoadSuccess) {
        final servicePosts = await servicePostRepository.getServicePostsByCategorySubCategory(categories: category, subCategories: subCategory, page: page);
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetServicePostsByCategorySubCategory');
        return;
      }
      final currentState = state as ServicePostLoadSuccess;
      final servicePosts = await servicePostRepository.getServicePostsByCategorySubCategory(categories: category, subCategories: subCategory, page: page);
      yield servicePosts.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : currentState.copyWith(
        servicePosts: currentState.servicePosts + servicePosts,
        hasReachedMax: false,
      );
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostsByCategorySubCategory');
    }
  }
  Stream<ServicePostState> _mapGetServicePostsByUserIdEventToState(
      int userId, int page) async* {
    yield const ServicePostLoading(event: 'GetServicePostsByUserIdEvent');
    if (state is ServicePostLoadSuccess && (state as ServicePostLoadSuccess).hasReachedMax) {
      return;
    }
    try {
      if (state is! ServicePostLoadSuccess) {
        final servicePosts = await servicePostRepository.getServicePostsByUserId(page: page,userId: userId ,);
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetServicePostsByUserIdEvent');
        return;
      }
      final currentState = state as ServicePostLoadSuccess;
      final servicePosts = await servicePostRepository.getServicePostsByUserId(page: page,userId: userId ,);
      yield servicePosts.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : currentState.copyWith(
        servicePosts: currentState.servicePosts + servicePosts,
        hasReachedMax: false,
      );
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostsByUserIdEvent');
    }
  }
  Stream<ServicePostState> _mapGetServicePostByFavouriteEventToState(
      int userId, int page) async* {
    yield const ServicePostLoading(event: 'GetServicePostByFavouriteEvent');
    if (state is ServicePostLoadSuccess && (state as ServicePostLoadSuccess).hasReachedMax) {
      return;
    }
    try {
      if (state is! ServicePostLoadSuccess) {
        final servicePosts = await servicePostRepository.getServicePostsByUserFavourite(page: page,userId: userId ,);
        yield ServicePostLoadSuccess(servicePosts: servicePosts, hasReachedMax: servicePosts.length < 10, event: 'GetServicePostByFavouriteEvent');
        return;
      }
      final currentState = state as ServicePostLoadSuccess;
      final servicePosts = await servicePostRepository.getServicePostsByUserFavourite(page: page,userId: userId ,);
      yield servicePosts.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : currentState.copyWith(
        servicePosts: currentState.servicePosts + servicePosts,
        hasReachedMax: false,
      );
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'GetServicePostByFavouriteEvent');
    }
  }


  Stream<ServicePostState> _mapLoadOldOrNewFormToState([int? servicePostId]) async* {
    yield const ServicePostLoading(event: 'LoadOldOrNewForm');
    try {
      ServicePost? servicePost;
      if (servicePostId != null) {
        servicePost = await servicePostRepository.getServicePostById(servicePostId);
      }
      yield ServicePostFormLoadSuccess(servicePost: servicePost);
    } catch (e) {
      yield ServicePostLoadFailure(errorMessage: e.toString(), event: 'LoadOldOrNewForm');
    }
  }


  Stream<ServicePostState> _mapCreateServicePostEventToState(
      CreateServicePostEvent event) async* {
    yield const ServicePostLoading(event: 'CreateServicePostEvent');
    try {
      final newServicePost =
      await servicePostRepository.createServicePost(event.servicePost, event.imageFiles);
      yield ServicePostOperationSuccess( servicePost: newServicePost, event: 'CreateServicePostEvent');
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'LoadOldOrNewForm');
    }
  }
  Stream<ServicePostState> _mapServicePostCategoryUpdateEventToState(
      ServicePostCategoryUpdateEvent event) async* {
    yield const ServicePostLoading(event: 'ServicePostCategoryUpdateEvent');
    try {
      final newServicePost =
      await servicePostRepository.updateServicePostCategory(event.servicePost , event.servicePostID);
      yield ServicePostOperationSuccess( servicePost: newServicePost, event: 'ServicePostCategoryUpdateEvent');
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'ServicePostCategoryUpdateEvent');
    }
  }
  Stream<ServicePostState> _mapServicePostBadgeUpdateEventToState(
      ServicePostBadgeUpdateEvent event) async* {
    yield const ServicePostLoading(event: 'ServicePostBadgeUpdateEvent');
    try {
      final newServicePost =
      await servicePostRepository.updateServicePostBadge(event.servicePost , event.servicePostID);
      yield ServicePostOperationSuccess( servicePost: newServicePost, event: 'ServicePostBadgeUpdateEvent');
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'ServicePostBadgeUpdateEvent');
    }
  }
  Stream<ServicePostState> _mapUpdateServicePostEventToState(
      UpdateServicePostEvent event) async* {
    yield const ServicePostLoading(event: 'UpdateServicePostEvent');
    try {
      final updatedServicePost =
      await servicePostRepository.updateServicePost(event.servicePost , event.imageFiles);
      yield ServicePostOperationSuccess( servicePost: updatedServicePost, event: 'UpdateServicePostEvent');
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'UpdateServicePostEvent');
    }
  }
  Stream<ServicePostState> _mapUpdatePhotoServicePostEventToState(
      UpdatePhotoServicePostEvent event) async* {
    yield const ServicePostLoading(event: 'UpdateServicePostEvent');
    try {
      bool updatedServicePost = await servicePostRepository.updateServicePostImage(event.imageFiles, servicePostImageId: event.servicePost );
      yield ServicePostImageUpdatingSuccess(imageUpdated: updatedServicePost);
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'UpdateServicePostEvent');
    }
  }
  Stream<ServicePostState> _mapDeleteServicePostEventToState(int id) async* {
    yield const ServicePostLoading(event: 'DeleteServicePostEvent');
    try {
      await servicePostRepository.deleteServicePost(servicePostId: id);
      yield ServicePostDeletingSuccess(servicePostId: id);
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'DeleteServicePostEvent');
    }
  }
  Stream<ServicePostState> _mapViewIncrementServicePostEventToState(int id) async* {
    yield const ServicePostLoading(event: 'ViewIncrementServicePostEvent');
    try {
      await servicePostRepository.viewIncrementServicePost(servicePostId: id);
      yield ServicePostViewIncrementSuccess(servicePostId: id);
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'ViewIncrementServicePostEvent');
    }
  }
  Stream<ServicePostState> _mapToggleFavoriteServicePostEventToState(int id) async* {
    yield const ServicePostLoading(event: 'ToggleFavoriteServicePostEvent');
    try {
      bool newFavoriteStatus = await servicePostRepository.toggleFavoriteServicePost(servicePostId: id);
      yield ServicePostFavoriteToggled(servicePostId: id, isFavorite: newFavoriteStatus);
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'ToggleFavoriteServicePostEvent');
    }
  }
  Stream<ServicePostState> _mapInitializeFavoriteServicePostEventToState(
      int servicePostId) async* {
    try {
      bool isFavorite = await servicePostRepository.getFavourite(servicePostId: servicePostId);
      yield ServicePostFavoriteInitialized(servicePostId: servicePostId, isFavorite: isFavorite);
    } catch (e) {
      // Handle the error
    }
  }

  Stream<ServicePostState> _mapDeleteServicePostImageEventToState(int id) async* {
    yield const ServicePostLoading(event: 'DeleteServicePostImageEvent');
    try {
      await servicePostRepository.deleteServicePostImage(servicePostImageId: id);
      yield ServicePostImageDeletingSuccess(servicePostImageId: id);
    } catch (e) {
      yield ServicePostOperationFailure(errorMessage: e.toString(), event: 'DeleteServicePostImageEvent');
    }
  }
}