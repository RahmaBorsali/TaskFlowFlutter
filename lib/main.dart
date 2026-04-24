import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/theme/theme_provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/project_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'core/services/notification_service.dart';
import 'core/utils/data_generator.dart';
import 'repositories/auth_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/project_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await HiveService.init();
  await NotificationService.init();
  
  // Generate Demo Data
  await DataGenerator.generateDemoData();

  // Initialize Repositories
  final authRepository = AuthRepository();
  final taskRepository = TaskRepository();
  final projectRepository = ProjectRepository();

  runApp(
    MultiProvider(
      providers: [
        // Repository Providers (Optional, but good for DI)
        Provider.value(value: authRepository),
        Provider.value(value: taskRepository),
        Provider.value(value: projectRepository),
        
        // Theme & Settings
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        
        // Feature ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => TaskViewModel(taskRepository)),
        ChangeNotifierProvider(create: (_) => ProjectViewModel(projectRepository)),
      ],
      child: const TaskFlowApp(),
    ),
  );
}
