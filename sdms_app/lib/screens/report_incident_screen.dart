import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../services/incident_service.dart';
import '../services/auth_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _offenderIdController = TextEditingController();
  final _offenderNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final IncidentService _incidentService = IncidentService();
  final AuthService _authService = AuthService();

  IncidentCategory _selectedCategory = IncidentCategory.misconduct;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _offenderIdController.dispose();
    _offenderNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = _authService.currentUser;
      final reporterEmail = _isAnonymous ? 'Anonymous' : (user?.email ?? 'anonymous@ueab.ac.ke');

      await _incidentService.reportIncident(
        reportedBy: reporterEmail,
        offenderStudentId: _offenderIdController.text.trim(),
        offenderName: _offenderNameController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident report submitted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report an Incident'),
        backgroundColor: AppColors.navy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoticeCard(),
              const SizedBox(height: 20),
              const Text(
                'Violation Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<IncidentCategory>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: IncidentCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _offenderIdController,
                      decoration: const InputDecoration(
                        labelText: 'Offender Student ID',
                        hintText: 'e.g. S21/04561/19',
                        prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                      ),
                      validator: (v) {
                        if (!_isAnonymous && (v == null || v.trim().isEmpty)) {
                          return 'Please specify student ID';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _offenderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name (Optional)',
                        hintText: 'If known',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / Venue',
                  hintText: 'e.g. Main Library, Male Hostel Block B',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please specify location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Detailed Incident Description',
                  hintText: 'Describe clearly what transpired, witnesses present, and relevant facts...',
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 15) {
                    return 'Please provide more details (minimum 15 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: CheckboxListTile(
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                  title: const Text(
                    'Report Anonymously',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Your personal details will not be disclosed to reviewing staff.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  activeColor: AppColors.navy,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Incident Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.infoBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.info, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reports are strictly confidential and routed to the Disciplinary Committee for official review.',
                style: TextStyle(fontSize: 12, color: AppColors.info.withOpacity(0.9), height: 1.3),
              ),
            ),
          ],
        ),
      );
}