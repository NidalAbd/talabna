// lib/data/datasources/service_post_data_source.dart
import 'package:talbna/data/models/service_post.dart';

abstract class ServicePostDataSource {
  Future<List<ServicePost>> getServicePostsByCategory({required int categories, required int page});
  Future<ServicePost> getServicePostById(int id);
// Add other methods as needed
}