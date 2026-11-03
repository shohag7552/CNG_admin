/// Example model — one row in the `items` table. Copy this file as the
/// starting point for a real model; keys are the Appwrite column names.
class ItemModel {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;

  const ItemModel({
    required this.id,
    required this.title,
    this.description = '',
    this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json['\$id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        createdAt: DateTime.tryParse(json['\$createdAt'] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  ItemModel copyWith({String? title, String? description}) => ItemModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt,
      );
}
