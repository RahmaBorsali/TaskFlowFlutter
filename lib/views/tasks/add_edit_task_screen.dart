import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../models/enums.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../shared/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  String? _selectedProjectId;
  String? _selectedAssigneeId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.todo;
    _dueDate = widget.task?.dueDate;
    _selectedProjectId = widget.task?.projectId;
    _selectedAssigneeId = widget.task?.assignedTo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final taskViewModel = context.read<TaskViewModel>();
    final currentUser = context.read<AuthViewModel>().currentUser!;

    final task = TaskModel(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate,
      projectId: _selectedProjectId,
      assignedTo: _selectedAssigneeId,
      createdBy: widget.task?.createdBy ?? currentUser.id,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.task == null) {
      await taskViewModel.createTask(task);
    } else {
      await taskViewModel.updateTask(task);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.task == null ? l10n.successTaskCreated : l10n.successTaskUpdated)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projectViewModel = context.watch<ProjectViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.task == null ? l10n.addTask : l10n.editTask,
        actions: widget.task != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () => _confirmDelete(l10n),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(l10n.taskTitle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(hintText: l10n.taskTitle),
                validator: (v) => v!.isEmpty ? l10n.errorEmptyField : null,
              ),
              const SizedBox(height: 24),

              // Description
              Text(l10n.taskDescription, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(hintText: l10n.taskDescription),
              ),
              const SizedBox(height: 24),

              // Priority & Status Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.taskPriority, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TaskPriority>(
                          value: _priority,
                          decoration: const InputDecoration(),
                          items: TaskPriority.values.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                          }).toList(),
                          onChanged: (val) => setState(() => _priority = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.taskStatus, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TaskStatus>(
                          value: _status,
                          decoration: const InputDecoration(),
                          items: TaskStatus.values.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
                          }).toList(),
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Due Date
              Text(l10n.taskDueDate, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    } else {
                      setState(() => _dueDate = date); // Just the date if they cancel time
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate == null ? l10n.noneOption : DateFormat('dd MMM yyyy, HH:mm').format(_dueDate!),
                        style: TextStyle(color: _dueDate == null ? AppColors.textSecondaryLight : null),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Project Selector
              Text(l10n.taskProject, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedProjectId,
                decoration: const InputDecoration(),
                hint: Text(l10n.selectProject),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.noneOption)),
                  ...projectViewModel.projects.map((p) {
                    return DropdownMenuItem(value: p.id, child: Text(p.name));
                  }),
                ],
                onChanged: (val) => setState(() => _selectedProjectId = val),
              ),
              const SizedBox(height: 24),

              // Assignee Selector
              Text(l10n.taskAssignTo, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedAssigneeId,
                decoration: const InputDecoration(),
                hint: Text(l10n.selectUser),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.noneOption)),
                  ...authViewModel.getAllUsers().map((u) {
                    return DropdownMenuItem(value: u.id, child: Text(u.name));
                  }),
                ],
                onChanged: (val) => setState(() => _selectedAssigneeId = val),
              ),
              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(l10n.save),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteTask),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<TaskViewModel>().deleteTask(widget.task!.id);
              if (mounted) {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Screen
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
