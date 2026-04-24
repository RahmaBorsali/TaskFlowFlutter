import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/enums.dart';
import '../core/services/hive_service.dart';
import '../core/services/api_sync_service.dart';

class ProjectRepository {
  final _projectBox = HiveService.getBox<ProjectModel>(HiveService.projectsBoxName);
  final _uuid = const Uuid();

  Future<void> createProject(ProjectModel project) async {
    await _projectBox.put(project.id, project);
    ApiSyncService.syncDataWithCloud();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projectBox.put(project.id, project);
    ApiSyncService.syncDataWithCloud();
  }

  Future<void> deleteProject(String id) async {
    await _projectBox.delete(id);
    
    // Add to sync deletion queue
    final settingsBox = HiveService.getBox(HiveService.settingsBoxName);
    List<dynamic> dynamicDeletedIds = settingsBox.get(HiveService.deletedProjectIdsKey, defaultValue: []);
    List<String> deletedIds = dynamicDeletedIds.cast<String>();
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      await settingsBox.put(HiveService.deletedProjectIdsKey, deletedIds);
    }
    
    ApiSyncService.syncDataWithCloud();
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
