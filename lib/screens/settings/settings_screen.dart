import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/avatar_widget.dart';

/// Settings & System Management screen for executive configuration and demo controls.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmResetDemoData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.warningDark),
            SizedBox(width: 10),
            Text('Reset to Demonstration Data?'),
          ],
        ),
        content: const Text(
          'This will purge all custom records and re-seed the initial 10 enterprise employee profiles and activity audit stream.\n\nAre you sure you wish to proceed?',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Dataset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<EmployeeProvider>().resetToSampleData();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demonstration workforce records restored successfully.'),
              backgroundColor: AppColors.successDark,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reset demonstration records.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showExportSummary(BuildContext context) {
    final provider = context.read<EmployeeProvider>();
    final stats = provider.dashboardStats;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.analytics_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Executive Summary Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEXUS People • Live Workforce Metrics',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildExportRow('Total Registered Employees', stats.totalEmployees.toString()),
            _buildExportRow('Active Retained Staff', '${stats.activeEmployees} (${stats.activePercentage.toStringAsFixed(0)}%)'),
            _buildExportRow('On Leave', stats.onLeaveEmployees.toString()),
            _buildExportRow('Probation / Onboarding', stats.probationEmployees.toString()),
            _buildExportRow('Active Departments', stats.departmentCount.toString()),
            _buildExportRow('Database Engine', 'SQLite 3 (Persistent Local)'),
            const SizedBox(height: 12),
            const Text(
              'All metrics verified against local database transactions.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildExportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Enterprise Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure presentation profile, local database parameters, and demo controls.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Profile Card
              _buildCard(
                title: 'Managing Director Presentation Session',
                icon: Icons.account_circle_outlined,
                child: Row(
                  children: [
                    const AvatarWidget(
                      initials: 'AD',
                      backgroundColor: AppColors.primary,
                      size: 52,
                      status: 'Active',
                      showStatus: true,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator (Executive Demo)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'admin.exec@nexuscorp.com • Full Permissions',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.successBorder),
                      ),
                      child: const Text(
                        'Live SQLite Sync',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // System & Database Metrics Card
              _buildCard(
                title: 'Data & Persistence Engine',
                icon: Icons.storage_rounded,
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.table_chart_outlined,
                      title: 'Local SQLite Database',
                      subtitle: 'Persistent relational storage (nexus_people_enterprise.db)',
                      trailing: Text(
                        '${provider.allEmployees.length} Records',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildSettingItem(
                      icon: Icons.file_download_outlined,
                      title: 'Workforce Report Generator',
                      subtitle: 'Generate formatted metrics summary for executive review',
                      trailing: OutlinedButton(
                        onPressed: () => _showExportSummary(context),
                        child: const Text('Export Summary'),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildSettingItem(
                      icon: Icons.restart_alt_rounded,
                      title: 'Reset Demo Dataset',
                      subtitle: 'Re-populate original 10 realistic corporate demonstration employees',
                      trailing: ElevatedButton(
                        onPressed: () => _confirmResetDemoData(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningDark,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset Demo Data'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Application Info
              _buildCard(
                title: 'About NEXUS People',
                icon: Icons.info_outline_rounded,
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.verified_outlined,
                      title: 'Software Version',
                      subtitle: AppConstants.appVersion,
                      trailing: const Text(
                        'Production Ready',
                        style: TextStyle(
                          color: AppColors.successDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildSettingItem(
                      icon: Icons.layers_outlined,
                      title: 'Enterprise Architecture',
                      subtitle: 'Clean Repository Pattern • SQLite Persistence • Provider Reactive State',
                      trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}
