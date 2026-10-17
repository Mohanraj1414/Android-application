import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../providers/employee_provider.dart';
import 'avatar_widget.dart';

/// Collapsible enterprise navigation sidebar for tablet and desktop viewports.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final empProvider = context.watch<EmployeeProvider>();
    final isCollapsed = navProvider.isSidebarCollapsed;

    final width = isCollapsed ? 76.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Branding Area
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 14 : 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed) ...[
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF818CF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3D4F46E5),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.blur_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'NEXUS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'PEOPLE OPS',
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_open_rounded, color: AppColors.textMuted, size: 20),
                    tooltip: 'Collapse sidebar',
                    onPressed: navProvider.toggleSidebar,
                    splashRadius: 18,
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                    tooltip: 'Expand sidebar',
                    onPressed: navProvider.toggleSidebar,
                    splashRadius: 18,
                  ),
                ],
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isCollapsed: isCollapsed,
                  isSelected: navProvider.currentIndex == 0,
                  onTap: () => navProvider.setIndex(0),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge_rounded,
                  label: 'Employees',
                  badgeCount: empProvider.allEmployees.length,
                  isCollapsed: isCollapsed,
                  isSelected: navProvider.currentIndex == 1,
                  onTap: () => navProvider.setIndex(1),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.account_tree_outlined,
                  activeIcon: Icons.account_tree_rounded,
                  label: 'Departments',
                  badgeCount: empProvider.departments.length,
                  isCollapsed: isCollapsed,
                  isSelected: navProvider.currentIndex == 2,
                  onTap: () => navProvider.setIndex(2),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isCollapsed: isCollapsed,
                  isSelected: navProvider.currentIndex == 3,
                  onTap: () => navProvider.setIndex(3),
                ),
              ],
            ),
          ),

          // Bottom Current Administrator Profile
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF090D16),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: isCollapsed
                ? const Center(
                    child: AvatarWidget(
                      initials: 'AD',
                      backgroundColor: AppColors.primary,
                      size: 36,
                      status: 'Active',
                      showStatus: true,
                    ),
                  )
                : Row(
                    children: [
                      const AvatarWidget(
                        initials: 'AD',
                        backgroundColor: AppColors.primary,
                        size: 38,
                        status: 'Active',
                        showStatus: true,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Managing Director Mode',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successBg.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successDark.withAlpha(80)),
                        ),
                        child: const Text(
                          'MD',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
    required bool isCollapsed,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeBg = AppColors.primary.withAlpha(35);
    final activeColor = const Color(0xFF818CF8);
    final inactiveColor = AppColors.textMuted;

    return Material(
      color: isSelected ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withAlpha(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 14,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
