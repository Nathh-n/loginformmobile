class UserModel {
  final int id;
  final String email;
  final String name;
  final String avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}