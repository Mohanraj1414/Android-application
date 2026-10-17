import 'package:flutter/material.dart';

/// Department summary metadata and metrics.
class Department {
  final String name;
  final int totalEmployees;
  final int activeEmployees;
  final String leadName;
  final String leadDesignation;
  final String budget;
  final IconData icon;
  final Color color;

  const Department({
    required this.name,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.leadName,
    required this.leadDesignation,
    required this.budget,
    required this.icon,
    required this.color,
  });

  double get activePercentage =>
      totalEmployees == 0 ? 0.0 : (activeEmployees / totalEmployees) * 100;
}
