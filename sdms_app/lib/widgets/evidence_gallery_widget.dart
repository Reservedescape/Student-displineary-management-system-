import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/evidence.dart';

class EvidenceGalleryWidget extends StatelessWidget {
  final List<EvidenceItem> evidenceItems;
  final String title;

  const EvidenceGalleryWidget({
    super.key,
    required this.evidenceItems,
    this.title = 'Attached Evidence (Photos & Videos)',
  });

  void _previewMedia(BuildContext context, EvidenceItem item) {
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
    if (evidenceItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.perm_media_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${evidenceItems.length} file(s)',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: evidenceItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = evidenceItems[index];
                return GestureDetector(
                  onTap: () => _previewMedia(context, item),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.isVideo
                          ? AppColors.navy.withOpacity(0.06)
                          : AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.isVideo
                            ? AppColors.navy.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.isVideo ? AppColors.navy : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            item.isVideo ? Icons.play_arrow : Icons.image,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.fileName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.isVideo ? 'Video Clip' : 'Photo Image',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: item.isVideo ? AppColors.navy : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
