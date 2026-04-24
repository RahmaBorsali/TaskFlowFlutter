import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../models/enums.dart';
import 'widgets/stats_card.dart';
import 'widgets/project_progress_card.dart';
import '../tasks/widgets/task_card.dart';
import '../shared/empty_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.id;
      if (userId != null) {
        context.read<TaskViewModel>().loadTasks(userId);
        context.read<ProjectViewModel>().loadProjects(userId);
      }
    });
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = context.watch<AuthViewModel>();
    final taskViewModel = context.watch<TaskViewModel>();
    final projectViewModel = context.watch<ProjectViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              taskViewModel.loadTasks(user.id);
              projectViewModel.loadProjects(user.id);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting(l10n)},",
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryLight),
                        ),
                        Text(
                          user?.name ?? 'Utilisateur',
                          style: AppTextStyles.h2,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: user != null ? Color(user.avatarColorValue) : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    StatsCard(
                      title: l10n.totalTasks,
                      value: taskViewModel.totalTasks.toString(),
                      icon: Icons.assignment_rounded,
                      color: AppColors.primary,
                    ),
                    StatsCard(
                      title: l10n.completedTasks,
                      value: taskViewModel.completedTasksCount.toString(),
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    StatsCard(
                      title: l10n.pendingTasks,
                      value: (taskViewModel.todoTasksCount + taskViewModel.inProgressTasksCount).toString(),
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.warning,
                    ),
                    StatsCard(
                      title: l10n.completionRate,
                      value: "${(taskViewModel.completionRate * 100).toInt()}%",
                      icon: Icons.analytics_rounded,
                      color: AppColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Projects Section
                if (projectViewModel.projects.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.projects, style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () => context.go('/projects'),
                        child: Text(l10n.all),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: projectViewModel.projects.length,
                      itemBuilder: (context, index) {
                        final project = projectViewModel.projects[index];
                        final projectTasks = taskViewModel.tasks.where((t) => t.projectId == project.id).toList();
                        final double progress = projectTasks.isEmpty 
                            ? 0.0 
                            : projectTasks.where((t) => t.status == TaskStatus.done).length / projectTasks.length;
                        return GestureDetector(
                          onTap: () => context.push('/project-details', extra: project),
                          child: ProjectProgressCard(project: project, progress: progress),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Recent Tasks Section
                Text(l10n.recentTasks, style: AppTextStyles.h3),
                const SizedBox(height: 16),
                if (taskViewModel.tasks.isEmpty)
                  EmptyState(
                    title: l10n.noTasks,
                    description: l10n.noTasksDescription,
                    icon: Icons.task_alt_rounded,
                  )
                else
                  AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taskViewModel.tasks.take(5).length,
                      itemBuilder: (context, index) {
                        final task = taskViewModel.tasks[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: TaskCard(
                                task: task,
                                onTap: () => context.push('/task-details', extra: task),
                                onStatusChanged: (value) async {
                                  final updatedTask = task.copyWith(
                                    status: value! ? TaskStatus.done : TaskStatus.todo,
                                  );
                                  await taskViewModel.updateTask(updatedTask);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-task'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTask),
      ),
    );
  }
}
