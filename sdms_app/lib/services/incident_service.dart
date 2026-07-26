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
    final payload = {
      'reported_by': isAnonymous ? 'Anonymous' : reportedBy,
      'offender_student_id': offenderStudentId.trim(),
      'offender_name': offenderName.trim(),
      'category': category.label,
      'location': location.trim(),
      'description': description.trim(),
      'is_anonymous': isAnonymous,
    };

    final result = await _client
        .from('incidents')
        .insert(payload)
        .select()
        .single();

    return Incident.fromJson(result);
  }

  Future<List<Incident>> fetchAllIncidents() async {
    try {
      final result = await _client
          .from('incidents')
          .select()
          .order('created_at', ascending: false);

      return (result as List).map((i) => Incident.fromJson(i)).toList();
    } catch (e) {
      print('Error fetching incidents: $e');
      return [];
    }
  }
}
