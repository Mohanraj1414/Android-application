import 'package:intl/intl.dart';

/// Clean, localized date formatting utilities for enterprise records.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _standardDate = DateFormat('dd MMM yyyy');
  static final DateFormat _headerDate = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _timestamp = DateFormat('dd MMM yyyy, hh:mm a');

  /// Formats date as '15 Oct 2024'
  static String format(DateTime? date) {
    if (date == null) return 'N/A';
    return _standardDate.format(date);
  }

  /// Formats date for dashboard executive header 'Saturday, October 17, 2026'
  static String formatHeader(DateTime date) {
    return _headerDate.format(date);
  }

  /// Formats date as 'Oct 2024'
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Formats date with time '15 Oct 2024, 02:45 PM'
  static String formatTimestamp(DateTime? date) {
    if (date == null) return 'N/A';
    return _timestamp.format(date);
  }

  /// Calculates human-readable enterprise tenure string:
  /// e.g. "3 yrs, 5 mos" or "4 mos" or "< 1 mo"
  static String calculateTenure(DateTime joiningDate) {
    final now = DateTime.now();
    int years = now.year - joiningDate.year;
    int months = now.month - joiningDate.month;
    if (now.day < joiningDate.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years <= 0 && months <= 0) {
      return '< 1 month';
    } else if (years <= 0) {
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (months == 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else {
      return '$years ${years == 1 ? 'yr' : 'yrs'}, $months ${months == 1 ? 'mo' : 'mos'}';
    }
  }

  /// Human-friendly relative time (e.g., "5 mins ago", "2 hours ago", "Yesterday")
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return format(dateTime);
    }
  }
}
