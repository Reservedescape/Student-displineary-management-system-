import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../core/constants.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user == null) return null;

    return await fetchProfile(email.trim());
  }

  Future<UserProfile?> signup({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required UserRole role,
  }) async {
    final authResponse = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    final user = authResponse.user;
    if (user == null) throw Exception('Signup failed. Could not create auth user.');

    // Save profile to Supabase 'profiles' table
    final profileData = {
      'id': user.id,
      'email': email.trim(),
      'full_name': fullName.trim(),
      'student_id': studentId.trim(),
      'role': role.value,
    };

    try {
      await _client.from('profiles').upsert(profileData);
    } catch (_) {
      // Fallback if upsert has RLS policy issue
      await _client.from('profiles').insert(profileData);
    }

    return UserProfile(
      id: user.id,
      email: email.trim(),
      fullName: fullName.trim(),
      role: role,
      studentId: studentId.trim(),
    );
  }

  Future<UserProfile?> fetchProfile(String email) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }
    } catch (e) {
      print('Profile fetch error: $e');
    }

    // Fallback profile object if not found
    return UserProfile(
      id: currentUser?.id ?? '0',
      email: email,
      fullName: email.split('@').first,
      role: UserRole.student,
      studentId: '',
    );
  }

  Future<List<UserProfile>> fetchStaffList() async {
    try {
      final result = await _client
          .from('profiles')
          .select()
          .eq('role', 'staff');
      return (result as List).map((p) => UserProfile.fromJson(p)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
