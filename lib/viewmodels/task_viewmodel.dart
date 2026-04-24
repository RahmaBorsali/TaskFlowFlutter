import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/enums.dart';
import '../repositories/task_repository.dart';
import '../core/services/notification_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _loadedForUserId;
  
  // Filter settings
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String _searchQuery = '';

  TaskViewModel(this._taskRepository);

  List<TaskModel> get tasks {
    return _tasks.where((task) {
      final matchesStatus = _statusFilter == null || task.status == _statusFilter;
      final matchesPriority = _priorityFilter == null || task.priority == _priorityFilter;
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesPriority && matchesSearch;
    }).toList();
  }

  bool get isLoading => _isLoading;

  void loadTasks(String userId) {
    // Ne recharger depuis Hive que si c'est un nouvel utilisateur
    if (_loadedForUserId == userId) return;
    _loadedForUserId = userId;

    _isLoading = true;
    notifyListeners();
    
    _tasks = _taskRepository.getTasksByUser(userId);
    _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    _isLoading = false;
    notifyListeners();
  }

  /// Réinitialiser lors du logout
  void clear() {
    _tasks = [];
    _loadedForUserId = null;
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> createTask(TaskModel task) async {
    await _taskRepository.createTask(task);
    _tasks.insert(0, task);
    _scheduleNotification(task);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskRepository.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _scheduleNotification(task);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setFilters({TaskStatus? status, TaskPriority? priority, String? search, bool clearStatus = false}) {
    if (clearStatus) {
      _statusFilter = null;
    } else if (status != null) {
      _statusFilter = status;
    }
    
    if (priority != null) _priorityFilter = priority;
    if (search != null) _searchQuery = search;
    
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.status == TaskStatus.done).length;
  int get inProgressTasksCount => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get todoTasksCount => _tasks.where((t) => t.status == TaskStatus.todo).length;
  
  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / _tasks.length;
  }

  void _scheduleNotification(TaskModel task) {
    if (task.dueDate == null) return;
    
    // Si la tâche est terminée, on ne planifie pas de notification
    if (task.status == TaskStatus.done) return;

    // Calculer l'heure de la notification (5 minutes avant la deadline)
    final notifyTime = task.dueDate!.subtract(const Duration(minutes: 5));
    
    // Si l'heure est déjà passée, on ne planifie rien
    if (notifyTime.isBefore(DateTime.now())) return;

    NotificationService.scheduleNotification(
      id: task.id.hashCode,
      title: 'Tâche urgente !',
      body: 'La tâche "${task.title}" arrive à échéance dans 5 minutes.',
      scheduledDate: notifyTime,
    );
  }
}
