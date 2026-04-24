import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/enums.dart';
import 'widgets/project_card.dart';
import '../shared/empty_state.dart';
import '../shared/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.id;
      if (userId != null) {
        final projectVM = context.read<ProjectViewModel>();
        // Charger SEULEMENT si pas encore chargé (évite d'écraser la liste en mémoire)
        if (projectVM.projects.isEmpty && !projectVM.isLoading) {
          projectVM.loadProjects(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projectViewModel = context.watch<ProjectViewModel>();
    final taskViewModel = context.watch<TaskViewModel>();

    debugPrint('🏗️ ProjectsScreen.build: ${projectViewModel.projects.length} projects, isLoading=${projectViewModel.isLoading}');

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.projects,
        showBackButton: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(l10n.all, null, projectViewModel),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.active, ProjectStatus.active, projectViewModel),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.completed, ProjectStatus.completed, projectViewModel),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.archived, ProjectStatus.archived, projectViewModel),
                ],
              ),
            ),
          ),
          Expanded(
            child: projectViewModel.projects.isEmpty
                ? EmptyState(
                    title: l10n.noProjects,
                    description: l10n.noProjectsDescription,
                    icon: Icons.folder_open_rounded,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
              itemCount: projectViewModel.projects.length,
              itemBuilder: (context, index) {
                final project = projectViewModel.projects[index];
                final projectTasks = taskViewModel.tasks
                    .where((t) => t.projectId == project.id)
                    .toList();
                final completedCount = projectTasks
                    .where((t) => t.status == TaskStatus.done)
                    .length;

                return ProjectCard(
                  project: project,
                  taskCount: projectTasks.length,
                  completedTaskCount: completedCount,
                  onTap: () => context.push('/project-details', extra: project),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-project'),
        child: const Icon(Icons.create_new_folder_rounded),
      ),
    );
  }

  Widget _buildFilterChip(String label, ProjectStatus? status, ProjectViewModel vm) {
    final isSelected = _selectedStatus == status;
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = status);
        vm.setFilter(status);
      },
      backgroundColor: theme.cardTheme.color,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
