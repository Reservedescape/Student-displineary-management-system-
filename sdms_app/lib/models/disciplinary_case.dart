import '../core/constants.dart';
import 'incident.dart';
import 'hearing.dart';
import 'sanction.dart';
import 'appeal.dart';

class DisciplinaryCase {
  final int id;
  final int incidentId;
  final String studentId;
  final String assignedTo;
  final CasePriority priority;
  final CaseStatus status;
  final DateTime createdAt;

  final Incident? incident;
  final Hearing? hearing;
  final Sanction? sanction;
  final List<Appeal> appeals;

  DisciplinaryCase({
    required this.id,
    required this.incidentId,
    required this.studentId,
    required this.assignedTo,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.incident,
    this.hearing,
    this.sanction,
    this.appeals = const [],
  });

  factory DisciplinaryCase.fromJson(Map<String, dynamic> json) {
    Hearing? hearingObj;
    if (json['hearings'] != null) {
      if (json['hearings'] is List && (json['hearings'] as List).isNotEmpty) {
        final hearingsList = (json['hearings'] as List)
            .map((h) => Hearing.fromJson(h as Map<String, dynamic>))
            .toList();
        hearingsList.sort((a, b) => b.id.compareTo(a.id));
        hearingObj = hearingsList.first;
      } else if (json['hearings'] is Map) {
        hearingObj = Hearing.fromJson(json['hearings']);
      }
    }

    Sanction? sanctionObj;
    if (json['sanctions'] != null) {
      if (json['sanctions'] is List && (json['sanctions'] as List).isNotEmpty) {
        final sanctionsList = (json['sanctions'] as List)
            .map((s) => Sanction.fromJson(s as Map<String, dynamic>))
            .toList();
        sanctionsList.sort((a, b) => b.id.compareTo(a.id));
        sanctionObj = sanctionsList.first;
      } else if (json['sanctions'] is Map) {
        sanctionObj = Sanction.fromJson(json['sanctions']);
      }
    }

    Incident? incidentObj;
    if (json['incidents'] != null) {
      if (json['incidents'] is Map) {
        incidentObj = Incident.fromJson(json['incidents']);
      }
    }

    List<Appeal> appealList = [];
    if (json['appeals'] != null && json['appeals'] is List) {
      appealList = (json['appeals'] as List)
          .map((a) => Appeal.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    // Determine derived case status if not explicitly stored
    CaseStatus derivedStatus = CaseStatusExtension.fromString(json['status']?.toString());
    if (json['status'] == null || json['status'].toString().isEmpty) {
      if (appealList.isNotEmpty) {
        derivedStatus = CaseStatus.appealed;
      } else if (sanctionObj != null) {
        derivedStatus = CaseStatus.sanctionIssued;
      } else if (hearingObj != null) {
        derivedStatus = CaseStatus.hearingScheduled;
      } else if (json['assigned_to'] != null && json['assigned_to'].toString().isNotEmpty) {
        derivedStatus = CaseStatus.investigating;
      } else {
        derivedStatus = CaseStatus.open;
      }
    }

    return DisciplinaryCase(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      incidentId: json['incident_id'] is int ? json['incident_id'] : int.tryParse(json['incident_id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? 'Unassigned',
      priority: CasePriorityExtension.fromString(json['priority']?.toString()),
      status: derivedStatus,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      incident: incidentObj,
      hearing: hearingObj,
      sanction: sanctionObj,
      appeals: appealList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'student_id': studentId,
      'assigned_to': assignedTo,
      'priority': priority.name,
      'status': status.name,
    };
  }

  Appeal? get latestAppeal => appeals.isNotEmpty ? appeals.last : null;
}
