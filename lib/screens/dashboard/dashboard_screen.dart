import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/growth_chart.dart';
import '../../widgets/dept_distribution_chart.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/status_badge.dart';
import '../employees/employee_details_screen.dart';
import '../employees/employee_form_screen.dart';

/// Executive Dashboard for Managing Director presentation.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final empProvider = context.watch<EmployeeProvider>();
    final navProvider = context.read<NavigationProvider>();
    final stats = empProvider.dashboardStats;

    if (empProvider.isLoading && empProvider.allEmployees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final recentEmployees = empProvider.allEmployees.take(4).toList();
    final recentLogs = empProvider.activityLogs.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 600 && !isDesktop;

        return RefreshIndicator(
          onRefresh: () => empProvider.loadData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive Welcome Banner
                _buildWelcomeHeader(context, empProvider),
                const SizedBox(height: 24),

                // 4 Strategic Stat Cards
                _buildStatCards(context, stats, navProvider, isDesktop, isTablet),
                const SizedBox(height: 24),

                // Charts Row
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildChartCard(
                          title: 'Workforce Growth Trajectory',
                          subtitle: 'Cumulative headcount expansion over past 7 months',
                          child: GrowthChart(data: stats.growthTrend),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: _buildChartCard(
                          title: 'Department Distribution',
                          subtitle: 'Active resource allocation by department',
                          child: DeptDistributionChart(
                            departmentCounts: stats.departmentCounts,
                            totalEmployees: stats.totalEmployees,
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildChartCard(
                    title: 'Workforce Growth Trajectory',
                    subtitle: 'Cumulative headcount expansion over past 7 months',
                    child: GrowthChart(data: stats.growthTrend),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'Department Distribution',
                    subtitle: 'Active resource allocation by department',
                    child: DeptDistributionChart(
                      departmentCounts: stats.departmentCounts,
                      totalEmployees: stats.totalEmployees,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Recent Additions & Activity Logs
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildRecentAdditionsCard(context, recentEmployees, navProvider),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: _buildActivityFeedCard(context, recentLogs),
                      ),
                    ],
                  )
                else ...[
                  _buildRecentAdditionsCard(context, recentEmployees, navProvider),
                  const SizedBox(height: 20),
                  _buildActivityFeedCard(context, recentLogs),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, EmployeeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good morning, Admin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s your live workforce overview for ${DateFormatter.formatHeader(DateTime.now())}.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const EmployeeFormScreen()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
    BuildContext context,
    dynamic stats,
    NavigationProvider navProvider,
    bool isDesktop,
    bool isTablet,
  ) {
    final cards = [
      StatCard(
        title: 'Total Workforce',
        value: stats.totalEmployees.toString(),
        subtitle: 'Across all business units',
        icon: Icons.groups_rounded,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primaryLight,
        trendText: '+12% YoY',
        isTrendPositive: true,
        onTap: () => navProvider.navigateToEmployees(),
      ),
      StatCard(
        title: 'Active Employees',
        value: stats.activeEmployees.toString(),
        subtitle: '${stats.activePercentage.toStringAsFixed(0)}% retention rate',
        icon: Icons.verified_user_rounded,
        iconColor: AppColors.success,
        iconBgColor: AppColors.successBg,
        trendText: 'Healthy',
        isTrendPositive: true,
        onTap: () => navProvider.navigateToEmployees(),
      ),
      StatCard(
        title: 'Departments',
        value: stats.departmentCount.toString(),
        subtitle: 'Operational business groups',
        icon: Icons.business_rounded,
        iconColor: const Color(0xFF0891B2),
        iconBgColor: const Color(0xFFECFEFF),
        trendText: 'Stable',
        isTrendPositive: true,
        onTap: () => navProvider.navigateToDepartments(),
      ),
      StatCard(
        title: 'Recent Additions',
        value: stats.recentlyJoinedCount.toString(),
        subtitle: 'Joined in past 90 days',
        icon: Icons.person_add_rounded,
        iconColor: AppColors.warningDark,
        iconBgColor: AppColors.warningBg,
        trendText: 'Q4 Pipeline',
        isTrendPositive: true,
        onTap: () => navProvider.navigateToEmployees(),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                ))
            .toList(),
      );
    }
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodyMedium),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildRecentAdditionsCard(
    BuildContext context,
    List<Employee> recentEmployees,
    NavigationProvider navProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Additions', style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Text('Latest onboarded staff members', style: AppTypography.bodyMedium),
                ],
              ),
              TextButton(
                onPressed: () => navProvider.navigateToEmployees(),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentEmployees.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No employees registered yet.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentEmployees.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final emp = recentEmployees[idx];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: AvatarWidget(
                    initials: emp.avatarInitials,
                    backgroundColor: Color(emp.avatarColor),
                    size: 38,
                    status: emp.employmentStatus,
                    showStatus: true,
                  ),
                  title: Row(
                    children: [
                      Text(
                        emp.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: emp.employmentStatus, isCompact: true),
                    ],
                  ),
                  subtitle: Text(
                    '${emp.designation} • ${emp.department}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    DateFormatter.format(emp.joiningDate),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (c) => EmployeeDetailsScreen(employeeId: emp.id!),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityFeedCard(BuildContext context, List<dynamic> logs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Audit Stream', style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Text('Executive workforce event log', style: AppTypography.bodyMedium),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fiber_manual_record_rounded, size: 8, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No audit events recorded yet.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final log = logs[idx];
                IconData icon;
                Color color;
                Color bgColor;

                switch (log.actionType) {
                  case 'CREATE':
                    icon = Icons.add_circle_outline_rounded;
                    color = AppColors.success;
                    bgColor = AppColors.successBg;
                    break;
                  case 'UPDATE':
                    icon = Icons.sync_rounded;
                    color = AppColors.primary;
                    bgColor = AppColors.primaryLight;
                    break;
                  case 'DELETE':
                    icon = Icons.delete_outline_rounded;
                    color = AppColors.danger;
                    bgColor = AppColors.dangerBg;
                    break;
                  default:
                    icon = Icons.info_outline_rounded;
                    color = AppColors.navyLight;
                    bgColor = AppColors.surfaceSubtle;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                log.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                DateFormatter.timeAgo(log.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
