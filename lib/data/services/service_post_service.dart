import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:http/http.dart' as http;

class ServicePostService {
  final ServicePostRepository _repository = ServicePostRepository();

  Future<List<ServicePost>> getAllServicePosts() async {
    return await _repository.getAllServicePosts();
  }

  Future<ServicePost> getServicePostById(int id) async {
    return await _repository.getServicePostById(id);
  }

  Future<List<ServicePost>> getUserServicePosts(int userId, int page) async {
    return await _repository.getServicePostsByUserId(userId: userId, page: page);
  }

  Future<List<ServicePost>> getServicePostsByCategory(
      int category, int page) async {
    return await _repository.getServicePostsByCategory(categories: category, page: page);
  }

  Future<List<ServicePost>> getServicePostsByCategorySubCategory(
      int category, int subCategory , int page) async {
    return await _repository.getServicePostsByCategorySubCategory( page: page, categories: category, subCategories: subCategory);
  }




}
