/// Enterprise Employee data model for NEXUS People.
class Employee {
  final int? id;
  final String employeeId;
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final DateTime joiningDate;
  final String employmentType;
  final String employmentStatus;
  final String location;
  final int avatarColor;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.employmentType,
    required this.employmentStatus,
    required this.location,
    required this.avatarColor,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Derives 2-letter uppercase initials from full name (e.g. "Sarah Jenkins" -> "SJ")
  String get avatarInitials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'NX';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Check whether employee is currently active
  bool get isActive => employmentStatus.toLowerCase() == 'active';

  /// Check whether employee is currently on leave
  bool get isOnLeave => employmentStatus.toLowerCase() == 'on leave';

  /// Check whether employee is on probation
  bool get isProbation => employmentStatus.toLowerCase() == 'probation';

  /// Check whether employee is terminated
  bool get isTerminated => employmentStatus.toLowerCase() == 'terminated';

  Employee copyWith({
    int? id,
    String? employeeId,
    String? fullName,
    String? email,
    String? phone,
    String? department,
    String? designation,
    DateTime? joiningDate,
    String? employmentType,
    String? employmentStatus,
    String? location,
    int? avatarColor,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      joiningDate: joiningDate ?? this.joiningDate,
      employmentType: employmentType ?? this.employmentType,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      location: location ?? this.location,
      avatarColor: avatarColor ?? this.avatarColor,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'joining_date': joiningDate.toIso8601String(),
      'employment_type': employmentType,
      'employment_status': employmentStatus,
      'location': location,
      'avatar_color': avatarColor,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      employeeId: map['employee_id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      department: map['department'] as String,
      designation: map['designation'] as String,
      joiningDate: DateTime.parse(map['joining_date'] as String),
      employmentType: map['employment_type'] as String,
      employmentStatus: map['employment_status'] as String,
      location: map['location'] as String,
      avatarColor: map['avatar_color'] as int,
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() => 'Employee($employeeId, $fullName, $department, $employmentStatus)';
}
