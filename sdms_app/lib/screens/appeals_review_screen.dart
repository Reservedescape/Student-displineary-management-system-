import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../core/formatters.dart';

class AppealsReviewScreen extends StatefulWidget {
  const AppealsReviewScreen({super.key});

  @override
  State<AppealsReviewScreen> createState() => _AppealsReviewScreenState();
}

class _AppealsReviewScreenState extends State<AppealsReviewScreen> {
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
      final result = await Supabase.instance.client
          .from('appeals')
          .select('*, cases(*)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _appeals = List<Map<String, dynamic>>.from(result);
        _loading = false;
      });
    } catch (e) {
      print('ERROR loading appeals: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _approveAppeal(int appealId) async {
    setState(() => _processingIds.add(appealId));
    try {
      await Supabase.instance.client
          .from('appeals')
          .update({'status': 'approved'})
          .eq('id', appealId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appeal approved.')),
        );
      }
      await _loadAppeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not approve appeal. Please try again.')),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deny Appeal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: notesController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Reason for denial',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please explain why this appeal is being denied';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deny', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingIds.add(appealId));
    try {
      await Supabase.instance.client.from('appeals').update({
        'status': 'denied',
        'notes': notesController.text.trim(),
      }).eq('id', appealId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appeal denied.')),
        );
      }
      await _loadAppeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not deny appeal. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(appealId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Pending Appeals'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _appeals.isEmpty
              ? _emptyState('No pending appeals right now.')
              : RefreshIndicator(
                  onRefresh: _loadAppeals,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _appeals.map((a) => _appealCard(a)).toList(),
                  ),
                ),
    );
  }

  Widget _emptyState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget _appealCard(Map<String, dynamic> appeal) {
    final appealId = appeal['id'] as int;
    final caseData = appeal['cases'] as Map<String, dynamic>?;
    final isProcessing = _processingIds.contains(appealId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_outlined, color: AppColors.navy, size: 18),
              const SizedBox(width: 8),
              Text(
                'Case #${caseData?['id'] ?? appeal['case_id']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.inputText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Student: ${appeal['student_id'] ?? 'Unknown'}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            formatDate(appeal['created_at']),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              appeal['reason'] ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.inputText),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : () => _denyAppeal(appealId),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Deny', style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : () => _approveAppeal(appealId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}