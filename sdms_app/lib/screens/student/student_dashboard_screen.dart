import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/constants.dart';
import '../../models/user_profile.dart';
import '../../models/disciplinary_case.dart';
import '../../services/case_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../login_screen.dart';
import '../report_incident_screen.dart';
import 'submit_appeal_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const StudentDashboardScreen({super.key, required this.userProfile});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final CaseService _caseService = CaseService();
  final AuthService _authService = AuthService();

  bool _loading = true;
  List<DisciplinaryCase> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cases = await _caseService.fetchCasesForStudent(widget.userProfile.studentId);
      setState(() {
        _cases = cases;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _activeSanctionsCount =>
      _cases.where((c) => c.sanction != null && c.status == CaseStatus.sanctionIssued).length;

  int get _pendingAppealsCount =>
      _cases.where((c) => c.latestAppeal?.status == AppealStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Disciplinary Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                          onPressed: _loadData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _loading
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          )
                        : _cases.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.verified_user_outlined,
                                title: 'Clean Record',
                                message:
                                    'You have no disciplinary cases on record. Keep up the great conduct at UEAB!',
                                actionLabel: 'Report an Incident',
                                onAction: () async {
                                  final res = await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
                                  );
                                  if (res == true) _loadData();
                                },
                              )
                            : Column(
                                children: _cases.map((c) => _buildCaseCard(c)).toList(),
                              ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
                          );
                          if (res == true) _loadData();
                        },
                        icon: const Icon(Icons.report_problem_outlined, size: 18),
                        label: const Text('Report an Incident / Witness Statement'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _authService.logout();
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('LOG OUT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hasActiveCase = _cases.any((c) => c.status != CaseStatus.closed);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.userProfile.initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${widget.userProfile.fullName}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${widget.userProfile.studentId.isNotEmpty ? widget.userProfile.studentId : 'N/A'}',
                      style: const TextStyle(color: AppColors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: hasActiveCase
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasActiveCase ? AppColors.warning : AppColors.success,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasActiveCase ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: hasActiveCase ? AppColors.warning : AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasActiveCase
                        ? 'Status: Active Disciplinary Review'
                        : 'Status: Good Standing',
                    style: TextStyle(
                      color: hasActiveCase ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() => Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total Cases',
              value: '${_cases.length}',
              icon: Icons.folder_special_outlined,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Sanctions',
              value: '$_activeSanctionsCount',
              icon: Icons.gpp_bad_outlined,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Appeals',
              value: '$_pendingAppealsCount',
              icon: Icons.gavel_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      );

  Widget _buildCaseCard(DisciplinaryCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel, size: 18, color: AppColors.navy),
                    const SizedBox(width: 8),
                    Text(
                      'Case #${c.id}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: c.status, compact: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assigned Staff: ${c.assignedTo}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    PriorityBadge(priority: c.priority),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Created: ${formatDate(c.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),

                // Hearing Notice Section
                if (c.hearing != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.info, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scheduled Disciplinary Hearing',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatDate(c.hearing!.hearingDate)} @ ${c.hearing!.venue}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Sanction Section & Appeal Action
                if (c.sanction != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gpp_bad, color: AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sanction: ${c.sanction!.sanctionType}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        if (c.sanction!.notes != null && c.sanction!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            c.sanction!.notes!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAppealSection(c),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealSection(DisciplinaryCase c) {
    final appeal = c.latestAppeal;

    if (appeal == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final res = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubmitAppealScreen(
                  caseId: c.id,
                  studentId: widget.userProfile.studentId,
                ),
              ),
            );
            if (res == true) _loadData();
          },
          icon: const Icon(Icons.gavel_outlined, size: 16, color: AppColors.primary),
          label: const Text('Submit Appeal to VC Board', style: TextStyle(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
      );
    }

    Color color;
    IconData icon;
    switch (appeal.status) {
      case AppealStatus.approved:
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case AppealStatus.denied:
        color = AppColors.danger;
        icon = Icons.cancel;
        break;
      case AppealStatus.pending:
      default:
        color = AppColors.warning;
        icon = Icons.hourglass_top;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Appeal ${appeal.status.label}',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
            ),
          ),
          if (appeal.notes != null && appeal.notes!.isNotEmpty)
            Tooltip(
              message: appeal.notes!,
              child: const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
