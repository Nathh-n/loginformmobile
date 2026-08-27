class UploadResult {
  final String url;
  final String deleteUrl;
  final int sizeInBytes;

  UploadResult({
    required this.url,
    required this.deleteUrl,
    required this.sizeInBytes,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UploadResult(
      url: data['display_url'] ?? data['url'] ?? '',
      deleteUrl: data['delete_url'] ?? '',
      sizeInBytes: data['size'] ?? 0,
    );
  }
}