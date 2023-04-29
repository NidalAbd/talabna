class Category {
  late int id;
  late String name;
  Category({required this.id, required this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
class SubCategory {
  late int id;
  late String name;
  late int categoryId;
  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryId = json['categories_id'];
  }
}

