import '../core/constants.dart';
import 'evidence.dart';

class Incident {
  final int id;
  final String reportedBy;
  final String offenderStudentId;
  final String offenderName;
  final IncidentCategory category;
  final String location;
  final String description;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<EvidenceItem> evidence;

  Incident({
    required this.id,
    required this.reportedBy,
    required this.offenderStudentId,
    required this.offenderName,
    required this.category,
    required this.location,
    required this.description,
    required this.isAnonymous,
    required this.createdAt,
    this.evidence = const [],
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    List<EvidenceItem> evidenceItems = [];
    if (json['evidence'] != null && json['evidence'] is List) {
      evidenceItems = (json['evidence'] as List)
          .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Incident(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reportedBy: json['reported_by']?.toString() ?? 'Anonymous',
      offenderStudentId: json['offender_student_id']?.toString() ?? json['student_id']?.toString() ?? '',
      offenderName: json['offender_name']?.toString() ?? 'Unidentified',
      category: IncidentCategoryExtension.fromString(json['category']?.toString()),
      location: json['location']?.toString() ?? 'Campus Grounds',
      description: json['description']?.toString() ?? '',
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous']?.toString() == 'true',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      evidence: evidenceItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reported_by': reportedBy,
      'offender_student_id': offenderStudentId,
      'offender_name': offenderName,
      'category': category.label,
      'location': location,
      'description': description,
      'is_anonymous': isAnonymous,
      'evidence': evidence.map((e) => e.toJson()).toList(),
    };
  }
}
