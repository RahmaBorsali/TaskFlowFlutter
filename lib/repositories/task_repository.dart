import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/enums.dart';
import '../core/services/hive_service.dart';

class TaskRepository {
  final _taskBox = HiveService.getBox<TaskModel>(HiveService.tasksBoxName);
  final _uuid = const Uuid();

  Future<void> createTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
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
