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
    final defaultStaff = [
      UserProfile(id: 'staff-1', email: 'dean@ueab.ac.ke', fullName: 'Dean of Students', role: UserRole.staff, studentId: ''),
      UserProfile(id: 'staff-2', email: 'disciplinary@ueab.ac.ke', fullName: 'Disciplinary Committee Chair', role: UserRole.staff, studentId: ''),
      UserProfile(id: 'staff-3', email: 'warden@ueab.ac.ke', fullName: 'Chief Hostel Warden', role: UserRole.staff, studentId: ''),
      UserProfile(id: 'staff-4', email: 'security@ueab.ac.ke', fullName: 'Chief Security Officer', role: UserRole.staff, studentId: ''),
      UserProfile(id: 'staff-5', email: 'staff@ueab.ac.ke', fullName: 'Staff Member', role: UserRole.staff, studentId: ''),
    ];

    try {
      final result = await _client
          .from('profiles')
          .select()
          .eq('role', 'staff');
      final remoteStaff = (result as List).map((p) => UserProfile.fromJson(p)).toList();

      final Map<String, UserProfile> map = {};
      for (var s in defaultStaff) {
        map[s.fullName.toLowerCase()] = s;
      }
      for (var s in remoteStaff) {
        if (s.fullName.isNotEmpty) {
          map[s.fullName.toLowerCase()] = s;
        }
      }
      return map.values.toList();
    } catch (_) {
      return defaultStaff;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
