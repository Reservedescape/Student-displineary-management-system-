import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hhlvvncfswrdedmoivtc.supabase.co',
    publishableKey: 'sb_publishable_i16wlV3cZPlpLxZjKhfpyg_PXcnvzo8',
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SDMS',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}