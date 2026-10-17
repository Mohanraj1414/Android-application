import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/employee_card.dart';
import '../../widgets/employee_table.dart';
import 'employee_details_screen.dart';
import 'employee_form_screen.dart';

/// Enterprise Employee Directory with live search, multi-factor filtering, and sorting.
class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<EmployeeProvider>();
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onViewEmployee(Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EmployeeDetailsScreen(employeeId: employee.id!),
      ),
    );
  }

  void _onEditEmployee(Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EmployeeFormScreen(employee: employee),
      ),
    );
  }

  Future<void> _onDeleteEmployee(Employee employee) async {
    final confirmed = await ConfirmationDialog.show(context, employee);
    if (confirmed == true && mounted) {
      final success = await context.read<EmployeeProvider>().deleteEmployee(employee);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${employee.fullName} removed from NEXUS People.'),
              backgroundColor: AppColors.navyDark,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: AppColors.primaryMuted,
                onPressed: () {},
              ),
            ),
          );
        } else {
          final err = context.read<EmployeeProvider>().errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err ?? 'Failed to delete employee.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employees = provider.filteredEmployees;
    final totalCount = provider.allEmployees.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area
                _buildHeader(context, totalCount, employees.length),
                const SizedBox(height: 20),

                // Search & Filter Toolbar
                _buildFilterBar(context, provider, isDesktop),
                const SizedBox(height: 20),

                // Data View
                if (provider.isLoading && provider.allEmployees.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (employees.isEmpty)
                  _buildEmptyState(context, provider)
                else if (isDesktop)
                  EmployeeTable(
                    employees: employees,
                    onView: _onViewEmployee,
                    onEdit: _onEditEmployee,
                    onDelete: _onDeleteEmployee,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: employees.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final emp = employees[i];
                      return EmployeeCard(
                        employee: emp,
                        onTap: () => _onViewEmployee(emp),
                        onEdit: () => _onEditEmployee(emp),
                        onDelete: () => _onDeleteEmployee(emp),
                      );
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int totalCount, int filteredCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Employee Directory',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$filteredCount of $totalCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage staff records, departments, and corporate role assignments.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const EmployeeFormScreen()),
            );
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Employee'),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, EmployeeProvider provider, bool isDesktop) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (val) => provider.setSearchQuery(val),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search by name, ID, email, designation...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    final departmentDropdown = DropdownButtonFormField<String>(
      initialValue: provider.selectedDepartment,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Department',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Departments', style: TextStyle(fontSize: 13))),
        ...AppConstants.departments.map(
          (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))),
        ),
      ],
      onChanged: (val) => provider.setDepartmentFilter(val),
    );

    final statusDropdown = DropdownButtonFormField<String>(
      initialValue: provider.selectedStatus,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Statuses', style: TextStyle(fontSize: 13))),
        ...AppConstants.employmentStatuses.map(
          (s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))),
        ),
      ],
      onChanged: (val) => provider.setStatusFilter(val),
    );

    final sortDropdown = DropdownButtonFormField<String>(
      initialValue: provider.selectedSort,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Sort By',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: AppConstants.sortOptions.map(
        (s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))),
      ).toList(),
      onChanged: (val) {
        if (val != null) provider.setSortOption(val);
      },
    );

    final clearButton = provider.hasActiveFilters
        ? OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.dangerBorder),
            ),
          )
        : const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 4, child: searchField),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: departmentDropdown),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: statusDropdown),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: sortDropdown),
                if (provider.hasActiveFilters) ...[
                  const SizedBox(width: 12),
                  clearButton,
                ],
              ],
            )
          else ...[
            searchField,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: departmentDropdown),
                const SizedBox(width: 10),
                Expanded(child: statusDropdown),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: sortDropdown),
                if (provider.hasActiveFilters) ...[
                  const SizedBox(width: 10),
                  clearButton,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, EmployeeProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching employees found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search criteria or clear active filters.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (provider.hasActiveFilters)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const EmployeeFormScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add First Employee'),
            ),
        ],
      ),
    );
  }
}
