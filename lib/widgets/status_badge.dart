import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Polished status badge widget adhering to enterprise visual standards.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    Color dot;

    switch (status.toLowerCase()) {
      case 'active':
        bg = AppColors.successBg;
        border = AppColors.successBorder;
        text = AppColors.successDark;
        dot = AppColors.success;
        break;
      case 'on leave':
        bg = AppColors.warningBg;
        border = AppColors.warningBorder;
        text = AppColors.warningDark;
        dot = AppColors.warning;
        break;
      case 'probation':
        bg = AppColors.infoBg;
        border = AppColors.infoBorder;
        text = AppColors.infoDark;
        dot = AppColors.info;
        break;
      case 'terminated':
        bg = AppColors.dangerBg;
        border = AppColors.dangerBorder;
        text = AppColors.dangerDark;
        dot = AppColors.danger;
        break;
      // Employment Types
      case 'full-time':
        bg = AppColors.primaryLight;
        border = AppColors.primaryMuted;
        text = AppColors.primary;
        dot = AppColors.primary;
        break;
      case 'part-time':
      case 'contract':
      case 'intern':
        bg = AppColors.surfaceSubtle;
        border = AppColors.border;
        text = AppColors.navyLight;
        dot = AppColors.textMuted;
        break;
      default:
        bg = AppColors.surfaceSubtle;
        border = AppColors.border;
        text = AppColors.textSecondary;
        dot = AppColors.textMuted;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 7,
            height: isCompact ? 6 : 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
