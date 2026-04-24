import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/project_model.dart';
import '../../models/enums.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../shared/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditProjectScreen extends StatefulWidget {
  final ProjectModel? project;

  const AddEditProjectScreen({super.key, this.project});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  
  late ProjectStatus _status;
  int _selectedColorValue = AppColors.primary.value;
  DateTime? _deadline;
  List<String> _selectedMemberIds = [];

  final List<int> _projectColors = [
    AppColors.primary.value,
    AppColors.secondary.value,
    AppColors.accent.value,
    AppColors.success.value,
    AppColors.info.value,
    Colors.orange.value,
    Colors.purple.value,
    Colors.redAccent.value,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _status = widget.project?.status ?? ProjectStatus.active;
    _selectedColorValue = widget.project?.colorValue ?? AppColors.primary.value;
    _deadline = widget.project?.deadline;
    _selectedMemberIds = List.from(widget.project?.memberIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final projectViewModel = context.read<ProjectViewModel>();
    final currentUser = context.read<AuthViewModel>().currentUser!;

    // Ensure creator is in members
    if (!_selectedMemberIds.contains(currentUser.id)) {
      _selectedMemberIds.add(currentUser.id);
    }

    final project = ProjectModel(
      id: widget.project?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      colorValue: _selectedColorValue,
      status: _status,
      memberIds: _selectedMemberIds,
      createdBy: widget.project?.createdBy ?? currentUser.id,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
      deadline: _deadline,
    );

    if (widget.project == null) {
      await projectViewModel.createProject(project);
    } else {
      await projectViewModel.updateProject(project);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.project == null ? l10n.successProjectCreated : l10n.successProjectUpdated)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = context.watch<AuthViewModel>();
    final users = authViewModel.getAllUsers();

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.project == null ? l10n.addProject : l10n.editProject,
        actions: widget.project != null
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
              // Name
              Text(l10n.projectName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: l10n.projectName),
                validator: (v) => v!.isEmpty ? l10n.errorEmptyField : null,
              ),
              const SizedBox(height: 24),

              // Description
              Text(l10n.projectDescription, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(hintText: l10n.projectDescription),
              ),
              const SizedBox(height: 24),

              // Color Selection
              Text(l10n.projectColor, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _projectColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorVal = _projectColors[index];
                    final isSelected = _selectedColorValue == colorVal;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorValue = colorVal),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: Color(colorVal).withOpacity(0.4), blurRadius: 8)] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Status
              Text(l10n.status, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                decoration: const InputDecoration(),
                items: ProjectStatus.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 24),

              // Deadline
              Text(l10n.projectDeadline, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _deadline = date);
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
                        _deadline == null ? l10n.noneOption : DateFormat('dd MMM, yyyy').format(_deadline!),
                        style: TextStyle(color: _deadline == null ? AppColors.textSecondaryLight : null),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Members Multi-Select (Simplified)
              Text(l10n.projectMembers, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: users.map((u) {
                  final isSelected = _selectedMemberIds.contains(u.id);
                  return FilterChip(
                    label: Text(u.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMemberIds.add(u.id);
                        } else {
                          if (u.id != authViewModel.currentUser?.id) {
                            _selectedMemberIds.remove(u.id);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_selectedColorValue),
                  ),
                  onPressed: _saveProject,
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
        content: Text(l10n.confirmDeleteProject),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<ProjectViewModel>().deleteProject(widget.project!.id);
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
