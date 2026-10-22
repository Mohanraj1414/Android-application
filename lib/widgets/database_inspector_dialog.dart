import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/employee_provider.dart';

/// Interactive database inspector dialog for executive transparency.
/// Displays the actual SQLite file location on disk, row counts, and raw database rows.
class DatabaseInspectorDialog extends StatefulWidget {
  const DatabaseInspectorDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const DatabaseInspectorDialog(),
    );
  }

  @override
  State<DatabaseInspectorDialog> createState() => _DatabaseInspectorDialogState();
}

class _DatabaseInspectorDialogState extends State<DatabaseInspectorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _employeeRows = [];
  List<Map<String, dynamic>> _activityRows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRawData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRawData() async {
    setState(() => _isLoading = true);
    final provider = context.read<EmployeeProvider>();
    final empRows = await provider.getRawTableRows('employees');
    final actRows = await provider.getRawTableRows('activity_logs');
    if (mounted) {
      setState(() {
        _employeeRows = empRows;
        _activityRows = actRows;
        _isLoading = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'In-Memory / Dynamic';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final dbPath = provider.databasePath;
    final fileSizeStr = _formatFileSize(provider.databaseFileSize);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      elevation: 20,
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storage_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SQLite Database Inspector', style: AppTypography.titleLarge),
                          SizedBox(height: 2),
                          Text(
                            'Real-time physical storage and raw table records',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // File Location Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.folder_open_rounded, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Physical File Location on Disk:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'Size: $fileSizeStr',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            dbPath.isNotEmpty ? dbPath : 'Initializing database connection...',
                            style: AppTypography.codeBadge.copyWith(
                              fontSize: 12,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                          tooltip: 'Copy Absolute Database Path',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: dbPath));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Database path copied to clipboard.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'employees (${_employeeRows.length} rows)'),
                  Tab(text: 'activity_logs (${_activityRows.length} rows)'),
                  const Tab(text: 'How to View Database'),
                ],
              ),
              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEmployeesTable(),
                          _buildActivityTable(),
                          _buildHowToViewGuide(dbPath),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeesTable() {
    if (_employeeRows.isEmpty) {
      return const Center(child: Text('No records in employees table'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceSubtle),
          columns: const [
            DataColumn(label: Text('id', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('employee_id', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('full_name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('department', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('designation', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('location', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('employment_status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('joining_date', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _employeeRows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row['id']?.toString() ?? '')),
              DataCell(Text(
                row['employee_id']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
              )),
              DataCell(Text(row['full_name']?.toString() ?? '')),
              DataCell(Text(row['department']?.toString() ?? '')),
              DataCell(Text(row['designation']?.toString() ?? '')),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  row['location']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
              )),
              DataCell(Text(row['email']?.toString() ?? '')),
              DataCell(Text(row['employment_status']?.toString() ?? '')),
              DataCell(Text(
                row['joining_date']?.toString().split('T').first ?? '',
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityTable() {
    if (_activityRows.isEmpty) {
      return const Center(child: Text('No records in activity_logs table'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceSubtle),
          columns: const [
            DataColumn(label: Text('id', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('action_type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('title', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _activityRows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row['id']?.toString() ?? '')),
              DataCell(Text(
                row['action_type']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navyMedium),
              )),
              DataCell(Text(row['title']?.toString() ?? '')),
              DataCell(Text(row['description']?.toString() ?? '')),
              DataCell(Text(row['timestamp']?.toString() ?? '')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHowToViewGuide(String dbPath) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to View and Inspect this SQLite Database File Externally:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '1. On Windows Desktop / PC:',
            'The database is located at:\n$dbPath\n\nYou can open this file using:\n• DB Browser for SQLite (Free open-source GUI at sqlitebrowser.org)\n• VS Code extension: "SQLite Viewer" or "SQLite Viewer Web"\n• SQLite CLI: `sqlite3 "$dbPath"`',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '2. On Android Device or Emulator:',
            'The database is located inside the application sandbox at:\n/data/data/com.example.flutter_application_1/databases/nexus_people_enterprise.db\n\nTo view on computer:\n• In Android Studio: Open "Device File Explorer" → `data/data/com.example.flutter_application_1/databases/` → Right-click and choose "Save As"\n• Or using ADB in terminal:\n  `adb exec-out run-as com.example.flutter_application_1 cat databases/nexus_people_enterprise.db > nexus.db`',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '3. Direct In-App Verification:',
            'Every time you add, edit, or delete an employee, SQLite commits the row immediately into the table shown in the "employees" tab above.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 6),
          SelectableText(
            body,
            style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
