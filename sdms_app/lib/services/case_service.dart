import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/disciplinary_case.dart';
import '../models/hearing.dart';
import '../models/sanction.dart';
import '../core/constants.dart';

class CaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  Future<DisciplinaryCase> createAndAssignCase({
    required int incidentId,
    required String studentId,
    required String assignedToStaff,
    CasePriority priority = CasePriority.medium,
  }) async {
    final payload = {
      'incident_id': incidentId,
      'student_id': studentId,
      'assigned_to': assignedToStaff,
      'priority': priority.name,
      'status': CaseStatus.investigating.name,
    };

    final result = await _client
        .from('cases')
        .insert(payload)
        .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
        .single();

    return DisciplinaryCase.fromJson(result);
  }

  Future<List<DisciplinaryCase>> fetchCasesForStudent(String studentId) async {
    try {
      final result = await _client
          .from('cases')
          .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return (result as List).map((c) => DisciplinaryCase.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching student cases: $e');
      return [];
    }
  }

  Future<List<DisciplinaryCase>> fetchCasesForStaff(String staffFullName) async {
    try {
      final result = await _client
          .from('cases')
          .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
          .eq('assigned_to', staffFullName)
          .order('created_at', ascending: false);

      return (result as List).map((c) => DisciplinaryCase.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching staff cases: $e');
      return [];
    }
  }

  Future<List<DisciplinaryCase>> fetchAllCases() async {
    try {
      final result = await _client
          .from('cases')
          .select('*, hearings(*), sanctions(*), appeals(*), incidents(*)')
          .order('created_at', ascending: false);

      return (result as List).map((c) => DisciplinaryCase.fromJson(c)).toList();
    } catch (e) {
      print('Error fetching all cases: $e');
      return [];
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

    final result = await _client
        .from('hearings')
        .insert(payload)
        .select()
        .single();

    // Update status on cases table if column exists
    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.hearingScheduled.name})
          .eq('id', caseId);
    } catch (_) {}

    return Hearing.fromJson(result);
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

    final result = await _client
        .from('sanctions')
        .insert(payload)
        .select()
        .single();

    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.sanctionIssued.name})
          .eq('id', caseId);
    } catch (_) {}

    return Sanction.fromJson(result);
  }
}
