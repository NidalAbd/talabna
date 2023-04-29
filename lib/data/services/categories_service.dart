import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/repositories/categories_repository.dart';

class CategoriesService {
  final CategoriesRepository _repository;

  CategoriesService({required CategoriesRepository repository})
      : _repository = repository;

  Future<List<Category>> getCategories() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      rethrow;
    }
  }

}
