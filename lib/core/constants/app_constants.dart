/// Enterprise constants for NEXUS People.
class AppConstants {
  AppConstants._();

  static const String appName = 'NEXUS People';
  static const String appSubtitle = 'Enterprise Workforce Management';
  static const String appVersion = 'v1.4.2 Production';

  // Standard Departments
  static const List<String> departments = [
    'Engineering',
    'Product',
    'Human Resources',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'Legal',
  ];

  // Employment Types
  static const List<String> employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Intern',
  ];

  // Employment Statuses
  static const List<String> employmentStatuses = [
    'Active',
    'On Leave',
    'Probation',
    'Terminated',
  ];

  // Standard Corporate Locations
  static const List<String> locations = [
    'San Francisco, CA',
    'New York, NY',
    'London, UK',
    'Singapore',
    'Remote',
    'Mumbai, IN',
    'Berlin, DE',
    'Tokyo, JP',
  ];

  // Standard Sort Options
  static const String sortNameAsc = 'Name (A to Z)';
  static const String sortNameDesc = 'Name (Z to A)';
  static const String sortDateDesc = 'Joining Date (Newest)';
  static const String sortDateAsc = 'Joining Date (Oldest)';
  static const String sortIdAsc = 'Employee ID';

  static const List<String> sortOptions = [
    sortNameAsc,
    sortNameDesc,
    sortDateDesc,
    sortDateAsc,
    sortIdAsc,
  ];

  // Corporate Avatar Palette Colors (Hex Integers)
  static const List<int> avatarColorHexes = [
    0xFF4F46E5, // Indigo
    0xFF0891B2, // Cyan
    0xFF059669, // Emerald
    0xFFD97706, // Amber
    0xFF7C3AED, // Violet
    0xFFDC2626, // Crimson
    0xFF2563EB, // Blue
    0xFFDB2777, // Pink
  ];
}
