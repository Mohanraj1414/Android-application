import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Professional corporate avatar widget with status dot indicator.
class AvatarWidget extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final double size;
  final String? status; // 'Active', 'On Leave', 'Probation', 'Terminated'
  final bool showStatus;

  const AvatarWidget({
    super.key,
    required this.initials,
    required this.backgroundColor,
    this.size = 40,
    this.status,
    this.showStatus = false,
  });

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'on leave':
        return AppColors.warning;
      case 'probation':
        return AppColors.info;
      case 'terminated':
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: size > 48 ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (showStatus && status != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
