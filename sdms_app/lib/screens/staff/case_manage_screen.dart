import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/disciplinary_case.dart';
import '../../services/case_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/priority_badge.dart';

class CaseManageScreen extends StatefulWidget {
  final DisciplinaryCase caseData;

  const CaseManageScreen({super.key, required this.caseData});

  @override
  State<CaseManageScreen> createState() => _CaseManageScreenState();
}

class _CaseManageScreenState extends State<CaseManageScreen> {
  final CaseService _caseService = CaseService();
  final _venueController = TextEditingController();
  final _hearingNotesController = TextEditingController();

  final _sanctionTypeController = TextEditingController();
  final _sanctionNotesController = TextEditingController();

  DateTime? _selectedHearingDate;
  DateTime? _sanctionStart;
  DateTime? _sanctionEnd;

  bool _savingHearing = false;
  bool _savingSanction = false;
  late DisciplinaryCase _currentCase;

  @override
  void initState() {
    super.initState();
    _currentCase = widget.caseData;
    _venueController.text = _currentCase.hearing?.venue ?? 'Dean of Students Office';
    _sanctionTypeController.text = _currentCase.sanction?.sanctionType ?? 'Formal Written Warning';
  }

  @override
  void dispose() {
    _venueController.dispose();
    _hearingNotesController.dispose();
    _sanctionTypeController.dispose();
    _sanctionNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickHearingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date != null) {
      setState(() => _selectedHearingDate = date);
    }
  }

  Future<void> _saveHearing() async {
    if (_selectedHearingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for the hearing.')),
      );
      return;
    }

    setState(() => _savingHearing = true);

    try {
      await _caseService.scheduleHearing(
        caseId: _currentCase.id,
        studentId: _currentCase.studentId,
        hearingDate: _selectedHearingDate!,
        venue: _venueController.text.trim(),
        committeeNotes: _hearingNotesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disciplinary hearing scheduled successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
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
        const SnackBar(content: Text('Please specify sanction type.')),
      );
      return;
    }

    setState(() => _savingSanction = true);

    try {
      await _caseService.recordSanction(
        caseId: _currentCase.id,
        studentId: _currentCase.studentId,
        sanctionType: _sanctionTypeController.text.trim(),
        startDate: _sanctionStart,
        endDate: _sanctionEnd,
        notes: _sanctionNotesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sanction recorded & student notified.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record sanction: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingSanction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Case #${_currentCase.id} Resolution'),
        backgroundColor: AppColors.navy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCaseOverviewCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Step 1: Hearing Scheduling', Icons.calendar_month),
            const SizedBox(height: 12),
            _currentCase.hearing != null
                ? _buildExistingHearingCard()
                : _buildHearingFormCard(),
            const SizedBox(height: 28),
            _buildSectionHeader('Step 2: Issue Sanction / Ruling', Icons.gavel),
            const SizedBox(height: 12),
            _currentCase.sanction != null
                ? _buildExistingSanctionCard()
                : _buildSanctionFormCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: AppColors.navy, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );

  Widget _buildCaseOverviewCard() => Container(
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
                Text(
                  'Student ID: ${_currentCase.studentId.isNotEmpty ? _currentCase.studentId : 'N/A'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                PriorityBadge(priority: _currentCase.priority),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Current Status: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                StatusBadge(status: _currentCase.status, compact: true),
              ],
            ),
            if (_currentCase.incident != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Category: ${_currentCase.incident!.category.label}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Description: ${_currentCase.incident!.description}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      );

  Widget _buildExistingHearingCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Hearing Date: ${formatDate(_currentCase.hearing!.hearingDate)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Venue: ${_currentCase.hearing!.venue}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _buildHearingFormCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: _pickHearingDate,
              icon: const Icon(Icons.event, size: 18),
              label: Text(
                _selectedHearingDate == null
                    ? 'Pick Hearing Date & Time'
                    : 'Selected: ${formatDateOnly(_selectedHearingDate!)}',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue / Room',
                hintText: 'e.g. Dean of Students Office Boardroom',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hearingNotesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Committee Agenda / Notes (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _savingHearing ? null : _saveHearing,
                icon: _savingHearing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.schedule, size: 18),
                label: Text(_savingHearing ? 'Saving...' : 'Schedule Hearing'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
              ),
            ),
          ],
        ),
      );

  Widget _buildExistingSanctionCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gpp_bad, color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Sanction: ${_currentCase.sanction!.sanctionType}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger),
                ),
              ],
            ),
            if (_currentCase.sanction!.notes != null) ...[
              const SizedBox(height: 4),
              Text(_currentCase.sanction!.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      );

  Widget _buildSanctionFormCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _sanctionTypeController,
              decoration: const InputDecoration(
                labelText: 'Sanction Type',
                hintText: 'e.g. Formal Warning, Suspension (1 Term), Disciplinary Probation',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickSanctionDate(isStart: true),
                    icon: const Icon(Icons.calendar_today, size: 14),
                    label: Text(
                      _sanctionStart == null ? 'Start Date' : formatDateOnly(_sanctionStart!),
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
                      _sanctionEnd == null ? 'End Date' : formatDateOnly(_sanctionEnd!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sanctionNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Sanction Ruling Details & Conditions',
                hintText: 'Specify mandatory requirements (e.g. Community service hours, counseling)...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _savingSanction ? null : _saveSanction,
                icon: _savingSanction
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_savingSanction ? 'Saving...' : 'Record Sanction'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
          ],
        ),
      );
}
