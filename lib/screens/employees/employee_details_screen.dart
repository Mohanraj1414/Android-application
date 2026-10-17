import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/status_badge.dart';
import 'employee_form_screen.dart';

/// Comprehensive Employee Details profile screen for executive review.
class EmployeeDetailsScreen extends StatelessWidget {
  final int employeeId;

  const EmployeeDetailsScreen({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employee = provider.allEmployees.where((e) => e.id == employeeId).firstOrNull;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('Employee not found or has been removed.', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Directory'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(employee.fullName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => EmployeeFormScreen(employee: employee),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            tooltip: 'Delete Employee',
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(context, employee);
              if (confirmed == true && context.mounted) {
                final success = await context.read<EmployeeProvider>().deleteEmployee(employee);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${employee.fullName} removed successfully.'),
                        backgroundColor: AppColors.navyDark,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Executive Profile Header Card
                _buildProfileHeaderCard(context, employee),
                const SizedBox(height: 24),

                // Responsive 2-column or 1-column layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 640;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildContactCard(context, employee),
                                const SizedBox(height: 20),
                                _buildAuditCard(employee),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                _buildEmploymentDetailsCard(employee),
                                const SizedBox(height: 20),
                                _buildNotesCard(employee),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildContactCard(context, employee),
                          const SizedBox(height: 20),
                          _buildEmploymentDetailsCard(employee),
                          const SizedBox(height: 20),
                          _buildNotesCard(employee),
                          const SizedBox(height: 20),
                          _buildAuditCard(employee),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, Employee employee) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarWidget(
            initials: employee.avatarInitials,
            backgroundColor: Color(employee.avatarColor),
            size: 72,
            status: employee.employmentStatus,
            showStatus: true,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        employee.employeeId,
                        style: AppTypography.codeBadge.copyWith(
                          color: AppColors.navyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${employee.designation} • ${employee.department}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge(status: employee.employmentStatus),
                    const SizedBox(width: 8),
                    StatusBadge(status: employee.employmentType, isCompact: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Employee employee) {
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
          const Row(
            children: [
              Icon(Icons.contact_mail_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Contact Information',
                style: TextStyle(
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
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Corporate Email',
            value: employee.email,
            action: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
              tooltip: 'Copy Email',
              splashRadius: 16,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied ${employee.email} to clipboard.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: employee.phone,
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Assigned Location',
            value: employee.location,
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.domain_rounded,
            label: 'Department Unit',
            value: employee.department,
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentDetailsCard(Employee employee) {
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
          const Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Employment & Tenure',
                style: TextStyle(
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
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Joining Date',
            value: DateFormatter.format(employee.joiningDate),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.hourglass_top_rounded,
            label: 'Current Tenure',
            value: DateFormatter.calculateTenure(employee.joiningDate),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Employment Type',
            value: employee.employmentType,
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status Verification',
            value: employee.employmentStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Employee employee) {
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
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Executive Notes & Key Responsibilities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (employee.notes.isEmpty)
            const Text(
              'No additional executive remarks or project assignments recorded for this profile.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
              ),
            )
          else
            Text(
              employee.notes,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(Employee employee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Record Created: ${DateFormatter.format(employee.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          Text(
            'Last Updated: ${DateFormatter.format(employee.updatedAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (action != null) ...[
          const Spacer(),
          action,
        ],
      ],
    );
  }
}
