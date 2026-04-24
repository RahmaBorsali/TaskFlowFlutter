import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/enums.dart';
import '../repositories/project_repository.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _projectRepository;
  
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _loadedForUserId;
  ProjectStatus? _statusFilter;

  List<ProjectModel> get projects {
    if (_statusFilter == null) return _projects;
    return _projects.where((p) => p.status == _statusFilter).toList();
  }
  
  bool get isLoading => _isLoading;

  ProjectViewModel(this._projectRepository);

  void setFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void loadProjects(String userId) {
    // Ne recharger depuis Hive que si c'est un nouvel utilisateur
    if (_loadedForUserId == userId) {
      debugPrint('📦 loadProjects SKIPPED (already loaded for $userId). _projects has ${_projects.length} items');
      return;
    }
    _loadedForUserId = userId;
    
    _isLoading = true;
    notifyListeners();
    
    _projects = _projectRepository.getProjectsByUser(userId);
    _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    debugPrint('📦 loadProjects LOADED for $userId: ${_projects.length} projects from Hive');
    
    _isLoading = false;
    notifyListeners();
  }

  /// Réinitialiser lors du logout
  void clear() {
    _projects = [];
    _loadedForUserId = null;
    notifyListeners();
  }

  Future<void> createProject(ProjectModel project) async {
    await _projectRepository.createProject(project);
    _projects.insert(0, project);
    debugPrint('✅ createProject: project "${project.name}" added. _projects now has ${_projects.length} items');
    notifyListeners();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projectRepository.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    await _projectRepository.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
