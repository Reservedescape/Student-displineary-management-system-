class Hearing {
  final int id;
  final int caseId;
  final String studentId;
  final DateTime hearingDate;
  final String venue;
  final String status;
  final String? committeeNotes;
  final String? plea;

  Hearing({
    required this.id,
    required this.caseId,
    required this.studentId,
    required this.hearingDate,
    required this.venue,
    required this.status,
    this.committeeNotes,
    this.plea,
  });

  factory Hearing.fromJson(Map<String, dynamic> json) {
    return Hearing(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      caseId: json['case_id'] is int ? json['case_id'] : int.tryParse(json['case_id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      hearingDate: DateTime.tryParse(json['hearing_date']?.toString() ?? '') ?? DateTime.now(),
      venue: json['venue']?.toString() ?? 'Disciplinary Office',
      status: json['status']?.toString() ?? 'scheduled',
      committeeNotes: json['committee_notes']?.toString(),
      plea: json['plea']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'student_id': studentId,
      'hearing_date': hearingDate.toIso8601String(),
      'venue': venue,
      'status': status,
      'committee_notes': committeeNotes,
      'plea': plea,
    };
  }
}
