import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/constants.dart';
import '../../models/user_profile.dart';
import '../../models/disciplinary_case.dart';
import '../../models/incident.dart';
import '../../services/case_service.dart';
import '../../services/incident_service.dart';
import '../../services/appeal_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../login_screen.dart';
import 'appeals_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const AdminDashboardScreen({super.key, required this.userProfile});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CaseService _caseService = CaseService();
  final IncidentService _incidentService = IncidentService();
  final AppealService _appealService = AppealService();
  final AuthService _authService = AuthService();

  bool _loading = true;
  List<DisciplinaryCase> _cases = [];
  List<Incident> _incidents = [];
  List<UserProfile> _staffList = [];
  int _pendingAppealsCount = 0;

  final Map<int, String?> _selectedStaff = {};
  final Map<int, CasePriority> _selectedPriority = {};
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cases = await _caseService.fetchAllCases();
      final incidents = await _incidentService.fetchAllIncidents();
      final staff = await _authService.fetchStaffList();
      final pendingAppeals = await _appealService.fetchPendingAppeals();

      setState(() {
        _cases = cases;
        _incidents = incidents;
        _staffList = staff;
        _pendingAppealsCount = pendingAppeals.length;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Incident> get _openIncidents {
    final assignedIncidentIds = _cases.map((c) => c.incidentId).toSet();
    return _incidents.where((i) => !assignedIncidentIds.contains(i.id)).toList();
  }

  Future<void> _assignCaseToStaff(Incident incident) async {
    final incidentId = incident.id;
    final staffName = _selectedStaff[incidentId];
    final priority = _selectedPriority[incidentId] ?? CasePriority.medium;

    if (staffName == null || staffName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a staff member to assign this case.')),
      );
      return;
    }

    final offenderStudentId = incident.offenderStudentId;
    if (offenderStudentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine offender Student ID from incident.')),
      );
      return;
    }

    setState(() => _processingIds.add(incidentId));

    try {
      await _caseService.createAndAssignCase(
        incidentId: incidentId,
        studentId: offenderStudentId,
        assignedToStaff: staffName,
        priority: priority,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incident #$incidentId triaged and assigned to $staffName.'),
          backgroundColor: AppColors.success,
        ),
      );

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign case: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(incidentId));
    }
  }

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
                    const SizedBox(height: 16),
                    _buildReviewAppealsButton(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Open Incidents awaiting Triage', Icons.report_problem_outlined),
                    const SizedBox(height: 12),
                    _loading
                        ? const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                        : _openIncidents.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.check_circle_outline,
                                title: 'All Incidents Triaged',
                                message: 'There are no unassigned incident reports in the queue.',
                              )
                            : Column(
                                children: _openIncidents.map((i) => _buildIncidentTriageCard(i)).toList(),
                              ),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Disciplinary Cases Directory', Icons.folder_copy_outlined),
                    const SizedBox(height: 12),
                    _loading
                        ? const SizedBox()
                        : _cases.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.folder_open,
                                title: 'No Disciplinary Cases',
                                message: 'No formal cases have been created yet.',
                              )
                            : Column(
                                children: _cases.map((c) => _buildCaseCard(c)).toList(),
                              ),
                    const SizedBox(height: 24),
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
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
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

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.userProfile.initials,
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal: ${widget.userProfile.fullName}',
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Chief Disciplinary Officer',
                      style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildStatsRow() => Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total Cases',
              value: '${_cases.length}',
              icon: Icons.folder_outlined,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Open Incidents',
              value: '${_openIncidents.length}',
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Appeals',
              value: '$_pendingAppealsCount',
              icon: Icons.rate_review_outlined,
              color: AppColors.danger,
            ),
          ),
        ],
      );

  Widget _buildReviewAppealsButton() => SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppealsReviewScreen()),
            );
            _loadData();
          },
          icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.navy),
          label: Text(
            _pendingAppealsCount > 0
                ? 'Review Pending Appeals ($_pendingAppealsCount Pending)'
                : 'Review Pending Appeals Board',
            style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.navy, width: 1.5),
          ),
        ),
      );

  Widget _buildSectionHeader(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: AppColors.navy, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      );

  Widget _buildIncidentTriageCard(Incident incident) {
    final incidentId = incident.id;
    final isProcessing = _processingIds.contains(incidentId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  incident.category.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              Text(
                formatDate(incident.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Offender Student ID: ${incident.offenderStudentId.isNotEmpty ? incident.offenderStudentId : 'Unknown'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: 4),
          Text(
            'Location: ${incident.location}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            incident.description,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Assign Staff Member', style: TextStyle(fontSize: 12)),
                      value: _selectedStaff[incidentId],
                      items: _staffList.map((staff) {
                        return DropdownMenuItem(
                          value: staff.fullName,
                          child: Text(staff.fullName, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedStaff[incidentId] = val),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CasePriority>(
                      isExpanded: true,
                      value: _selectedPriority[incidentId] ?? CasePriority.medium,
                      items: CasePriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.label, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority[incidentId] = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : () => _assignCaseToStaff(incident),
              icon: isProcessing
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(isProcessing ? 'Assigning...' : 'Create & Assign Case'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(DisciplinaryCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Case #${c.id}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: c.priority),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: ${c.studentId.isNotEmpty ? c.studentId : 'N/A'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Assigned Staff: ${c.assignedTo}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusBadge(status: c.status, compact: true),
        ],
      ),
    );
  }
}
