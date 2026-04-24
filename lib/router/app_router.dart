import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_screen.dart';
import '../views/tasks/tasks_screen.dart';
import '../views/projects/projects_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/shared/main_layout.dart';
import '../views/tasks/add_edit_task_screen.dart';
import '../views/projects/add_edit_project_screen.dart';
import '../views/tasks/task_details_screen.dart';
import '../views/projects/project_details_screen.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _instance;

  static GoRouter router(BuildContext context) {
    if (_instance != null) return _instance!;

    final authViewModel = context.read<AuthViewModel>();

    _instance = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isAuthPath = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!isAuthenticated) {
          return isAuthPath ? null : '/login';
        }

        if (isAuthenticated && isAuthPath) {
          return '/';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main App with Shell Navigation (Bottom Nav)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
            ),
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // Modal/Deep Routes
        GoRoute(
          path: '/add-task',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditTaskScreen(),
        ),
        GoRoute(
          path: '/edit-task',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final task = state.extra as TaskModel?;
            return AddEditTaskScreen(task: task);
          },
        ),
        GoRoute(
          path: '/add-project',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditProjectScreen(),
        ),
        GoRoute(
          path: '/edit-project',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final project = state.extra as ProjectModel?;
            return AddEditProjectScreen(project: project);
          },
        ),
        GoRoute(
          path: '/task-details',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final task = state.extra as TaskModel;
            return TaskDetailsScreen(task: task);
          },
        ),
        GoRoute(
          path: '/project-details',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final project = state.extra as ProjectModel;
            return ProjectDetailsScreen(project: project);
          },
        ),
      ],
    );

    return _instance!;
  }
}

