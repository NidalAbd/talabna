import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/photos.dart';

abstract class ServicePostEvent extends Equatable {
  const ServicePostEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCachesEvent extends ServicePostEvent {
  const InitializeCachesEvent();
}

class GetServicePostsByCategoryEvent extends ServicePostEvent {
  final int category;
  final int page;
  final bool forceRefresh;

  const GetServicePostsByCategoryEvent(
      this.category,
      this.page, {
        this.forceRefresh = false,
      });

  @override
  List<Object> get props => [category, page, forceRefresh];
}

class GetAllServicePostsEvent extends ServicePostEvent {
  const GetAllServicePostsEvent();
}

class GetServicePostByIdEvent extends ServicePostEvent {
  final int id;
  final bool forceRefresh;

  const GetServicePostByIdEvent(this.id, {this.forceRefresh = false});

  @override
  List<Object> get props => [id, forceRefresh];
}

class LoadOldOrNewFormEvent extends ServicePostEvent {
  final int? servicePostId;

  const LoadOldOrNewFormEvent({this.servicePostId});

  @override
  List<Object?> get props => [servicePostId];
}

class GetServicePostsByUserFavouriteEvent extends ServicePostEvent {
  final int userId;
  final int page;
  final bool forceRefresh;

  const GetServicePostsByUserFavouriteEvent({
    required this.userId,
    required this.page,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [userId, page, forceRefresh];
}

class GetServicePostsRealsEvent extends ServicePostEvent {
  final int page;
  final bool forceRefresh;

  const GetServicePostsRealsEvent({
    required this.page,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [page, forceRefresh];
}

class GetServicePostsByCategorySubCategoryEvent extends ServicePostEvent {
  final int category;
  final int subCategory;
  final int page;
  final bool forceRefresh;

  const GetServicePostsByCategorySubCategoryEvent({
    required this.category,
    required this.subCategory,
    required this.page,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [category, subCategory, page, forceRefresh];
}

class GetServicePostsByUserIdEvent extends ServicePostEvent {
  final int userId;
  final int page;
  final bool forceRefresh;

  const GetServicePostsByUserIdEvent({
    required this.userId,
    required this.page,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [userId, page, forceRefresh];
}

class CreateServicePostEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final List<MultipartFile> imageFiles;

  const CreateServicePostEvent({
    required this.servicePost,
    required this.imageFiles,
  });

  @override
  List<Object> get props => [servicePost, imageFiles];
}

class UpdateServicePostEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final List<MultipartFile> imageFiles;

  const UpdateServicePostEvent({
    required this.servicePost,required this.imageFiles,
  });

  @override
  List<Object> get props => [servicePost];
}

class UpdatePhotoServicePostEvent extends ServicePostEvent {
  final int servicePost;
  final List<MultipartFile> imageFiles;

  const UpdatePhotoServicePostEvent({
    required this.servicePost,
    required this.imageFiles,
  });

  @override
  List<Object> get props => [servicePost, imageFiles];
}

class ServicePostCategoryUpdateEvent extends ServicePostEvent {
  final int servicePostID;
  final ServicePost servicePost;

  const ServicePostCategoryUpdateEvent({
    required this.servicePostID,
    required this.servicePost,
  });

  @override
  List<Object> get props => [servicePostID, servicePost];
}

class ServicePostBadgeUpdateEvent extends ServicePostEvent {
  final int servicePostID;
  final ServicePost servicePost;

  const ServicePostBadgeUpdateEvent({
    required this.servicePostID,
    required this.servicePost,
  });

  @override
  List<Object> get props => [servicePostID, servicePost];
}

class DeleteServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const DeleteServicePostEvent({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class ViewIncrementServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const ViewIncrementServicePostEvent({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class ToggleFavoriteServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const ToggleFavoriteServicePostEvent({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class InitializeFavoriteServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const InitializeFavoriteServicePostEvent({
    required this.servicePostId,
  });

  @override
  List<Object> get props => [servicePostId];
}

class DeleteServicePostImageEvent extends ServicePostEvent {
  final int servicePostImageId;

  const DeleteServicePostImageEvent({
    required this.servicePostImageId,
  });

  @override
  List<Object> get props => [servicePostImageId];
}

class ClearServicePostCacheEvent extends ServicePostEvent {
  final int? categoryId;
  final int? subcategoryId;
  final int? userId;
  final int? postId;

  const ClearServicePostCacheEvent({
    this.categoryId,
    this.subcategoryId,
    this.userId,
    this.postId,
  });

  @override
  List<Object?> get props => [categoryId, subcategoryId, userId, postId];
}