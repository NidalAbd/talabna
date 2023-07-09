import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:http/http.dart' as http;

abstract class ServicePostEvent extends Equatable {
  const ServicePostEvent();
  @override
  List<Object?> get props => []; // Change return type to List<Object?>
}

class GetAllServicePostsEvent extends ServicePostEvent {}

class GetServicePostByIdEvent extends ServicePostEvent {
  final int id;
  const GetServicePostByIdEvent({required this.id});
  @override
  List<Object> get props => [id];
}
class GetServicePostsByCategoryEvent extends ServicePostEvent {
  final int category;
  final int page;
  const GetServicePostsByCategoryEvent(this.category, this.page);
  @override
  List<Object> get props => [category];
}
class GetServicePostsRealsEvent extends ServicePostEvent {
  final int page;
  const GetServicePostsRealsEvent( this.page);
  @override
  List<Object> get props => [page];
}
class GetServicePostsByCategorySubCategoryEvent extends ServicePostEvent {
  final int category;
  final int subCategory;
  final int page;
  const GetServicePostsByCategorySubCategoryEvent(this.category, this.subCategory, this.page);
  @override
  List<Object> get props => [category, subCategory];
}
class GetServicePostsByUserIdEvent extends ServicePostEvent {
  final int userId;
  final int page;
  const GetServicePostsByUserIdEvent(this.userId, this.page);
  @override
  List<Object> get props => [userId];
}

class GetServicePostsByUserFavouriteEvent extends ServicePostEvent {
  final int userId;
  final int page;
  const GetServicePostsByUserFavouriteEvent(this.userId, this.page);
  @override
  List<Object> get props => [userId];
}

class CreateServicePostEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final List<http.MultipartFile> imageFiles;
  const CreateServicePostEvent(this.servicePost, this.imageFiles);
  @override
  List<Object> get props => [servicePost, imageFiles];
}
class UpdateServicePostEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final List<http.MultipartFile> imageFiles;
  const UpdateServicePostEvent(this.servicePost, this.imageFiles);
  @override
  List<Object> get props => [servicePost, imageFiles];
}

class UpdatePhotoServicePostEvent extends ServicePostEvent {
  final int servicePost;
  final List<http.MultipartFile> imageFiles;
  const UpdatePhotoServicePostEvent(this.servicePost, this.imageFiles);
  @override
  List<Object> get props => [servicePost, imageFiles];
}

class DeleteServicePostEvent extends ServicePostEvent {
  final int servicePostId;
  const DeleteServicePostEvent({required this.servicePostId});

  @override
  List<Object> get props => [servicePostId];
}
class ViewIncrementServicePostEvent extends ServicePostEvent {
  final int servicePostId;
  const ViewIncrementServicePostEvent({required this.servicePostId});

  @override
  List<Object> get props => [servicePostId];
}
class ToggleFavoriteServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const ToggleFavoriteServicePostEvent({required this.servicePostId});

  @override
  List<Object?> get props => [servicePostId];
}
class InitializeFavoriteServicePostEvent extends ServicePostEvent {
  final int servicePostId;

  const InitializeFavoriteServicePostEvent({required this.servicePostId});

  @override
  List<Object?> get props => [servicePostId];
}

class DeleteServicePostImageEvent extends ServicePostEvent {
  final int servicePostImageId;
  const DeleteServicePostImageEvent({required this.servicePostImageId});

  @override
  List<Object> get props => [servicePostImageId];
}
class LoadOldOrNewFormEvent extends ServicePostEvent {
  final int? servicePostId;

  const LoadOldOrNewFormEvent({this.servicePostId});

  @override
  List<Object?> get props => [servicePostId];
}
class ServicePostBadgeUpdateEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final int servicePostID;

  const ServicePostBadgeUpdateEvent(this.servicePost, this.servicePostID);

  @override
  List<Object?> get props => [servicePost];
}
class ServicePostCategoryUpdateEvent extends ServicePostEvent {
  final ServicePost servicePost;
  final int servicePostID;
  const ServicePostCategoryUpdateEvent(this.servicePost, this.servicePostID);

  @override
  List<Object?> get props => [servicePost , servicePostID];
}