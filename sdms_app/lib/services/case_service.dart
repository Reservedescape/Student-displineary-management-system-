import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/disciplinary_case.dart';
import '../models/incident.dart';
import '../models/hearing.dart';
import '../models/sanction.dart';
import '../core/constants.dart';

class CaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final List<DisciplinaryCase> _localCases = [];

  Future<DisciplinaryCase> createAndAssignCase({
    required int incidentId,
    required String studentId,
    required String assignedToStaff,
    CasePriority priority = CasePriority.medium,
    Incident? incident,
  }) async {
    final payload = {
      'incident_id': incidentId,
      'student_id': studentId,
      'assigned_to': assignedToStaff,
      'priority': priority.name,
      'status': CaseStatus.investigating.name,
    };

    Map<String, dynamic>? result;

    try {
      result = await _client
          .from('cases')
          .insert(payload)
          .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
          .maybeSingle();
    } catch (_) {
      try {
        await _client.from('cases').insert(payload);
      } catch (_) {}
    }

    final newCase = result != null
        ? DisciplinaryCase.fromJson(result)
        : DisciplinaryCase(
            id: DateTime.now().millisecondsSinceEpoch,
            incidentId: incidentId,
            studentId: studentId,
            assignedTo: assignedToStaff,
            priority: priority,
            status: CaseStatus.investigating,
            createdAt: DateTime.now(),
            incident: incident,
          );

    _localCases.removeWhere((c) => c.id == newCase.id);
    _localCases.insert(0, newCase);

    return newCase;
  }

  Future<List<DisciplinaryCase>> fetchCasesForStudent(String studentId) async {
    final all = await fetchAllCases();
    final query = studentId.trim().toLowerCase();

    return all.where((c) {
      if (query.isEmpty) return true;
      final sid = c.studentId.trim().toLowerCase();
      return sid == query || sid == 'unknown' || sid.contains(query) || query.contains(sid);
    }).toList();
  }

  Future<List<DisciplinaryCase>> fetchCasesForStaff(String staffFullName) async {
    final all = await fetchAllCases();
    final query = staffFullName.trim().toLowerCase();

    return all.where((c) {
      final assigned = c.assignedTo.trim().toLowerCase();
      if (assigned.isEmpty || assigned == 'unassigned') return false;
      return assigned == query ||
          assigned.contains(query) ||
          query.contains(assigned) ||
          query.isEmpty ||
          query.contains('staff') ||
          query.contains('admin');
    }).toList();
  }

  Future<List<DisciplinaryCase>> fetchAllCases() async {
    try {
      final result = await _client
          .from('cases')
          .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
          .order('created_at', ascending: false);

      final remoteCases = (result as List).map((c) => DisciplinaryCase.fromJson(c)).toList();
      final Map<int, DisciplinaryCase> map = {};
      for (var c in _localCases) {
        map[c.id] = c;
      }
      for (var c in remoteCases) {
        map[c.id] = c;
      }
      final merged = map.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    } catch (_) {
      return List<DisciplinaryCase>.from(_localCases);
    }
  }

  Future<Hearing> scheduleHearing({
    required int caseId,
    required String studentId,
    required DateTime hearingDate,
    required String venue,
    String? committeeNotes,
  }) async {
    final payload = {
      'case_id': caseId,
      'student_id': studentId,
      'hearing_date': hearingDate.toIso8601String(),
      'venue': venue,
      'status': 'scheduled',
      'committee_notes': committeeNotes,
    };

    Map<String, dynamic>? result;

    try {
      result = await _client
          .from('hearings')
          .insert(payload)
          .select()
          .maybeSingle();
    } catch (_) {
      try {
        await _client.from('hearings').insert(payload);
      } catch (_) {}
    }

    // Update status on cases table if column exists
    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.hearingScheduled.name})
          .eq('id', caseId);
    } catch (_) {}

    if (result != null) {
      return Hearing.fromJson(result);
    }

    return Hearing(
      id: DateTime.now().millisecondsSinceEpoch,
      caseId: caseId,
      studentId: studentId,
      hearingDate: hearingDate,
      venue: venue,
      status: 'scheduled',
      committeeNotes: committeeNotes,
    );
  }

  Future<Sanction> recordSanction({
    required int caseId,
    required String studentId,
    required String sanctionType,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final payload = {
      'case_id': caseId,
      'student_id': studentId,
      'sanction_type': sanctionType,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
    };

    Map<String, dynamic>? result;

    try {
      result = await _client
          .from('sanctions')
          .insert(payload)
          .select()
          .maybeSingle();
    } catch (_) {
      try {
        await _client.from('sanctions').insert(payload);
      } catch (_) {}
    }

    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.sanctionIssued.name})
          .eq('id', caseId);
    } catch (_) {}

    if (result != null) {
      return Sanction.fromJson(result);
    }

    return Sanction(
      id: DateTime.now().millisecondsSinceEpoch,
      caseId: caseId,
      studentId: studentId,
      sanctionType: sanctionType,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );
  }
}
