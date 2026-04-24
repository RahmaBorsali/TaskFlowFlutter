import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String password; // In a real app, this would be hashed or handled by Auth service
  
  @HiveField(4)
  final int avatarColorValue;
  
  @HiveField(5)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatarColorValue,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    int? avatarColorValue,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      avatarColorValue: json['avatarColorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'avatarColorValue': avatarColorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
