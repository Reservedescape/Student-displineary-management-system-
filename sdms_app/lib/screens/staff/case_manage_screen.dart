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
  bool _isEditingHearing = false;
  bool _isEditingSanction = false;

  late DisciplinaryCase _currentCase;

  @override
  void initState() {
    super.initState();
    _currentCase = widget.caseData;
    _venueController.text = _currentCase.hearing?.venue ?? 'Dean of Students Office';
    _hearingNotesController.text = _currentCase.hearing?.committeeNotes ?? '';
    _sanctionTypeController.text = _currentCase.sanction?.sanctionType ?? 'Formal Written Warning';
    _sanctionNotesController.text = _currentCase.sanction?.notes ?? '';
    _sanctionStart = _currentCase.sanction?.startDate;
    _sanctionEnd = _currentCase.sanction?.endDate;
    _selectedHearingDate = _currentCase.hearing?.hearingDate;
  }

  @override
  void dispose() {
    _venueController.dispose();
    _hearingNotesController.dispose();
    _sanctionTypeController.dispose();
    _sanctionNotesController.dispose();
    super.dispose();
  }

  bool get _isHearingDateReached {
    if (_currentCase.sanction != null) return true;
    if (_currentCase.hearing == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hearingDay = DateTime(
      _currentCase.hearing!.hearingDate.year,
      _currentCase.hearing!.hearingDate.month,
      _currentCase.hearing!.hearingDate.day,
    );

    return !hearingDay.isAfter(today);
  }

  Future<void> _pickHearingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedHearingDate ?? DateTime.now().add(const Duration(days: 2)),
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
      final updatedHearing = await _caseService.scheduleHearing(
        caseId: _currentCase.id,
        studentId: _currentCase.studentId,
        hearingDate: _selectedHearingDate!,
        venue: _venueController.text.trim(),
        committeeNotes: _hearingNotesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _currentCase = DisciplinaryCase(
          id: _currentCase.id,
          incidentId: _currentCase.incidentId,
          studentId: _currentCase.studentId,
          assignedTo: _currentCase.assignedTo,
          priority: _currentCase.priority,
          status: CaseStatus.hearingScheduled,
          createdAt: _currentCase.createdAt,
          incident: _currentCase.incident,
          hearing: updatedHearing,
          sanction: _currentCase.sanction,
          appeals: _currentCase.appeals,
        );
        _isEditingHearing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disciplinary hearing scheduled successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
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
      final updatedSanction = await _caseService.recordSanction(
        caseId: _currentCase.id,
        studentId: _currentCase.studentId,
        sanctionType: _sanctionTypeController.text.trim(),
        startDate: _sanctionStart,
        endDate: _sanctionEnd,
        notes: _sanctionNotesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _currentCase = DisciplinaryCase(
          id: _currentCase.id,
          incidentId: _currentCase.incidentId,
          studentId: _currentCase.studentId,
          assignedTo: _currentCase.assignedTo,
          priority: _currentCase.priority,
          status: CaseStatus.sanctionIssued,
          createdAt: _currentCase.createdAt,
          incident: _currentCase.incident,
          hearing: _currentCase.hearing,
          sanction: updatedSanction,
          appeals: _currentCase.appeals,
        );
        _isEditingSanction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sanction recorded & student notified.'),
          backgroundColor: AppColors.success,
        ),
      );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Case #${_currentCase.id} Action'),
          backgroundColor: AppColors.navy,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.white70,
            tabs: [
              Tab(icon: Icon(Icons.event), text: 'Hearing Schedule'),
              Tab(icon: Icon(Icons.gavel), text: 'Sanction & Ruling'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  _buildCaseOverviewCard(),
                  const SizedBox(height: 12),
                  _buildProcessStepper(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Hearing Schedule Details', Icons.calendar_month),
                        const SizedBox(height: 12),
                        (_currentCase.hearing != null && !_isEditingHearing)
                            ? _buildExistingHearingCard()
                            : _buildHearingFormCard(),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Sanction & Ruling Decision', Icons.gavel),
                        const SizedBox(height: 12),
                        _buildSanctionSectionContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStepper() {
    final hasHearing = _currentCase.hearing != null;
    final isConducted = _isHearingDateReached;
    final hasSanction = _currentCase.sanction != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _buildStepItem(
            step: '1',
            label: 'Schedule Hearing',
            isDone: hasHearing,
            isActive: !hasHearing,
          ),
          _buildStepLine(isDone: hasHearing),
          _buildStepItem(
            step: '2',
            label: 'Hearing Date',
            isDone: isConducted,
            isActive: hasHearing && !isConducted,
          ),
          _buildStepLine(isDone: isConducted),
          _buildStepItem(
            step: '3',
            label: 'Issue Sanction',
            isDone: hasSanction,
            isActive: isConducted,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    Color bg = isDone
        ? AppColors.success
        : (isActive ? AppColors.navy : AppColors.cardBorder);
    Color textCol = isDone || isActive ? AppColors.white : AppColors.textMuted;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: bg,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : Text(step, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.normal,
              color: isActive || isDone ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      width: 20,
      height: 2,
      color: isDone ? AppColors.success : AppColors.cardBorder,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  Widget _buildSanctionSectionContent() {
    if (_currentCase.hearing == null) {
      return _buildSanctionLockedCard(
        icon: Icons.lock_clock_outlined,
        title: 'Hearing Schedule Required',
        message:
            'A disciplinary hearing must be scheduled first before a sanction or ruling can be recorded.',
      );
    }

    if (!_isHearingDateReached) {
      return Column(
        children: [
          _buildSanctionLockedCard(
            icon: Icons.event_note,
            title: 'Hearing Pending (${formatDateOnly(_currentCase.hearing!.hearingDate)})',
            message:
                'The hearing is scheduled for ${formatDate(_currentCase.hearing!.hearingDate)} at ${_currentCase.hearing!.venue}.\n\nSanctions & rulings can only be recorded on or after the hearing date.',
          ),
          const SizedBox(height: 12),
          _buildHearingSummaryBox(),
        ],
      );
    }

    return (_currentCase.sanction != null && !_isEditingSanction)
        ? _buildExistingSanctionCard()
        : _buildSanctionFormCard();
  }

  Widget _buildSanctionLockedCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Workflow rule: Sanction follows hearing date',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHearingSummaryBox() {
    final hearing = _currentCase.hearing!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled Hearing: ${formatDate(hearing.hearingDate)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  'Venue: ${hearing.venue}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
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
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hearing Date: ${formatDate(_currentCase.hearing!.hearingDate)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Venue: ${_currentCase.hearing!.venue}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            if (_currentCase.hearing!.committeeNotes != null && _currentCase.hearing!.committeeNotes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Notes: ${_currentCase.hearing!.committeeNotes}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedHearingDate = _currentCase.hearing!.hearingDate;
                    _venueController.text = _currentCase.hearing!.venue;
                    _hearingNotesController.text = _currentCase.hearing!.committeeNotes ?? '';
                    _isEditingHearing = true;
                  });
                },
                icon: const Icon(Icons.edit_calendar, size: 16),
                label: const Text('Reschedule / Edit Hearing'),
              ),
            ),
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
            Row(
              children: [
                if (_currentCase.hearing != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditingHearing = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _savingHearing ? null : _saveHearing,
                    icon: _savingHearing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Icon(Icons.schedule, size: 18),
                    label: Text(_savingHearing ? 'Saving...' : (_currentCase.hearing == null ? 'Schedule Hearing' : 'Update Hearing')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildExistingSanctionCard() => Container(
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
              children: [
                const Icon(Icons.gpp_bad, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sanction: ${_currentCase.sanction!.sanctionType}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.danger),
                  ),
                ),
              ],
            ),
            if (_currentCase.sanction!.startDate != null) ...[
              const SizedBox(height: 6),
              Text(
                'Effective: ${formatDateOnly(_currentCase.sanction!.startDate!)}${_currentCase.sanction!.endDate != null ? ' to ${formatDateOnly(_currentCase.sanction!.endDate!)}' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            if (_currentCase.sanction!.notes != null && _currentCase.sanction!.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(_currentCase.sanction!.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _sanctionTypeController.text = _currentCase.sanction!.sanctionType;
                    _sanctionNotesController.text = _currentCase.sanction!.notes ?? '';
                    _sanctionStart = _currentCase.sanction!.startDate;
                    _sanctionEnd = _currentCase.sanction!.endDate;
                    _isEditingSanction = true;
                  });
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modify Sanction'),
              ),
            ),
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
            Row(
              children: [
                if (_currentCase.sanction != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditingSanction = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _savingSanction ? null : _saveSanction,
                    icon: _savingSanction
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_savingSanction ? 'Saving...' : (_currentCase.sanction == null ? 'Record Sanction' : 'Update Sanction')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
