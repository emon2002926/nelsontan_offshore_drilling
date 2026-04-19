import 'package:get_storage/get_storage.dart';

import '../../features/auth/models/sign_in_response_model.dart';

class StorageService {
  static final _box = GetStorage();

  static const _tokenKey        = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _languageKey     = 'app_language';
  static const _userKey         = 'user_data';

  // ── Access Token ──────────────────────────────────────────────────────────
  static Future<void> saveToken(String accessToken) async {
    await _box.write(_tokenKey, accessToken);
  }
  static String? get accessToken => _box.read(_tokenKey);
  static bool    get hasToken    => accessToken != null && accessToken!.isNotEmpty;

  // ── Refresh Token ─────────────────────────────────────────────────────────
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _box.write(_refreshTokenKey, refreshToken);
  }
  static String? get refreshToken => _box.read(_refreshTokenKey);

  // ── User ──────────────────────────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await _box.write(_userKey, _userToJson(user));
  }

  static UserModel? get user {
    final raw = _box.read<Map<String, dynamic>>(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  static bool get hasUser => user != null;

  // ── Save token + user together ────────────────────────────────────────────
  static Future<void> saveSession(SignInData data) async {
    await saveToken(data.token);
    await saveUser(data.user);
  }

  // ── Language ──────────────────────────────────────────────────────────────
  static Future<void> saveLanguage(String languageCode) async {
    await _box.write(_languageKey, languageCode);
  }
  static String get language    => _box.read(_languageKey) ?? 'en';
  static bool   get hasLanguage => _box.hasData(_languageKey);

  // ── Clear ─────────────────────────────────────────────────────────────────
  static Future<void> clearToken() async {
    await _box.remove(_tokenKey);
    await _box.remove(_refreshTokenKey);
  }

  static Future<void> logout() async {
    final savedLanguage = language;
    await _box.erase();
    await saveLanguage(savedLanguage);
  }

  // ── Internal serializer ───────────────────────────────────────────────────
  static Map<String, dynamic> _userToJson(UserModel u) => {
    "id":            u.id,
    "name":          u.name,
    "email":         u.email,
    "profile":       u.profile,
    "entryCompany":  u.entryCompany,
    "position":      u.position,
    "phone":         u.phone,
    "isVerified":    u.isVerified,
    "approveStatus": u.approveStatus,
    "status":        u.status,
    "createdAt":     u.createdAt.toIso8601String(),
    "updatedAt":     u.updatedAt.toIso8601String(),
    "companyId":     u.companyId,
    "rigId":         u.rigId,
  };
}