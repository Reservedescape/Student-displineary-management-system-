import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_incident_screen.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String fullName;
  final String studentId;

  const DashboardScreen({
    super.key,
    required this.role,
    required this.fullName,
    required this.studentId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    try {
      final result = await Supabase.instance.client
          .from('cases')
          .select()
          .eq('student_id', widget.studentId);

      setState(() {
        _cases = List<Map<String, dynamic>>.from(result);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
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
                  _statRow(),
                  const SizedBox(height: 20),
                  _sectionTitle('My cases'),
                  const SizedBox(height: 10),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _cases.isEmpty
                          ? _emptyState('No cases found. You have a clean record!')
                          : Column(
                              children: _cases.map((c) => _caseCard(c)).toList(),
                            ),
                  const SizedBox(height: 12),
                  _reportIncidentButton(context),
                  const SizedBox(height: 12),
                  _actionButtons(context, user?.email ?? 'Unknown'),
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

  // ── Stat cards ─────────────────────────────────────────
  Widget _statRow() => Row(
    children: [
      Expanded(child: _statCard('Open cases', '${_cases.length}')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Hearings', '0')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Notifications', '0')),
    ],
  );

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
            const Icon(Icons.description_outlined, color: AppColors.navy, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Case #${caseData['id']}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Assigned to: ${caseData['assigned_to'] ?? 'Unassigned'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // ── Report incident button ──────────────────────────────
  Widget _reportIncidentButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ReportIncidentScreen()),
        );
        if (result == true) {
          _loadCases();
        }
      },
      icon: const Icon(Icons.report_outlined, size: 18, color: AppColors.navy),
      label: const Text('Report an incident', style: TextStyle(color: AppColors.navy)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.navy),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  // ── Action buttons ─────────────────────────────────────
  Widget _actionButtons(BuildContext context, String email) => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_outline, size: 18),
          label: const Text('My profile'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
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
      ),
    ],
  );
}