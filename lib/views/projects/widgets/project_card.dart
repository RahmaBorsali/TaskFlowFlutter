import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/project_model.dart';
import '../../../models/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int taskCount;
  final int completedTaskCount;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.taskCount,
    required this.completedTaskCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = taskCount == 0 ? 0 : completedTaskCount / taskCount;
    final color = Color(project.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getLocalizedStatus(context, project.status).toUpperCase(),
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("$completedTaskCount/$taskCount", style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 16),
              Text(project.name, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatars of members (simplified)
                  SizedBox(
                    height: 32,
                    width: project.memberIds.isEmpty
                        ? 28
                        : (project.memberIds.length > 3 ? 3 : project.memberIds.length) * 20.0 + 8,
                    child: project.memberIds.isEmpty
                        ? CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary.withOpacity(0.3),
                            child: const Icon(Icons.person, size: 14, color: Colors.white),
                          )
                        : Stack(
                            children: List.generate(
                              project.memberIds.length > 3 ? 3 : project.memberIds.length,
                              (index) => Positioned(
                                left: index * 20.0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withOpacity(0.5),
                                  child: const Icon(Icons.person, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (project.deadline != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          "${project.deadline!.day}/${project.deadline!.month}",
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
