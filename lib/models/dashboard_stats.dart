/// Calculated executive dashboard metrics derived dynamically from database.
class DashboardStats {
  final int totalEmployees;
  final int activeEmployees;
  final int onLeaveEmployees;
  final int probationEmployees;
  final int terminatedEmployees;
  final int departmentCount;
  final int recentlyJoinedCount;
  final double activePercentage;
  final Map<String, int> departmentCounts;
  final List<MonthlyGrowthData> growthTrend;

  const DashboardStats({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.onLeaveEmployees,
    required this.probationEmployees,
    required this.terminatedEmployees,
    required this.departmentCount,
    required this.recentlyJoinedCount,
    required this.activePercentage,
    required this.departmentCounts,
    required this.growthTrend,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalEmployees: 0,
      activeEmployees: 0,
      onLeaveEmployees: 0,
      probationEmployees: 0,
      terminatedEmployees: 0,
      departmentCount: 0,
      recentlyJoinedCount: 0,
      activePercentage: 0.0,
      departmentCounts: {},
      growthTrend: [],
    );
  }
}

class MonthlyGrowthData {
  final String label; // e.g. "May", "Jun"
  final int year;
  final int month;
  final int count;

  const MonthlyGrowthData({
    required this.label,
    required this.year,
    required this.month,
    required this.count,
  });
}
