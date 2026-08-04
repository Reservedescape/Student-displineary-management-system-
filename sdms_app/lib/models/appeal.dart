import '../core/constants.dart';
import 'evidence.dart';

class Appeal {
  final int id;
  final int caseId;
  final String studentId;
  final String reason;
  final AppealStatus status;
  final String? notes;
  final DateTime createdAt;
  final List<EvidenceItem> evidence;

  Appeal({
    required this.id,
    required this.caseId,
    required this.studentId,
    required this.reason,
    required this.status,
    this.notes,
    required this.createdAt,
    this.evidence = const [],
  });

  factory Appeal.fromJson(Map<String, dynamic> json) {
    List<EvidenceItem> evidenceItems = [];
    if (json['evidence'] != null && json['evidence'] is List) {
      evidenceItems = (json['evidence'] as List)
          .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Appeal(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      caseId: json['case_id'] is int ? json['case_id'] : int.tryParse(json['case_id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: AppealStatusExtension.fromString(json['status']?.toString()),
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      evidence: evidenceItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'student_id': studentId,
      'reason': reason,
      'status': status.name,
      'notes': notes,
      'evidence': evidence.map((e) => e.toJson()).toList(),
    };
  }
}
