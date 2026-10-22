import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../models/department.dart';
import '../models/activity_log.dart';
import '../models/dashboard_stats.dart';
import '../repositories/employee_repository.dart';
import '../core/constants/app_constants.dart';

/// Central state management for NEXUS People employees and analytics.
class EmployeeProvider extends ChangeNotifier {
  final EmployeeRepository _repository;

  EmployeeProvider({EmployeeRepository? repository})
      : _repository = repository ?? EmployeeRepository();

  // Internal State
  List<Employee> _allEmployees = [];
  DashboardStats _dashboardStats = DashboardStats.empty();
  List<Department> _departments = [];
  List<ActivityLog> _activityLogs = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _databasePath = '';
  int _databaseFileSize = 0;

  // Search & Filter State
  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedStatus;
  String? _selectedEmploymentType;
  String _selectedSort = AppConstants.sortNameAsc;

  // Getters
  List<Employee> get allEmployees => _allEmployees;
  DashboardStats get dashboardStats => _dashboardStats;
  List<Department> get departments => _departments;
  List<ActivityLog> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get databasePath => _databasePath;
  int get databaseFileSize => _databaseFileSize;

  String get searchQuery => _searchQuery;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedStatus => _selectedStatus;
  String? get selectedEmploymentType => _selectedEmploymentType;
  String get selectedSort => _selectedSort;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedDepartment != null ||
      _selectedStatus != null ||
      _selectedEmploymentType != null;

  /// Filtered and sorted employee list for the directory
  List<Employee> get filteredEmployees {
    List<Employee> list = List.from(_allEmployees);

    // Apply text search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((emp) {
        return emp.fullName.toLowerCase().contains(q) ||
            emp.employeeId.toLowerCase().contains(q) ||
            emp.email.toLowerCase().contains(q) ||
            emp.department.toLowerCase().contains(q) ||
            emp.designation.toLowerCase().contains(q) ||
            emp.location.toLowerCase().contains(q);
      }).toList();
    }

    // Apply department filter
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      list = list.where((emp) => emp.department == _selectedDepartment).toList();
    }

    // Apply status filter
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      list = list.where((emp) => emp.employmentStatus == _selectedStatus).toList();
    }

    // Apply employment type filter
    if (_selectedEmploymentType != null && _selectedEmploymentType!.isNotEmpty) {
      list = list.where((emp) => emp.employmentType == _selectedEmploymentType).toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case AppConstants.sortNameAsc:
        list.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case AppConstants.sortNameDesc:
        list.sort((a, b) => b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case AppConstants.sortDateDesc:
        list.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
        break;
      case AppConstants.sortDateAsc:
        list.sort((a, b) => a.joiningDate.compareTo(b.joiningDate));
        break;
      case AppConstants.sortIdAsc:
        list.sort((a, b) => a.employeeId.compareTo(b.employeeId));
        break;
      default:
        list.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    }

    return list;
  }

  /// Loads full data set from SQLite database
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final employeesFuture = _repository.getAllEmployees();
      final statsFuture = _repository.getDashboardStats();
      final deptsFuture = _repository.getDepartments();
      final logsFuture = _repository.getActivityLogs();
      final pathFuture = _repository.getDatabasePath();
      final sizeFuture = _repository.getDatabaseFileSize();

      final results = await Future.wait([
        employeesFuture,
        statsFuture,
        deptsFuture,
        logsFuture,
        pathFuture,
        sizeFuture,
      ]);

      _allEmployees = results[0] as List<Employee>;
      _dashboardStats = results[1] as DashboardStats;
      _departments = results[2] as List<Department>;
      _activityLogs = results[3] as List<ActivityLog>;
      _databasePath = results[4] as String;
      _databaseFileSize = results[5] as int;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load enterprise records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retrieves raw database rows for live in-app inspection
  Future<List<Map<String, dynamic>>> getRawTableRows(String table, {int limit = 50}) =>
      _repository.getRawTableRows(table, limit: limit);

  /// Adds a new employee to SQLite
  Future<bool> addEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate unique employee ID
      final isIdTaken = await _repository.isEmployeeIdTaken(employee.employeeId);
      if (isIdTaken) {
        _errorMessage = 'Employee ID "${employee.employeeId}" is already assigned to another employee.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate unique email
      final isEmailTaken = await _repository.isEmailTaken(employee.email);
      if (isEmailTaken) {
        _errorMessage = 'Corporate email "${employee.email}" is already registered.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _repository.insertEmployee(employee);
      await loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Database error creating employee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing employee
  Future<bool> updateEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check ID uniqueness excluding this employee
      final isIdTaken = await _repository.isEmployeeIdTaken(
        employee.employeeId,
        excludeId: employee.id,
      );
      if (isIdTaken) {
        _errorMessage = 'Employee ID "${employee.employeeId}" is already taken.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check Email uniqueness excluding this employee
      final isEmailTaken = await _repository.isEmailTaken(
        employee.email,
        excludeId: employee.id,
      );
      if (isEmailTaken) {
        _errorMessage = 'Corporate email "${employee.email}" is already registered to another staff member.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _repository.updateEmployee(employee);
      await loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Database error updating employee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes an employee from database
  Future<bool> deleteEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEmployee(employee);
      await loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete employee: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Generates the next sequential Employee ID (e.g. "NEX-1011")
  Future<String> getNextEmployeeId() async {
    return await _repository.generateNextEmployeeId();
  }

  /// Resets database to sample data
  Future<bool> resetToSampleData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.resetToSampleData();
      clearFilters();
      await loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reset demo data: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Filter and Search Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDepartmentFilter(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setEmploymentTypeFilter(String? type) {
    _selectedEmploymentType = type;
    notifyListeners();
  }

  void setSortOption(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = null;
    _selectedStatus = null;
    _selectedEmploymentType = null;
    _selectedSort = AppConstants.sortNameAsc;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
