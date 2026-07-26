import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hhlvvncfswrdedmoivtc.supabase.co',
    publishableKey: 'sb_publishable_i16wlV3cZPlpLxZjKhfpyg_PXcnvzo8',
  );

  runApp(const SDMSApp());
}

class SDMSApp extends StatelessWidget {
  const SDMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UEAB SDMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}