class ProductModel {
  final int id;
  final String title;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? [];

    String imageUrl = images.isNotEmpty ? images.first.toString() : '';
    // Beberapa data lama formatnya rusak, contoh: "[\"https://...\"]"
    // (string yang isinya kayak array JSON). Ini bersihin karakter sisanya.
    imageUrl = imageUrl
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '');

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '-',
      imageUrl: imageUrl,
    );
  }
}