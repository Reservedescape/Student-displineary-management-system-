import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/evidence.dart';

class EvidenceUploadWidget extends StatefulWidget {
  final List<EvidenceItem> evidenceList;
  final ValueChanged<List<EvidenceItem>> onChanged;

  const EvidenceUploadWidget({
    super.key,
    required this.evidenceList,
    required this.onChanged,
  });

  @override
  State<EvidenceUploadWidget> createState() => _EvidenceUploadWidgetState();
}

class _EvidenceUploadWidgetState extends State<EvidenceUploadWidget> {
  final _captionController = TextEditingController();
  final _fileNameController = TextEditingController();

  void _addSampleMedia(String defaultName, String type, String size, String defaultUrl) {
    _fileNameController.text = defaultName;
    _captionController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                type == 'video' ? Icons.videocam_outlined : Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                type == 'video' ? 'Attach Video Evidence' : 'Attach Photo Evidence',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select standard evidence item or provide custom file details:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preset ${type == 'video' ? 'Video' : 'Photo'} Samples:',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: type == 'video'
                      ? [
                          _buildPresetChip('CCTV_Hallway_Footage.mp4', 'video', '18.4 MB'),
                          _buildPresetChip('Library_Incident_Video.mp4', 'video', '12.1 MB'),
                          _buildPresetChip('Witness_Statement_Video.mov', 'video', '24.5 MB'),
                        ]
                      : [
                          _buildPresetChip('Damaged_Property_Photo_1.jpg', 'photo', '3.2 MB'),
                          _buildPresetChip('Student_ID_Evidence_Scan.png', 'photo', '1.8 MB'),
                          _buildPresetChip('Noticeboard_Snapshot.jpg', 'photo', '2.5 MB'),
                        ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fileNameController,
                  decoration: InputDecoration(
                    labelText: 'File Name / Identifier',
                    hintText: type == 'video' ? 'e.g. CCTV_Footage.mp4' : 'e.g. Evidence_Photo.jpg',
                    prefixIcon: Icon(
                      type == 'video' ? Icons.movie_outlined : Icons.image_outlined,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    labelText: 'Description / Note (Optional)',
                    hintText: 'e.g. Shows timestamp and location near library entrance...',
                    prefixIcon: Icon(Icons.description_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = _fileNameController.text.trim().isEmpty
                    ? defaultName
                    : _fileNameController.text.trim();
                final desc = _captionController.text.trim();

                final newItem = EvidenceItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  fileName: name,
                  fileType: type,
                  fileUrl: defaultUrl,
                  thumbnailUrl: type == 'photo' ? defaultUrl : null,
                  fileSize: size,
                  description: desc.isNotEmpty ? desc : null,
                  uploadedAt: DateTime.now(),
                );

                final updated = List<EvidenceItem>.from(widget.evidenceList)..add(newItem);
                widget.onChanged(updated);
                Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('Add Evidence'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresetChip(String name, String type, String size) {
    return ActionChip(
      avatar: Icon(
        type == 'video' ? Icons.play_circle_fill : Icons.image,
        size: 16,
        color: AppColors.primary,
      ),
      label: Text(name, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        setState(() {
          _fileNameController.text = name;
        });
      },
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.cardBorder),
    );
  }

  void _removeEvidence(int index) {
    final updated = List<EvidenceItem>.from(widget.evidenceList)..removeAt(index);
    widget.onChanged(updated);
  }

  void _previewMedia(EvidenceItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            item.isVideo ? Icons.movie : Icons.image,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.fileName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (item.isPhoto)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo, size: 64, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(
                                item.fileName,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Video Evidence Player',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: 00:45 • ${item.fileSize ?? '15 MB'}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Notes: ${item.description}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Attach Evidence (Photos & Videos)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.evidenceList.length} Files',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Add photos of damaged property, document scans, or video recordings to support your case.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Upload Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addSampleMedia(
                    'Evidence_Photo.jpg',
                    'photo',
                    '2.8 MB',
                    'assets/sample_photo.jpg',
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Add Photo',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addSampleMedia(
                    'Security_Footage.mp4',
                    'video',
                    '14.5 MB',
                    'assets/sample_video.mp4',
                  ),
                  icon: const Icon(Icons.video_call_outlined, size: 18, color: AppColors.navy),
                  label: const Text(
                    'Add Video',
                    style: TextStyle(fontSize: 12, color: AppColors.navy),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.navy),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),

          // Attached Items Grid/List
          if (widget.evidenceList.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.evidenceList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.evidenceList[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.isVideo
                              ? AppColors.navy.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.isVideo ? Icons.videocam : Icons.image,
                          color: item.isVideo ? AppColors.navy : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.fileName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.isVideo
                                        ? AppColors.navy.withOpacity(0.1)
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isVideo ? 'VIDEO' : 'PHOTO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: item.isVideo ? AppColors.navy : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Size: ${item.fileSize ?? 'Unknown'} ${item.description != null ? '• ${item.description}' : ''}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.info),
                        onPressed: () => _previewMedia(item),
                        tooltip: 'Preview Media',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                        onPressed: () => _removeEvidence(index),
                        tooltip: 'Remove Attachment',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
