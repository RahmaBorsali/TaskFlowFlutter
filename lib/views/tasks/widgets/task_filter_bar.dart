import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/enums.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskStatus? currentStatus;
  final Function(TaskStatus?) onStatusChanged;
  final Map<TaskStatus?, String> statusLabels;

  const TaskFilterBar({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.statusLabels,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: statusLabels[null]!,
            isSelected: currentStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          ...TaskStatus.values.map((status) {
            return _FilterChip(
              label: statusLabels[status]!,
              isSelected: currentStatus == status,
              onTap: () => onStatusChanged(status),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
