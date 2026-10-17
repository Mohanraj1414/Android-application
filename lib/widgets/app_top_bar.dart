import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../screens/employees/employee_form_screen.dart';

/// Top application bar for executive overview and rapid actions.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showAddButton;
  final VoidCallback? onSearchTap;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showAddButton = true,
    this.onSearchTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final currentDateStr = DateFormatter.formatHeader(DateTime.now());

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // If mobile, show menu icon to open drawer
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (!isDesktop) const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Date indicator (desktop/tablet)
          if (isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    currentDateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Notification icon button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 22),
                tooltip: 'System notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All enterprise services operational. No pending alerts.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                splashRadius: 20,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // Primary "Add Employee" CTA button
          if (showAddButton) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const EmployeeFormScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(isDesktop ? 'Add Employee' : 'Add'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
