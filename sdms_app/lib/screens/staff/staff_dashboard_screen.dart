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
import 'case_manage_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const StaffDashboardScreen({super.key, required this.userProfile});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final CaseService _caseService = CaseService();
  final AuthService _authService = AuthService();

  bool _loading = true;
  List<DisciplinaryCase> _cases = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cases = await _caseService.fetchCasesForStaff(widget.userProfile.fullName);
      setState(() {
        _cases = cases;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DisciplinaryCase> get _filteredCases {
    if (_searchQuery.trim().isEmpty) return _cases;
    final query = _searchQuery.toLowerCase();
    return _cases.where((c) {
      return c.id.toString().contains(query) ||
          c.studentId.toLowerCase().contains(query) ||
          (c.incident?.category.label.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  int get _pendingHearingsCount =>
      _cases.where((c) => c.status == CaseStatus.hearingScheduled).length;

  int get _activeSanctionsCount =>
      _cases.where((c) => c.status == CaseStatus.sanctionIssued).length;

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
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Search cases by ID, Student ID, or Category...',
                        prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cases Assigned to You',
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
                        : _filteredCases.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.assignment_outlined,
                                title: 'No Cases Assigned',
                                message:
                                    'There are currently no active disciplinary cases assigned to your queue.',
                              )
                            : Column(
                                children: _filteredCases.map((c) => _buildCaseCard(c)).toList(),
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

  Widget _buildHeader() {
    return Container(
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
                  'Staff Portal: ${widget.userProfile.fullName}',
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
                    'Disciplinary Committee Staff',
                    style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
              label: 'Assigned Cases',
              value: '${_cases.length}',
              icon: Icons.folder_shared_outlined,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Hearings',
              value: '$_pendingHearingsCount',
              icon: Icons.event,
              color: AppColors.primary,
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
        ],
      );

  Widget _buildCaseCard(DisciplinaryCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final res = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CaseManageScreen(caseData: c)),
            );
            if (res == true) _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          PriorityBadge(priority: c.priority),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Student ID: ${c.studentId.isNotEmpty ? c.studentId : 'Unlinked'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${formatDate(c.createdAt)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(status: c.status, compact: true),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
