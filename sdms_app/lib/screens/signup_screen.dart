import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import 'student/student_dashboard_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _passwordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final fullName = _fullNameController.text.trim();
      final studentId = _studentIdController.text.trim();

      final profile = await _authService.signup(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        role: _selectedRole,
      );

      if (!mounted) return;

      if (profile != null) {
        Widget targetDashboard;
        switch (profile.role) {
          case UserRole.staff:
            targetDashboard = StaffDashboardScreen(userProfile: profile);
            break;
          case UserRole.admin:
            targetDashboard = AdminDashboardScreen(userProfile: profile);
            break;
          case UserRole.student:
            targetDashboard = StudentDashboardScreen(userProfile: profile);
            break;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => targetDashboard),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSignupCard(),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Already registered? Back to Sign In',
                          style: AppTextStyles.forgotPassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => const Column(
        children: [
          Text(
            'UNIVERSITY OF EASTERN AFRICA, BARATON',
            textAlign: TextAlign.center,
            style: AppTextStyles.universityName,
          ),
          SizedBox(height: 4),
          Text('Create Account', style: AppTextStyles.appTitle),
          SizedBox(height: 4),
          Text('Join the SDMS Portal', style: AppTextStyles.subtitle),
        ],
      );

  Widget _buildSignupCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Account Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: UserRole.values.map((role) {
                final active = _selectedRole == role;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.navy : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active ? AppColors.navy : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        role.label.split(' ').first,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          color: active ? AppColors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. John Doe',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter full name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'University Email',
                hintText: 'student@ueab.ac.ke',
                prefixIcon: Icon(Icons.mail_outline, color: AppColors.primary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter email';
                if (!v.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _studentIdController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: _selectedRole == UserRole.student ? 'Student ID' : 'Staff ID',
                hintText: 'e.g. S21/04561/19',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter ID' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignup(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
}