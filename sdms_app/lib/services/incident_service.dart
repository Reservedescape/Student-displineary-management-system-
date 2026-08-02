import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident.dart';
import '../core/constants.dart';

class IncidentService {
  static final SupabaseClient _client = Supabase.instance.client;

  Future<Incident> reportIncident({
    required String reportedBy,
    required String offenderStudentId,
    required String offenderName,
    required IncidentCategory category,
    required String location,
    required String description,
    required bool isAnonymous,
  }) async {
    final finalOffenderId = offenderStudentId.trim().isEmpty ? 'Unknown' : offenderStudentId.trim();
    final finalOffenderName = offenderName.trim().isEmpty ? 'Unidentified' : offenderName.trim();
    final finalReportedBy = isAnonymous ? 'Anonymous' : (reportedBy.trim().isEmpty ? 'Anonymous' : reportedBy.trim());

    final payload = {
      'reported_by': finalReportedBy,
      'offender_student_id': finalOffenderId,
      'offender_name': finalOffenderName,
      'category': category.label,
      'location': location.trim(),
      'description': description.trim(),
      'is_anonymous': isAnonymous,
    };

    Map<String, dynamic>? result;

    try {
      result = await _client
          .from('incidents')
          .insert(payload)
          .select()
          .maybeSingle();
    } catch (_) {
      try {
        await _client.from('incidents').insert(payload);
      } catch (_) {}
    }

    if (result != null) {
      return Incident.fromJson(result);
    }

    return Incident(
      id: DateTime.now().millisecondsSinceEpoch,
      reportedBy: finalReportedBy,
      offenderStudentId: finalOffenderId,
      offenderName: finalOffenderName,
      category: category,
      location: location.trim(),
      description: description.trim(),
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Incident>> fetchAllIncidents() async {
    try {
      final result = await _client
          .from('incidents')
          .select()
          .order('created_at', ascending: false);

      return (result as List).map((i) => Incident.fromJson(i)).toList();
    } catch (_) {
      return [];
    }
  }
}
