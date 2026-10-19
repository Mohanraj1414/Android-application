import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  // Web and Desktop use 127.0.0.1; Android Emulator uses 10.0.2.2
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // 1. GET ALL EMPLOYEES
  Future<List<Employee>> getAllEmployees({
    String? search,
    String? department,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (department != null && department.isNotEmpty) {
      queryParams['department'] = department;
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/employees').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Employee.fromMap(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load employees from Laravel API: ${response.statusCode}');
    }
  }

  // 2. CREATE EMPLOYEE (POST)
  Future<Employee> createEmployee(Employee employee) async {
    final uri = Uri.parse('$baseUrl/employees');
    final map = employee.toMap();
    // Normalize date for Laravel date column
    map['joining_date'] = employee.joiningDate.toIso8601String().split('T')[0];

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(map),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Employee.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create employee: ${response.body}');
    }
  }

  // 3. UPDATE EMPLOYEE (PUT)
  Future<Employee> updateEmployee(Employee employee) async {
    final uri = Uri.parse('$baseUrl/employees/${employee.id}');
    final map = employee.toMap();
    map['joining_date'] = employee.joiningDate.toIso8601String().split('T')[0];

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(map),
    );

    if (response.statusCode == 200) {
      return Employee.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update employee: ${response.body}');
    }
  }

  // 4. DELETE EMPLOYEE (DELETE)
  Future<bool> deleteEmployee(int id) async {
    final uri = Uri.parse('$baseUrl/employees/$id');
    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json'},
    );
    return response.statusCode == 200;
  }
}
