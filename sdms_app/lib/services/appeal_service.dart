import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appeal.dart';
import '../core/constants.dart';

class AppealService {
  static final SupabaseClient _client = Supabase.instance.client;

  Future<Appeal> submitAppeal({
    required int caseId,
    required String studentId,
    required String reason,
  }) async {
    final payload = {
      'case_id': caseId,
      'student_id': studentId,
      'reason': reason.trim(),
      'status': AppealStatus.pending.name,
    };

    final result = await _client
        .from('appeals')
        .insert(payload)
        .select()
        .single();

    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.appealed.name})
          .eq('id', caseId);
    } catch (_) {}

    return Appeal.fromJson(result);
  }

  Future<List<Map<String, dynamic>>> fetchPendingAppeals() async {
    try {
      final result = await _client
          .from('appeals')
          .select('*, cases(*, incidents(*), sanctions(*))')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching appeals: $e');
      return [];
    }
  }

  Future<void> approveAppeal(int appealId, int caseId) async {
    await _client
        .from('appeals')
        .update({'status': 'approved'})
        .eq('id', appealId);

    try {
      await _client
          .from('cases')
          .update({'status': CaseStatus.closed.name})
          .eq('id', caseId);
    } catch (_) {}
  }

  Future<void> denyAppeal(int appealId, String notes) async {
    await _client.from('appeals').update({
      'status': 'denied',
      'notes': notes.trim(),
    }).eq('id', appealId);
  }
}
