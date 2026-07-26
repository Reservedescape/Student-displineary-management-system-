import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'constants.dart';

String formatDate(dynamic dateInput) {
  if (dateInput == null) return 'N/A';
  try {
    DateTime date;
    if (dateInput is DateTime) {
      date = dateInput.toLocal();
    } else {
      date = DateTime.parse(dateInput.toString()).toLocal();
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} $month ${date.year}, $hour:$minute $ampm';
  } catch (e) {
    return dateInput.toString();
  }
}

String formatDateOnly(dynamic dateInput) {
  if (dateInput == null) return 'N/A';
  try {
    DateTime date;
    if (dateInput is DateTime) {
      date = dateInput.toLocal();
    } else {
      date = DateTime.parse(dateInput.toString()).toLocal();
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  } catch (e) {
    return dateInput.toString();
  }
}

String timeAgo(dynamic dateInput) {
  if (dateInput == null) return '';
  try {
    DateTime date = dateInput is DateTime
        ? dateInput
        : DateTime.parse(dateInput.toString());
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  } catch (_) {
    return '';
  }
}

Color getCaseStatusColor(CaseStatus status) {
  switch (status) {
    case CaseStatus.open:
      return AppColors.info;
    case CaseStatus.investigating:
      return AppColors.warning;
    case CaseStatus.hearingScheduled:
      return AppColors.primary;
    case CaseStatus.sanctionIssued:
      return AppColors.danger;
    case CaseStatus.appealed:
      return Colors.purple;
    case CaseStatus.closed:
      return AppColors.success;
  }
}

Color getPriorityColor(CasePriority priority) {
  switch (priority) {
    case CasePriority.low:
      return AppColors.info;
    case CasePriority.medium:
      return AppColors.warning;
    case CasePriority.high:
      return Colors.deepOrange;
    case CasePriority.urgent:
      return AppColors.danger;
  }
}