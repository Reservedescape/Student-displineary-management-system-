import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident.dart';
import '../core/constants.dart';

class IncidentService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final List<Incident> _localIncidents = [];

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

    final newIncident = result != null
        ? Incident.fromJson(result)
        : Incident(
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

    _localIncidents.removeWhere((i) => i.id == newIncident.id);
    _localIncidents.insert(0, newIncident);

    return newIncident;
  }

  Future<List<Incident>> fetchAllIncidents() async {
    try {
      final result = await _client
          .from('incidents')
          .select()
          .order('created_at', ascending: false);

      final remoteIncidents = (result as List).map((i) => Incident.fromJson(i)).toList();

      final Map<int, Incident> map = {};
      for (var inc in _localIncidents) {
        map[inc.id] = inc;
      }
      for (var inc in remoteIncidents) {
        map[inc.id] = inc;
      }

      final merged = map.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    } catch (_) {
      return List<Incident>.from(_localIncidents);
    }
  }
}
