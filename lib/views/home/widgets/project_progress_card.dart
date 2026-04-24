import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/project_model.dart';

class ProjectProgressCard extends StatelessWidget {
  final ProjectModel project;
  final double progress;

  const ProjectProgressCard({
    super.key,
    required this.project,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 8.0,
                percent: progress,
                center: Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Color(project.colorValue),
                backgroundColor: Color(project.colorValue).withOpacity(0.1),
                animation: true,
              ),
              const SizedBox(height: 16),
              Text(
                project.name,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
