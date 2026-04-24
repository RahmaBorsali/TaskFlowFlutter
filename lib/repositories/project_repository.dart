import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/enums.dart';
import '../core/services/hive_service.dart';

class ProjectRepository {
  final _projectBox = HiveService.getBox<ProjectModel>(HiveService.projectsBoxName);
  final _uuid = const Uuid();

  Future<void> createProject(ProjectModel project) async {
    await _projectBox.put(project.id, project);
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projectBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await _projectBox.delete(id);
  }

  ProjectModel? getProject(String id) {
    return _projectBox.get(id);
  }

  List<ProjectModel> getAllProjects() {
    return _projectBox.values.toList();
  }

  List<ProjectModel> getProjectsByUser(String userId) {
    return _projectBox.values.where((p) => p.memberIds.contains(userId)).toList();
  }

  String generateId() => _uuid.v4();
}
