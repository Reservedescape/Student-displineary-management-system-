import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../services/appeal_service.dart';
import '../../widgets/empty_state_widget.dart';

class AppealsReviewScreen extends StatefulWidget {
  const AppealsReviewScreen({super.key});

  @override
  State<AppealsReviewScreen> createState() => _AppealsReviewScreenState();
}

class _AppealsReviewScreenState extends State<AppealsReviewScreen> {
  final AppealService _appealService = AppealService();
  bool _loading = true;
  List<Map<String, dynamic>> _appeals = [];
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadAppeals();
  }

  Future<void> _loadAppeals() async {
    setState(() => _loading = true);
    try {
      final list = await _appealService.fetchPendingAppeals();
      setState(() {
        _appeals = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveAppeal(int appealId, int caseId) async {
    setState(() => _processingIds.add(appealId));
    try {
      await _appealService.approveAppeal(appealId, caseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appeal approved & case closed.'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadAppeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(appealId));
    }
  }

  Future<void> _denyAppeal(int appealId) async {
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Deny Student Appeal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: notesController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Official Reason / VC Board Remarks',
              hintText: 'State why the appeal is denied...',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please explain reason' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogCtx, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirm Denial', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingIds.add(appealId));
    try {
      await _appealService.denyAppeal(appealId, notesController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appeal denied.'),
          backgroundColor: AppColors.info,
        ),
      );
      _loadAppeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to deny: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(appealId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VC Appeals Review Board'),
        backgroundColor: AppColors.navy,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _appeals.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.rate_review_outlined,
                  title: 'No Pending Appeals',
                  message: 'There are currently no student appeals awaiting board deliberation.',
                )
              : RefreshIndicator(
                  onRefresh: _loadAppeals,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appeals.length,
                    itemBuilder: (ctx, index) => _buildAppealCard(_appeals[index]),
                  ),
                ),
    );
  }

  Widget _buildAppealCard(Map<String, dynamic> appeal) {
    final appealId = appeal['id'] as int;
    final caseId = appeal['case_id'] as int;
    final isProcessing = _processingIds.contains(appealId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Case #$caseId',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              Text(
                formatDate(appeal['created_at']),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Appellant Student ID: ${appeal['student_id'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Grounds for Appeal:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  appeal['reason'] ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : () => _denyAppeal(appealId),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Deny Appeal', style: TextStyle(color: AppColors.danger)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : () => _approveAppeal(appealId, caseId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: isProcessing
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : const Text('Approve Appeal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
