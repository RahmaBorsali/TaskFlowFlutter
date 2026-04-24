import 'package:hive/hive.dart';
import 'enums.dart';

part 'project_model.g.dart';

@HiveType(typeId: 4)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final int colorValue;
  
  @HiveField(4)
  final ProjectStatus status;
  
  @HiveField(5)
  final List<String> memberIds;
  
  @HiveField(6)
  final String createdBy;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? deadline;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.status,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.deadline,
  });

  ProjectModel copyWith({
    String? name,
    String? description,
    int? colorValue,
    ProjectStatus? status,
    List<String>? memberIds,
    DateTime? deadline,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      status: status ?? this.status,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      colorValue: json['colorValue'] as int,
      status: ProjectStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ProjectStatus.active),
      memberIds: (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'status': status.name,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
    };
  }
}
