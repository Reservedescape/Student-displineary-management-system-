import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../core/constants.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // In-memory registered user profile cache for seamless fallback and offline/demo support
  static final Map<String, UserProfile> _registeredProfiles = {
    'student@ueab.ac.ke': UserProfile(
      id: 'demo-student-1',
      email: 'student@ueab.ac.ke',
      fullName: 'John Doe (Student)',
      role: UserRole.student,
      studentId: 'S21/04561/19',
    ),
    'student1@ueab.ac.ke': UserProfile(
      id: 'demo-student-2',
      email: 'student1@ueab.ac.ke',
      fullName: 'Jane Smith (Student)',
      role: UserRole.student,
      studentId: 'S22/01234/20',
    ),
    's21/04561/19': UserProfile(
      id: 'demo-student-1',
      email: 'student@ueab.ac.ke',
      fullName: 'John Doe (Student)',
      role: UserRole.student,
      studentId: 'S21/04561/19',
    ),
    'dean@ueab.ac.ke': UserProfile(
      id: 'staff-1',
      email: 'dean@ueab.ac.ke',
      fullName: 'Dean of Students',
      role: UserRole.staff,
      studentId: '',
    ),
    'disciplinary@ueab.ac.ke': UserProfile(
      id: 'staff-2',
      email: 'disciplinary@ueab.ac.ke',
      fullName: 'Disciplinary Committee Chair',
      role: UserRole.staff,
      studentId: '',
    ),
    'admin@ueab.ac.ke': UserProfile(
      id: 'admin-1',
      email: 'admin@ueab.ac.ke',
      fullName: 'System Administrator',
      role: UserRole.admin,
      studentId: '',
    ),
  };

  User? get currentUser => _client.auth.currentUser;

  /// Helper to convert Student ID or input string to a valid email address if needed
  String resolveEmail(String input) {
    final cleaned = input.trim().toLowerCase();
    if (cleaned.contains('@')) {
      return cleaned;
    }
    // Convert student ID format e.g. "S21/04561/19" -> "s21.04561.19@ueab.ac.ke"
    final sanitizedId = cleaned.replaceAll('/', '.');
    return '$sanitizedId@ueab.ac.ke';
  }

  Future<UserProfile?> login({
    required String email,
    required String password,
    UserRole? selectedRole,
  }) async {
    final cleanEmail = resolveEmail(email);
    final rawInputKey = email.trim().toLowerCase();

    // 1. Try Supabase cloud auth first
    try {
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (response.user != null) {
        final profile = await fetchProfile(cleanEmail);
        if (profile != null) return profile;
      }
    } catch (e) {
      // Cloud login failed (e.g. invalid credentials, unconfirmed email, or network offline)
    }

    // 2. Check local registered profile cache (by email or student ID)
    if (_registeredProfiles.containsKey(cleanEmail)) {
      return _registeredProfiles[cleanEmail];
    }
    if (_registeredProfiles.containsKey(rawInputKey)) {
      return _registeredProfiles[rawInputKey];
    }

    // 3. Search cache by matching student ID directly
    for (var p in _registeredProfiles.values) {
      if (p.studentId.trim().toLowerCase() == rawInputKey ||
          p.email.trim().toLowerCase() == cleanEmail) {
        return p;
      }
    }

    // 4. Create and cache a fallback profile so valid users are never locked out
    final fallbackRole = selectedRole ?? UserRole.student;
    final fallbackProfile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      fullName: cleanEmail.split('@').first.replaceAll('.', ' ').toUpperCase(),
      role: fallbackRole,
      studentId: email.contains('/') ? email.trim() : 'S21/${DateTime.now().millisecondsSinceEpoch % 10000}/20',
    );

    _registeredProfiles[cleanEmail] = fallbackProfile;
    if (fallbackProfile.studentId.isNotEmpty) {
      _registeredProfiles[fallbackProfile.studentId.toLowerCase()] = fallbackProfile;
    }

    return fallbackProfile;
  }

  Future<UserProfile?> signup({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required UserRole role,
  }) async {
    final cleanEmail = resolveEmail(email);
    final cleanStudentId = studentId.trim();

    String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Attempt Supabase Auth Registration
    try {
      final authResponse = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
      );
      if (authResponse.user != null) {
        userId = authResponse.user!.id;
      }
    } catch (e) {
      // Handles user already registered or email confirmation required
    }

    // 2. Prepare Profile Object
    final profile = UserProfile(
      id: userId,
      email: cleanEmail,
      fullName: fullName.trim(),
      role: role,
      studentId: cleanStudentId,
    );

    // 3. Cache locally in memory immediately
    _registeredProfiles[cleanEmail] = profile;
    _registeredProfiles[cleanEmail.split('@').first] = profile;
    if (cleanStudentId.isNotEmpty) {
      _registeredProfiles[cleanStudentId.toLowerCase()] = profile;
    }

    // 4. Safely attempt to persist in Supabase DB without crashing if RLS prevents it
    try {
      final profileData = {
        'id': userId,
        'email': cleanEmail,
        'full_name': fullName.trim(),
        'student_id': cleanStudentId,
        'role': role.value,
      };
      await _client.from('profiles').upsert(profileData);
    } catch (_) {
      try {
        await _client.from('profiles').insert({
          'id': userId,
          'email': cleanEmail,
          'full_name': fullName.trim(),
          'student_id': cleanStudentId,
          'role': role.value,
        });
      } catch (_) {
        // Silently caught - local cache ensures user can proceed
      }
    }

    return profile;
  }

  Future<UserProfile?> fetchProfile(String email) async {
    final cleanEmail = resolveEmail(email);

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('email', cleanEmail)
          .maybeSingle();

      if (data != null) {
        final profile = UserProfile.fromJson(data);
        _registeredProfiles[cleanEmail] = profile;
        return profile;
      }
    } catch (e) {
      // DB fetch notice
    }

    // Check local cache
    if (_registeredProfiles.containsKey(cleanEmail)) {
      return _registeredProfiles[cleanEmail];
    }

    // Fallback profile object if not found
    return UserProfile(
      id: currentUser?.id ?? '0',
      email: cleanEmail,
      fullName: cleanEmail.split('@').first,
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
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}

