import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/employee_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/main_layout_screen.dart';

/// NEXUS People enterprise root application widget.
class NexusPeopleApp extends StatelessWidget {
  const NexusPeopleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EmployeeProvider()..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'NEXUS People',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayoutScreen(),
      ),
    );
  }
}
