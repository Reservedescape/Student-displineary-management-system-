import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── State ──────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  int _selectedRole = 0;

  final _roles = ['Student', 'Staff', 'Admin'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 13),
      filled: true,
      fillColor: AppColors.white,
      prefixIcon: Icon(icon, color: AppColors.iconColor, size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: _border(Colors.transparent),
      focusedBorder: _border(AppColors.navy),
      errorBorder: _border(Colors.redAccent),
      focusedErrorBorder: _border(Colors.redAccent),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: color == Colors.transparent
        ? BorderSide.none
        : BorderSide(color: color, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 72),
                  _logo(),
                  const SizedBox(height: 16),
                  _header(),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.white.withOpacity(0.25)),
                  const SizedBox(height: 20),
                  _roleSelector(),
                  const SizedBox(height: 16),
                  _emailField(),
                  const SizedBox(height: 14),
                  _passwordField(),
                  _forgotPassword(),
                  const SizedBox(height: 8),
                  _loginButton(),
                  const SizedBox(height: 24),
                  const Text(
                    'UEAB  ·  Secure login',
                    style: AppTextStyles.footerText,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() => Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      color: AppColors.white,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.white.withOpacity(0.5), width: 3),
    ),
    child: ClipOval(
      child: Image.asset(
        'assets/logo-2.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.school, size: 44, color: AppColors.primary),
      ),
    ),
  );

  Widget _header() => const Column(
    children: [
      Text(
        'University of Eastern Africa, Baraton',
        textAlign: TextAlign.center,
        style: AppTextStyles.universityName,
      ),
      SizedBox(height: 4),
      Text('SDMS', style: AppTextStyles.appTitle),
      SizedBox(height: 4),
      Text('Student Disciplinary System', style: AppTextStyles.subtitle),
    ],
  );

  Widget _roleSelector() => Row(
    children: List.generate(_roles.length, (i) {
      final active = _selectedRole == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedRole = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.white
                  : AppColors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.22),
              ),
            ),
            child: Text(
              _roles[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? AppColors.primary : AppColors.white70,
              ),
            ),
          ),
        ),
      );
    }),
  );

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    style: const TextStyle(color: AppColors.inputText, fontSize: 14),
    decoration: _inputDecoration('University email', Icons.mail_outline),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Please enter your email';
      if (!v.contains('@')) return 'Enter a valid email';
      return null;
    },
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordController,
    obscureText: !_passwordVisible,
    textInputAction: TextInputAction.done,
    onFieldSubmitted: (_) => _handleLogin(),
    style: const TextStyle(color: AppColors.inputText, fontSize: 14),
    decoration: _inputDecoration(
      'Password',
      Icons.lock_outline,
      suffix: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColors.hintText,
          size: 20,
        ),
        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
      ),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Please enter your password';
      if (v.length < 6) return 'Password must be at least 6 characters';
      return null;
    },
  );

  Widget _forgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () {},
      child: const Text(
        'Forgot password?',
        style: AppTextStyles.forgotPassword,
      ),
    ),
  );

  Widget _loginButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.white.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          : const Text('Sign in', style: AppTextStyles.buttonLabel),
    ),
  );
}
