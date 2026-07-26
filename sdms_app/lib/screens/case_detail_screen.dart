import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../core/formatters.dart';

class CaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const CaseDetailScreen({super.key, required this.caseData});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _hearing;
  Map<String, dynamic>? _sanction;

  final _venueController = TextEditingController();
  DateTime? _selectedHearingDate;

  final _sanctionTypeController = TextEditingController();
  final _sanctionNotesController = TextEditingController();
  DateTime? _sanctionStart;
  DateTime? _sanctionEnd;

  bool _savingHearing = false;
  bool _savingSanction = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _venueController.dispose();
    _sanctionTypeController.dispose();
    _sanctionNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() => _loading = true);
    try {
      final hearingResult = await Supabase.instance.client
          .from('hearings')
          .select()
          .eq('case_id', widget.caseData['id'])
          .maybeSingle();

      final sanctionResult = await Supabase.instance.client
          .from('sanctions')
          .select()
          .eq('case_id', widget.caseData['id'])
          .maybeSingle();

      setState(() {
        _hearing = hearingResult;
        _sanction = sanctionResult;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickHearingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedHearingDate = date);
    }
  }

  Future<void> _saveHearing() async {
    if (_selectedHearingDate == null || _venueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and enter a venue.')),
      );
      return;
    }
    setState(() => _savingHearing = true);
    try {
      await Supabase.instance.client.from('hearings').insert({
        'case_id': widget.caseData['id'],
        'student_id': widget.caseData['student_id'],
        'hearing_date': _selectedHearingDate!.toIso8601String(),
        'venue': _venueController.text.trim(),
        'status': 'scheduled',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hearing scheduled.')),
        );
      }
      await _loadDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not schedule hearing.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingHearing = false);
    }
  }

  Future<void> _pickSanctionDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _sanctionStart = date;
        } else {
          _sanctionEnd = date;
        }
      });
    }
  }

  Future<void> _saveSanction() async {
    if (_sanctionTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sanction type.')),
      );
      return;
    }
    setState(() => _savingSanction = true);
    try {
      await Supabase.instance.client.from('sanctions').insert({
        'case_id': widget.caseData['id'],
        'student_id': widget.caseData['student_id'],
        'sanction_type': _sanctionTypeController.text.trim(),
        'start_date': _sanctionStart?.toIso8601String(),
        'end_date': _sanctionEnd?.toIso8601String(),
        'notes': _sanctionNotesController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sanction recorded.')),
        );
      }
      await _loadDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not record sanction.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingSanction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(
          'Case #${widget.caseData['id']}',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student ID: ${widget.caseData['student_id'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14, color: AppColors.inputText),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Hearing'),
                  const SizedBox(height: 10),
                  _hearing != null ? _hearingSummary() : _hearingForm(),
                  const SizedBox(height: 28),
                  _sectionTitle('Disciplinary action'),
                  const SizedBox(height: 10),
                  _hearing == null
                      ? _emptyState('Schedule a hearing before recording a disciplinary action.')
                      : (_sanction != null ? _sanctionSummary() : _sanctionForm()),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Row(
    children: [
      Icon(
        title == 'Hearing' ? Icons.balance : Icons.gpp_bad_outlined,
        color: AppColors.navy,
        size: 18,
      ),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.inputText)),
    ],
  );

  Widget _emptyState(String message) => Container(
    padding: const EdgeInsets.all(16),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      message,
      style: const TextStyle(fontSize: 13, color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  );

  Widget _hearingSummary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date: ${formatDate(_hearing?['hearing_date'])}', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text('Venue: ${_hearing?['venue'] ?? '-'}', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text('Status: ${_hearing?['status'] ?? '-'}', style: const TextStyle(fontSize: 13)),
      ],
    ),
  );

  Widget _hearingForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton.icon(
        onPressed: _pickHearingDate,
        icon: const Icon(Icons.calendar_today, size: 16),
        label: Text(
          _selectedHearingDate == null
              ? 'Pick hearing date'
              : '${_selectedHearingDate!.day}/${_selectedHearingDate!.month}/${_selectedHearingDate!.year}',
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _venueController,
        decoration: InputDecoration(
          hintText: 'Venue (e.g. Dean\'s Office)',
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _savingHearing ? null : _saveHearing,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _savingHearing
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
              : const Text('Schedule hearing', style: TextStyle(color: AppColors.white)),
        ),
      ),
    ],
  );

  Widget _sanctionSummary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: ${_sanction?['sanction_type'] ?? '-'}', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text('Start: ${formatDate(_sanction?['start_date'])}', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text('End: ${formatDate(_sanction?['end_date'])}', style: const TextStyle(fontSize: 13)),
        if ((_sanction?['notes'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Notes: ${_sanction?['notes']}', style: const TextStyle(fontSize: 13)),
        ],
      ],
    ),
  );

  Widget _sanctionForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _sanctionTypeController,
        decoration: InputDecoration(
          hintText: 'Sanction type (e.g. Written warning)',
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickSanctionDate(isStart: true),
              icon: const Icon(Icons.calendar_today, size: 14),
              label: Text(
                _sanctionStart == null
                    ? 'Start date'
                    : '${_sanctionStart!.day}/${_sanctionStart!.month}/${_sanctionStart!.year}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickSanctionDate(isStart: false),
              icon: const Icon(Icons.calendar_today, size: 14),
              label: Text(
                _sanctionEnd == null
                    ? 'End date'
                    : '${_sanctionEnd!.day}/${_sanctionEnd!.month}/${_sanctionEnd!.year}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _sanctionNotesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Notes (optional)',
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _savingSanction ? null : _saveSanction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _savingSanction
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
              : const Text('Record sanction', style: TextStyle(color: AppColors.white)),
        ),
      ),
    ],
  );
}