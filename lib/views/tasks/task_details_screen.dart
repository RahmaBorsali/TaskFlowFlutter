import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../models/enums.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/custom_app_bar.dart';
import '../shared/custom_sweet_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskViewModel = context.watch<TaskViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    
    // We get the updated task from viewmodel to stay reactive
    final currentTask = taskViewModel.tasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    final assignedUser = authViewModel.getUserById(currentTask.assignedTo);
    final creatorUser = authViewModel.getUserById(currentTask.createdBy);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.tasks,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/edit-task', extra: currentTask),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(context, currentTask, l10n, taskViewModel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and Priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, currentTask.status, l10n),
                _buildPriorityBadge(currentTask.priority, l10n),
              ],
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(currentTask.title, style: AppTextStyles.h1),
            const SizedBox(height: 16),
            
            // Description
            Text(
              currentTask.description,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: Column(
                children: [
                  if (currentTask.dueDate != null)
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: l10n.dueDate,
                      value: DateFormat('dd MMM yyyy, HH:mm').format(currentTask.dueDate!),
                      valueColor: currentTask.dueDate!.isBefore(DateTime.now()) && currentTask.status != TaskStatus.done 
                          ? AppColors.error 
                          : null,
                    ),
                  const Divider(height: 30),
                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n.assignedTo,
                    value: assignedUser?.name ?? l10n.noAssignment,
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(
                    icon: Icons.create_rounded,
                    label: l10n.createdBy,
                    value: creatorUser?.name ?? 'Utilisateur inconnu',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Action Button
            if (currentTask.status != TaskStatus.done)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text("Marquer comme terminée"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final updatedTask = currentTask.copyWith(status: TaskStatus.done);
                    await taskViewModel.updateTask(updatedTask);
                    if (context.mounted) {
                      CustomSweetDialog.show(
                        context: context,
                        title: "Bravo !",
                        description: "La tâche a été marquée comme terminée.",
                        type: DialogType.success,
                        confirmText: "Super",
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

  void _showDeleteConfirm(BuildContext context, TaskModel task, AppLocalizations l10n, TaskViewModel vm) {
    CustomSweetDialog.show(
      context: context,
      title: l10n.confirmDelete,
      description: l10n.confirmDeleteTask,
      type: DialogType.warning,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      onCancel: () {},
      onConfirm: () async {
        await vm.deleteTask(task.id);
        if (context.mounted) {
          context.pop(); // Go back to list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.successTaskDeleted)),
          );
        }
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, TaskStatus status, AppLocalizations l10n) {
    Color color;
    String text;
    switch (status) {
      case TaskStatus.todo:
        color = AppColors.secondary;
        text = l10n.todo;
        break;
      case TaskStatus.inProgress:
        color = AppColors.info;
        text = l10n.inProgress;
        break;
      case TaskStatus.done:
        color = AppColors.success;
        text = l10n.done;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority, AppLocalizations l10n) {
    Color color;
    String text;
    switch (priority) {
      case TaskPriority.low:
        color = AppColors.info;
        text = l10n.low;
        break;
      case TaskPriority.medium:
        color = AppColors.warning;
        text = l10n.medium;
        break;
      case TaskPriority.high:
        color = Colors.orange;
        text = l10n.high;
        break;
      case TaskPriority.urgent:
        color = AppColors.error;
        text = l10n.urgent;
        break;
    }

    return Row(
      children: [
        Icon(Icons.flag_rounded, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondaryLight, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.bodyMedium.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
