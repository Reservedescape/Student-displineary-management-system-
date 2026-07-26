class Sanction {
  final int id;
  final int caseId;
  final String studentId;
  final String sanctionType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  Sanction({
    required this.id,
    required this.caseId,
    required this.studentId,
    required this.sanctionType,
    this.startDate,
    this.endDate,
    this.notes,
  });

  factory Sanction.fromJson(Map<String, dynamic> json) {
    return Sanction(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      caseId: json['case_id'] is int ? json['case_id'] : int.tryParse(json['case_id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      sanctionType: json['sanction_type']?.toString() ?? 'Formal Warning',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'student_id': studentId,
      'sanction_type': sanctionType,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
