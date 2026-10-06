class CategoryModel {
  final String value;
  final String name;

  CategoryModel({
    required this.value,
    required this.name,
  });

  @override
  String toString() => name;
}