class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
