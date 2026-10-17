import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_top_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'employees/employee_list_screen.dart';
import 'employees/employee_form_screen.dart';
import 'departments/departments_screen.dart';
import 'settings/settings_screen.dart';

/// Responsive main shell adapting between mobile navigation bar/drawer and desktop sidebar.
class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    EmployeeListScreen(),
    DepartmentsScreen(),
    SettingsScreen(),
  ];

  static const List<Map<String, String>> _screenMeta = [
    {
      'title': 'Executive Workforce Dashboard',
      'subtitle': 'Executive workforce overview and real-time operational analytics',
    },
    {
      'title': 'Employee Directory',
      'subtitle': 'Manage personnel records, departments, and roles',
    },
    {
      'title': 'Business Departments',
      'subtitle': 'Departmental structure, headcount, and budgetary allocations',
    },
    {
      'title': 'System Settings',
      'subtitle': 'Application configuration, database management, and diagnostics',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;
    final meta = _screenMeta[currentIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          // Desktop & Tablet Viewport: Left Sidebar + Top Bar + Content Area
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: meta['title']!,
                        subtitle: meta['subtitle'],
                        showAddButton: true,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: _screens,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Viewport: Drawer + Top Bar + Content Area + Bottom Navigation Bar
          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: const Drawer(
              width: 280,
              child: AppSidebar(),
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: AppTopBar(
                title: meta['title']!,
                subtitle: null,
                showAddButton: false,
              ),
            ),
            body: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const EmployeeFormScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add_alt_1_rounded),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (idx) => navProvider.setIndex(idx),
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.primaryLight,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.badge_outlined),
                    selectedIcon: Icon(Icons.badge_rounded, color: AppColors.primary),
                    label: 'Employees',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_tree_outlined),
                    selectedIcon: Icon(Icons.account_tree_rounded, color: AppColors.primary),
                    label: 'Departments',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
