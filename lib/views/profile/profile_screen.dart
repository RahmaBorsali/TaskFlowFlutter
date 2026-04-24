import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/theme_provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import 'widgets/settings_tile.dart';
import '../shared/custom_app_bar.dart';
import '../../core/services/api_sync_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = context.watch<AuthViewModel>();
    final themeProvider = context.watch<ThemeProvider>();
    final settingsViewModel = context.watch<SettingsViewModel>();
    final taskViewModel = context.watch<TaskViewModel>();
    final user = authViewModel.currentUser;

    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.profile,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(user.avatarColorValue),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(user.avatarColorValue).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: AppTextStyles.h2),
                  Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Personal Stats Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: l10n.totalTasks, value: taskViewModel.totalTasks.toString()),
                  Container(width: 1, height: 40, color: AppColors.dividerLight),
                  _StatItem(label: l10n.completedTasks, value: taskViewModel.completedTasksCount.toString()),
                  Container(width: 1, height: 40, color: AppColors.dividerLight),
                  _StatItem(label: l10n.completionRate, value: "${(taskViewModel.completionRate * 100).toInt()}%"),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.settings, style: AppTextStyles.h3),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SettingsTile(
                      title: l10n.darkMode,
                      icon: Icons.dark_mode_rounded,
                      trailing: Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      title: l10n.language,
                      icon: Icons.language_rounded,
                      trailing: DropdownButton<String>(
                        value: settingsViewModel.locale.languageCode,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
                          DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                        ],
                        onChanged: (val) {
                          if (val != null) settingsViewModel.setLocale(Locale(val));
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      title: l10n.notifications,
                      icon: Icons.notifications_active_rounded,
                      trailing: Switch.adaptive(
                        value: settingsViewModel.notificationsEnabled,
                        onChanged: (_) => settingsViewModel.toggleNotifications(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sync Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SettingsTile(
                  title: l10n.syncData,
                  icon: Icons.cloud_sync_rounded,
                  iconColor: AppColors.info,
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Synchronisation en cours...')),
                    );
                    final success = await ApiSyncService.syncDataWithCloud();
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.syncSuccess),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Logout
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SettingsTile(
                  title: l10n.logout,
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  onTap: () => _confirmLogout(context, l10n, authViewModel),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                // Return to login is handled by the Router redirect
                Navigator.pop(context);
              }
            },
            child: Text(l10n.logout, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
      ],
    );
  }
}
