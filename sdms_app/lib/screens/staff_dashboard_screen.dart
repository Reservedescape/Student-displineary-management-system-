import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String fullName;

  const StaffDashboardScreen({
    super.key,
    required this.fullName,
  });

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _cases = [];
  List<Map<String, dynamic>> _incidents = [];
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final casesResult = await Supabase.instance.client
          .from('cases')
          .select()
          .eq('assigned_to', widget.fullName);

      final incidentsResult = await Supabase.instance.client
          .from('incidents')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _cases = List<Map<String, dynamic>>.from(casesResult);
        _incidents = List<Map<String, dynamic>>.from(incidentsResult);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createCaseFromIncident(Map<String, dynamic> incident) async {
    final incidentId = incident['id'] as int;
    setState(() => _processingIds.add(incidentId));

    try {
      final reporterEmail = incident['reported_by'];

      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('email', reporterEmail)
          .maybeSingle();

      final studentId = profile?['student_id'] ?? '';

      await Supabase.instance.client.from('cases').insert({
        'incident_id': incidentId,
        'student_id': studentId,
        'assigned_to': widget.fullName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case created successfully.')),
        );
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create case. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(incidentId));
    }
  }

  // Incidents that already have a matching case are excluded from the list
  List<Map<String, dynamic>> get _openIncidents {
    final caseIncidentIds = _cases.map((c) => c['incident_id']).toSet();
    return _incidents.where((i) => !caseIncidentIds.contains(i['id'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(widget.fullName),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _statCard('Assigned cases', '${_cases.length}')),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Open incidents', '${_openIncidents.length}')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Open incidents'),
                  const SizedBox(height: 10),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _openIncidents.isEmpty
                          ? _emptyState('No open incidents right now.')
                          : Column(
                              children: _openIncidents.map((i) => _incidentCard(i)).toList(),
                            ),
                  const SizedBox(height: 20),
                  _sectionTitle('Cases assigned to you'),
                  const SizedBox(height: 10),
                  _loading
                      ? const SizedBox()
                      : _cases.isEmpty
                          ? _emptyState('No cases currently assigned to you.')
                          : Column(
                              children: _cases.map((c) => _caseCard(c)).toList(),
                            ),
                  const SizedBox(height: 24),
                  _logoutButton(context, user?.email ?? 'Unknown'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _header(String name) => Container(
    color: AppColors.navy,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'University of Eastern Africa, Baraton',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome, $name',
                style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Staff',
                  style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Text(
            _initials(name),
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    ),
  );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  // ── Stat card ──────────────────────────────────────────
  Widget _statCard(String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.inputText)),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.inputText),
  );

  // ── Empty state ────────────────────────────────────────
  Widget _emptyState(String message) => Container(
    padding: const EdgeInsets.all(20),
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

  // ── Incident card ────────────────────────────────────────
  Widget _incidentCard(Map<String, dynamic> incident) {
    final incidentId = incident['id'] as int;
    final isProcessing = _processingIds.contains(incidentId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0C9A0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Incident #$incidentId',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.inputText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            incident['description'] ?? '',
            style: const TextStyle(fontSize: 13, color: AppColors.inputText),
          ),
          const SizedBox(height: 4),
          Text(
            'Reported by: ${incident['reported_by'] ?? 'Unknown'}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : () => _createCaseFromIncident(incident),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Create case', style: TextStyle(color: AppColors.white, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Case card ──────────────────────────────────────────
  Widget _caseCard(Map<String, dynamic> caseData) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.gavel, color: AppColors.navy, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Case #${caseData['id']}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Student ID: ${caseData['student_id'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // ── Logout button ───────────────────────────────────────
  Widget _logoutButton(BuildContext context, String email) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      icon: const Icon(Icons.logout, size: 18, color: AppColors.white),
      label: const Text('Log out', style: TextStyle(color: AppColors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
  );
}