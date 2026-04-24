import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/enums.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_bar.dart';
import '../shared/empty_state.dart';
import '../shared/loading_widget.dart';
import '../shared/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _selectedStatus;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.id;
      if (userId != null) {
        final taskVM = context.read<TaskViewModel>();
        if (taskVM.totalTasks == 0 && !taskVM.isLoading) {
          taskVM.loadTasks(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskViewModel = context.watch<TaskViewModel>();
    final user = context.read<AuthViewModel>().currentUser;

    if (user == null) return const Scaffold();

    final statusLabels = {
      null: l10n.all,
      TaskStatus.todo: l10n.todo,
      TaskStatus.inProgress: l10n.inProgress,
      TaskStatus.done: l10n.done,
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.tasks,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Search and Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => taskViewModel.setFilters(search: val),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              taskViewModel.setFilters(search: '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TaskFilterBar(
                  currentStatus: _selectedStatus,
                  statusLabels: statusLabels,
                  onStatusChanged: (status) {
                    setState(() => _selectedStatus = status);
                    if (status == null) {
                      taskViewModel.setFilters(clearStatus: true);
                    } else {
                      taskViewModel.setFilters(status: status);
                    }
                  },
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: taskViewModel.isLoading
                ? const LoadingWidget()
                : taskViewModel.tasks.isEmpty
                    ? EmptyState(
                    title: l10n.noTasks,
                    description: l10n.noTasksDescription,
                    icon: Icons.assignment_rounded,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: taskViewModel.tasks.length,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
