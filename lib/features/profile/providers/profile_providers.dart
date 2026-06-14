import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_profile.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  // Access SharedPreferences via workout repo pattern or a dedicated provider
  // For implementation, we'll assume a global prefs exists or inject it.
  throw UnimplementedError('Initialize in main.dart');
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;
  static const _key = 'user_profile_v1';

  ProfileNotifier(this._prefs) : super(UserProfile.defaultProfile()) {
    _load();
  }

  void _load() {
    final data = _prefs.getString(_key);
    if (data != null) {
      state = UserProfile.fromJson(jsonDecode(data));
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    await _prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
