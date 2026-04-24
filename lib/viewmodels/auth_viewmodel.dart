import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(this._authRepository) {
    _currentUser = _authRepository.getCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Identifiants incorrects';
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password, int avatarColor) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.register(name, email, password, avatarColor);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<UserModel> getAllUsers() {
    return _authRepository.getAllUsers();
  }

  UserModel? getUserById(String? id) {
    if (id == null) return null;
    try {
      return _authRepository.getAllUsers().firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
