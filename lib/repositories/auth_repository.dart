import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../core/services/hive_service.dart';

class AuthRepository {
  final _userBox = HiveService.getBox<UserModel>(HiveService.usersBoxName);
  final _settingsBox = HiveService.getBox(HiveService.settingsBoxName);
  final _uuid = const Uuid();

  static const String _currentUserKey = 'currentUser';

  Future<UserModel?> login(String email, String password) async {
    try {
      final user = _userBox.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      await _settingsBox.put(_currentUserKey, user.id);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> register(String name, String email, String password, int avatarColor) async {
    if (_userBox.values.any((u) => u.email == email)) {
      throw Exception('User already exists');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      password: password,
      avatarColorValue: avatarColor,
      createdAt: DateTime.now(),
    );

    await _userBox.put(user.id, user);
    await _settingsBox.put(_currentUserKey, user.id);
    return user;
  }

  Future<void> logout() async {
    await _settingsBox.delete(_currentUserKey);
  }

  UserModel? getCurrentUser() {
    final userId = _settingsBox.get(_currentUserKey);
    if (userId == null) return null;
    return _userBox.get(userId);
  }

  List<UserModel> getAllUsers() {
    return _userBox.values.toList();
  }
}
