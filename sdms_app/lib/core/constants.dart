enum UserRole { student, staff, admin }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.staff:
        return 'staff';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.staff:
        return 'Staff Member';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'staff':
        return UserRole.staff;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

enum IncidentCategory {
  academicDishonesty,
  substancePolicy,
  propertyDamage,
  noiseViolation,
  dressCode,
  misconduct,
  bullyingOrHarassment,
  other,
}

extension IncidentCategoryExtension on IncidentCategory {
  String get label {
    switch (this) {
      case IncidentCategory.academicDishonesty:
        return 'Academic Dishonesty';
      case IncidentCategory.substancePolicy:
        return 'Substance Policy Violation';
      case IncidentCategory.propertyDamage:
        return 'Property Damage';
      case IncidentCategory.noiseViolation:
        return 'Noise & Disruption';
      case IncidentCategory.dressCode:
        return 'Dress Code Violation';
      case IncidentCategory.misconduct:
        return 'General Misconduct';
      case IncidentCategory.bullyingOrHarassment:
        return 'Bullying & Harassment';
      case IncidentCategory.other:
        return 'Other Violation';
    }
  }

  static IncidentCategory fromString(String? cat) {
    if (cat == null) return IncidentCategory.other;
    for (var value in IncidentCategory.values) {
      if (value.label.toLowerCase() == cat.toLowerCase() || value.name.toLowerCase() == cat.toLowerCase()) {
        return value;
      }
    }
    return IncidentCategory.other;
  }
}

enum CasePriority { low, medium, high, urgent }

extension CasePriorityExtension on CasePriority {
  String get label {
    switch (this) {
      case CasePriority.low:
        return 'Low';
      case CasePriority.medium:
        return 'Medium';
      case CasePriority.high:
        return 'High';
      case CasePriority.urgent:
        return 'Urgent';
    }
  }

  static CasePriority fromString(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return CasePriority.urgent;
      case 'high':
        return CasePriority.high;
      case 'medium':
        return CasePriority.medium;
      default:
        return CasePriority.low;
    }
  }
}

enum CaseStatus {
  open,
  investigating,
  hearingScheduled,
  sanctionIssued,
  appealed,
  closed,
}

extension CaseStatusExtension on CaseStatus {
  String get label {
    switch (this) {
      case CaseStatus.open:
        return 'Open / Unassigned';
      case CaseStatus.investigating:
        return 'Under Investigation';
      case CaseStatus.hearingScheduled:
        return 'Hearing Scheduled';
      case CaseStatus.sanctionIssued:
        return 'Sanction Issued';
      case CaseStatus.appealed:
        return 'Under Appeal';
      case CaseStatus.closed:
        return 'Case Closed';
    }
  }

  static CaseStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'investigating':
      case 'under investigation':
        return CaseStatus.investigating;
      case 'hearingscheduled':
      case 'hearing scheduled':
        return CaseStatus.hearingScheduled;
      case 'sanctionissued':
      case 'sanction issued':
        return CaseStatus.sanctionIssued;
      case 'appealed':
      case 'under appeal':
        return CaseStatus.appealed;
      case 'closed':
        return CaseStatus.closed;
      default:
        return CaseStatus.open;
    }
  }
}

enum AppealStatus { pending, approved, denied }

extension AppealStatusExtension on AppealStatus {
  String get label {
    switch (this) {
      case AppealStatus.pending:
        return 'Pending Review';
      case AppealStatus.approved:
        return 'Appeal Approved';
      case AppealStatus.denied:
        return 'Appeal Denied';
    }
  }

  static AppealStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppealStatus.approved;
      case 'denied':
        return AppealStatus.denied;
      default:
        return AppealStatus.pending;
    }
  }
}
