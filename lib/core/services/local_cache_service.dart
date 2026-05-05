import 'package:hive_flutter/hive_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// LocalCacheService  –  a thin, generic wrapper around a single Hive box.
///
/// HOW TO REUSE IN ANOTHER PROJECT
/// ────────────────────────────────
/// This service is completely model-agnostic.  Drop it into any project as-is.
/// Create one instance per box you need (profile, settings, cart, etc.).
///
/// Usage example:
///   final cache = LocalCacheService<ProfileHiveModel>('profile_box');
///   await cache.init();          // call once, usually in main() or binding
///   await cache.save(hiveModel);
///   final model = cache.get();   // null if never saved
///   await cache.clear();
/// ─────────────────────────────────────────────────────────────────────────────
class LocalCacheService<T> {
  final String boxName;

  // Single-record boxes use this fixed key so callers never think about keys.
  static const _singleKey = 'data';

  Box<T>? _box;

  LocalCacheService(this.boxName);

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  /// Open the Hive box.  Call this before any read/write (once per app run).
  Future<void> init() async {
    _box = await Hive.openBox<T>(boxName);
  }

  /// Close the box when it's no longer needed (optional – Hive handles it on
  /// app exit, but explicit closing is cleaner in tests).
  Future<void> close() async => _box?.close();

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Returns the cached value, or `null` if nothing has been saved yet.
  T? get() => _box?.get(_singleKey);

  /// True when there is at least one cached value.
  bool get hasData => get() != null;

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Persists [value].  Overwrites any previously stored value.
  Future<void> save(T value) async => _box?.put(_singleKey, value);

  /// Deletes the stored value.
  Future<void> clear() async => _box?.delete(_singleKey);
}