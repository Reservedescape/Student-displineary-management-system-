class EvidenceItem {
  final String id;
  final String fileName;
  final String fileType; // 'photo' or 'video'
  final String fileUrl;
  final String? thumbnailUrl;
  final String? description;
  final String? fileSize;
  final DateTime uploadedAt;

  EvidenceItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    this.thumbnailUrl,
    this.description,
    this.fileSize,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  bool get isVideo => fileType.toLowerCase() == 'video';
  bool get isPhoto => fileType.toLowerCase() == 'photo' || fileType.toLowerCase() == 'image';

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: json['file_name']?.toString() ?? json['fileName']?.toString() ?? 'attachment',
      fileType: json['file_type']?.toString() ?? json['fileType']?.toString() ?? 'photo',
      fileUrl: json['file_url']?.toString() ?? json['fileUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? json['thumbnailUrl']?.toString(),
      description: json['description']?.toString(),
      fileSize: json['file_size']?.toString() ?? json['fileSize']?.toString(),
      uploadedAt: DateTime.tryParse(json['uploaded_at']?.toString() ?? json['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'description': description,
      'file_size': fileSize,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
