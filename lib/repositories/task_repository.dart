import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/enums.dart';
import '../core/services/hive_service.dart';
import '../core/services/api_sync_service.dart';

class TaskRepository {
  final _taskBox = HiveService.getBox<TaskModel>(HiveService.tasksBoxName);
  final _uuid = const Uuid();

  Future<void> createTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
    ApiSyncService.syncDataWithCloud(); // Non-blocking sync
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
    ApiSyncService.syncDataWithCloud();
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    
    // Add to sync deletion queue
    final settingsBox = HiveService.getBox(HiveService.settingsBoxName);
    List<dynamic> dynamicDeletedIds = settingsBox.get(HiveService.deletedTaskIdsKey, defaultValue: []);
    List<String> deletedIds = dynamicDeletedIds.cast<String>();
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      await settingsBox.put(HiveService.deletedTaskIdsKey, deletedIds);
    }
    
    ApiSyncService.syncDataWithCloud();
  }

  TaskModel? getTask(String id) {
    return _taskBox.get(id);
  }

  List<TaskModel> getAllTasks() {
    return _taskBox.values.toList();
  }

  List<TaskModel> getTasksByProject(String projectId) {
    return _taskBox.values.where((t) => t.projectId == projectId).toList();
  }

  List<TaskModel> getTasksByUser(String userId) {
    return _taskBox.values.where((t) => t.assignedTo == userId || t.createdBy == userId).toList();
  }

  String generateId() => _uuid.v4();
}
