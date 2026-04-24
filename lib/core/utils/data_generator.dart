import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../models/enums.dart';
import '../../core/services/hive_service.dart';
import '../../core/constants/app_colors.dart';

class DataGenerator {
  static Future<void> generateDemoData() async {
    final userBox = HiveService.getBox<UserModel>(HiveService.usersBoxName);
    final projectBox = HiveService.getBox<ProjectModel>(HiveService.projectsBoxName);
    final taskBox = HiveService.getBox<TaskModel>(HiveService.tasksBoxName);

  }
}
