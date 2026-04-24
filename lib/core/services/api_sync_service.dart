import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'hive_service.dart';
import '../../models/task_model.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';

class ApiSyncService {
  static final ApiService _apiService = ApiService();

  static Future<bool> syncDataWithCloud() async {
    debugPrint('🔄 Début de la synchronisation avec l\'API REST...');
    
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('⚠️ Pas de connexion Internet. Synchronisation annulée.');
        return false;
      }

      await _syncTasks();
      await _syncProjects();
      await _syncUsers();

      debugPrint('✅ Synchronisation API réussie.');
      return true;
    } catch (e) {
      debugPrint('❌ Échec de la synchronisation: $e');
      return false;
    }
  }

  static Future<void> _syncTasks() async {
    final taskBox = HiveService.getBox<TaskModel>(HiveService.tasksBoxName);
    final settingsBox = HiveService.getBox(HiveService.settingsBoxName);
    
    // 0. Process deletion queue
    List<dynamic> dynamicDeletedIds = settingsBox.get(HiveService.deletedTaskIdsKey, defaultValue: []);
    List<String> deletedIds = dynamicDeletedIds.cast<String>();
    for (String id in deletedIds) {
      try {
        await _apiService.delete('tasks', id);
      } catch (_) {}
    }
    await settingsBox.put(HiveService.deletedTaskIdsKey, <String>[]);

    // 1. Fetch remote tasks
    List<dynamic> remoteData = [];
    try {
      remoteData = await _apiService.get('tasks');
    } catch (_) {
      // API may be empty or unreachable, continue
    }
    
    final Map<String, dynamic> remoteTasksMap = {
      for (var item in remoteData) item['id']: item
    };

    // 2. Push local tasks to server
    for (var task in taskBox.values) {
      if (remoteTasksMap.containsKey(task.id)) {
        // Update server if local is newer
        final remoteTask = TaskModel.fromJson(remoteTasksMap[task.id]);
        if (task.updatedAt.isAfter(remoteTask.updatedAt)) {
          await _apiService.put('tasks', task.id, task.toJson());
        }
      } else {
        // Create on server
        await _apiService.post('tasks', task.toJson());
      }
    }

    // 3. Fetch remote again and update local
    final finalRemoteData = await _apiService.get('tasks');
    for (var item in finalRemoteData) {
      final remoteTask = TaskModel.fromJson(item as Map<String, dynamic>);
      await taskBox.put(remoteTask.id, remoteTask);
    }
  }

  static Future<void> _syncProjects() async {
    final projectBox = HiveService.getBox<ProjectModel>(HiveService.projectsBoxName);
    final settingsBox = HiveService.getBox(HiveService.settingsBoxName);
    
    // 0. Process deletion queue
    List<dynamic> dynamicDeletedIds = settingsBox.get(HiveService.deletedProjectIdsKey, defaultValue: []);
    List<String> deletedIds = dynamicDeletedIds.cast<String>();
    for (String id in deletedIds) {
      try {
        await _apiService.delete('projects', id);
      } catch (_) {}
    }
    await settingsBox.put(HiveService.deletedProjectIdsKey, <String>[]);

    List<dynamic> remoteData = [];
    try {
      remoteData = await _apiService.get('projects');
    } catch (_) {}
    
    final Map<String, dynamic> remoteProjectsMap = {
      for (var item in remoteData) item['id']: item
    };

    for (var project in projectBox.values) {
      if (remoteProjectsMap.containsKey(project.id)) {
        // Here we just overwrite for simplicity, or we could check a timestamp if ProjectModel had updatedAt
        await _apiService.put('projects', project.id, project.toJson());
      } else {
        await _apiService.post('projects', project.toJson());
      }
    }

    final finalRemoteData = await _apiService.get('projects');
    for (var item in finalRemoteData) {
      final remoteProject = ProjectModel.fromJson(item as Map<String, dynamic>);
      await projectBox.put(remoteProject.id, remoteProject);
    }
  }

  static Future<void> _syncUsers() async {
    final userBox = HiveService.getBox<UserModel>(HiveService.usersBoxName);
    
    List<dynamic> remoteData = [];
    try {
      remoteData = await _apiService.get('users');
    } catch (_) {}
    
    final Map<String, dynamic> remoteUsersMap = {
      for (var item in remoteData) item['id']: item
    };

    for (var user in userBox.values) {
      if (remoteUsersMap.containsKey(user.id)) {
        await _apiService.put('users', user.id, user.toJson());
      } else {
        await _apiService.post('users', user.toJson());
      }
    }

    final finalRemoteData = await _apiService.get('users');
    for (var item in finalRemoteData) {
      final remoteUser = UserModel.fromJson(item as Map<String, dynamic>);
      await userBox.put(remoteUser.id, remoteUser);
    }
  }
}
