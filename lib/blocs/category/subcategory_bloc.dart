import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'subcategory_event.dart';
import 'subcategory_state.dart';

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  final CategoriesRepository categoriesRepository;
  SubcategoryBloc({required this.categoriesRepository}) : super(SubcategoryInitial()) {
    print('SubcategoryBloc created: $hashCode');

    on<FetchSubcategories>((event, emit) async {
      emit(SubcategoryLoading());
      try {
        final List<SubCategoryMenu> subcategories = await categoriesRepository.getSubCategoriesMenu(event.categoryId);
        emit(SubcategoryLoaded(subcategories));
      } catch (e) {
        emit(SubcategoryError(e.toString()));
      }
    });
    on<FetchCategories>((event, emit) async {
      emit(SubcategoryLoading());
      try {
        final List<CategoryMenu> subcategories = await categoriesRepository.getCategoryMenu();
        emit( CategoryLoaded(subcategories));
      } catch (e) {
        emit(SubcategoryError(e.toString()));
      }
    });

  }
}
