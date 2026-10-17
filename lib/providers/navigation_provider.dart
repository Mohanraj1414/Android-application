import 'package:flutter/foundation.dart';

/// Navigation state provider managing active destination and sidebar status.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0; // 0: Dashboard, 1: Employees, 2: Departments, 3: Settings
  bool _isSidebarCollapsed = false;

  int get currentIndex => _currentIndex;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void navigateToEmployees({String? departmentFilter}) {
    _currentIndex = 1;
    notifyListeners();
  }

  void navigateToDashboard() {
    _currentIndex = 0;
    notifyListeners();
  }

  void navigateToDepartments() {
    _currentIndex = 2;
    notifyListeners();
  }

  void navigateToSettings() {
    _currentIndex = 3;
    notifyListeners();
  }
}
