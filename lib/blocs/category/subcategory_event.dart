import 'package:equatable/equatable.dart';

abstract class SubcategoryEvent extends Equatable {
  const SubcategoryEvent();

  @override
  List<Object> get props => [];
}

class FetchSubcategories extends SubcategoryEvent {
  final int categoryId;

  const FetchSubcategories({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}


