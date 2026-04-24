import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/project_model.dart';
import '../../models/enums.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/custom_app_bar.dart';
import '../shared/custom_sweet_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projectViewModel = context.watch<ProjectViewModel>();
    final taskViewModel = context.watch<TaskViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    
    // Stay reactive
    final currentProject = projectViewModel.projects.firstWhere(
      (p) => p.id == project.id,
      orElse: () => project,
    );

    final projectTasks = taskViewModel.tasks.where((t) => t.projectId == currentProject.id).toList();
    final completedTasks = projectTasks.where((t) => t.status == TaskStatus.done).length;
    final progress = projectTasks.isEmpty ? 0.0 : completedTasks / projectTasks.length;
    final color = Color(currentProject.colorValue);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.projects,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/edit-project', extra: currentProject),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(context, currentProject, l10n, projectViewModel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getLocalizedStatus(context, currentProject.status).toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(currentProject.name, style: AppTextStyles.h1),
            const SizedBox(height: 16),
            
            // Description
            Text(
              currentProject.description,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // Progress Section
            Text("Progression de l'équipe", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$completedTasks / ${projectTasks.length} tâches", style: AppTextStyles.bodyMedium),
                      Text("${(progress * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.1),
                    color: color,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Members Section
            Text(l10n.members, style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: currentProject.memberIds.map((id) {
                final user = authViewModel.getUserById(id);
                if (user == null) return const SizedBox.shrink();
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Color(user.avatarColorValue),
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  label: Text(user.name),
                  backgroundColor: Theme.of(context).cardTheme.color,
                  side: BorderSide(color: AppColors.dividerLight),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Details Card
            if (currentProject.deadline != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondaryLight, size: 20),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.projectDeadline, style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(currentProject.deadline!),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: currentProject.deadline!.isBefore(DateTime.now()) && currentProject.status != ProjectStatus.completed 
                                ? AppColors.error 
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],

            // Action Button
            if (currentProject.status != ProjectStatus.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text("Clôturer le projet"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final updatedProject = currentProject.copyWith(status: ProjectStatus.completed);
                    await projectViewModel.updateProject(updatedProject);
                    if (context.mounted) {
                      CustomSweetDialog.show(
                        context: context,
                        title: "Projet Terminé !",
                        description: "Félicitations à toute l'équipe.",
                        type: DialogType.success,
                        confirmText: "Génial",
                        onConfirm: () {},
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ProjectModel project, AppLocalizations l10n, ProjectViewModel vm) {
    CustomSweetDialog.show(
      context: context,
      title: l10n.confirmDelete,
      description: l10n.confirmDeleteProject,
      type: DialogType.error,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      onCancel: () {},
      onConfirm: () async {
        await vm.deleteProject(project.id);
        if (context.mounted) {
          context.pop(); // Go back to list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.successProjectDeleted)),
          );
        }
      },
    );
  }

  String _getLocalizedStatus(BuildContext context, ProjectStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ProjectStatus.active:
        return l10n.active;
      case ProjectStatus.completed:
        return l10n.completed;
      case ProjectStatus.archived:
        return l10n.archived;
    }
  }
}
