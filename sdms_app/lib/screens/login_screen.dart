import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'student/student_dashboard_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _passwordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final emailOrId = _emailController.text.trim();
      final password = _passwordController.text;

      final profile = await _authService.login(
        email: emailOrId,
        password: password,
        selectedRole: _selectedRole,
      );

      if (!mounted) return;

      final activeRole = profile?.role ?? _selectedRole;

      Widget targetDashboard;
      switch (activeRole) {
        case UserRole.staff:
          targetDashboard = StaffDashboardScreen(
            userProfile: profile ??
                UserProfile(
                  id: '0',
                  email: emailOrId,
                  fullName: emailOrId.split('@').first,
                  role: UserRole.staff,
                  studentId: '',
                ),
          );
          break;
        case UserRole.admin:
          targetDashboard = AdminDashboardScreen(
            userProfile: profile ??
                UserProfile(
                  id: '0',
                  email: emailOrId,
                  fullName: emailOrId.split('@').first,
                  role: UserRole.admin,
                  studentId: '',
                ),
          );
          break;
        case UserRole.student:
          targetDashboard = StudentDashboardScreen(
            userProfile: profile ??
                UserProfile(
                  id: '0',
                  email: emailOrId,
                  fullName: emailOrId.split('@').first,
                  role: UserRole.student,
                  studentId: emailOrId.contains('/') ? emailOrId : '',
                ),
          );
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => targetDashboard),
      );
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
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildLoginFormCard(),
                      const SizedBox(height: 24),
                      _buildFooter(context),
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

  Widget _buildHeader() => Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo-2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.school,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'UNIVERSITY OF EASTERN AFRICA, BARATON',
            textAlign: TextAlign.center,
            style: AppTextStyles.universityName,
          ),
          const SizedBox(height: 4),
          const Text('SDMS', style: AppTextStyles.appTitle),
          const SizedBox(height: 4),
          const Text(
            'Student Disciplinary Management System',
            style: AppTextStyles.subtitle,
          ),
        ],
      );

  Widget _buildLoginFormCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Portal Access',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
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
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? AppColors.navy : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active ? AppColors.navy : AppColors.cardBorder,
                          width: active ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        role.label.split(' ').first,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                          color: active ? AppColors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              '${_selectedRole.label} Sign In',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your ${_selectedRole.label.toLowerCase()} dashboard',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'University Email or Student ID',
                hintText: 'e.g. user@ueab.ac.ke or S21/04561/19',
                prefixIcon: Icon(Icons.mail_outline, color: AppColors.primary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email or Student ID';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
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
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your password';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                    : Text(
                        'SIGN IN AS ${_selectedRole.label.toUpperCase().split(' ').first}',
                        style: const TextStyle(
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

  Widget _buildFooter(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: AppColors.white70, fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text(
                  'Register Here',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'UEAB SDMS  ·  Secure Portal',
            style: AppTextStyles.footerText,
          ),
        ],
      );
}