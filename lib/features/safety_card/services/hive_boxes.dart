import 'package:hive_flutter/hive_flutter.dart';
import '../../profile/data/models/profile_hive_model.dart';
import '../models/cached_debrief_dropdown_model.dart';
import '../models/cached_dropdown_model.dart';
import '../models/pending_debrief_model.dart';
import '../models/pending_submission_model.dart';
import 'adapters/cached_debrief_dropdown_adapter.dart';
import 'adapters/cached_dropdown_adapter.dart';
import 'adapters/pending_debrief_adapter.dart';
import 'adapters/pending_submission_adapter.dart';


class HiveBoxes {
  HiveBoxes._();

  // ── Box name constants ─────────────────────────────────────────────────
  static const String pendingSubmissions    = 'pending_submissions';
  static const String dropdownCache         = 'dropdown_cache';
  static const String pendingDebriefs       = 'pending_debriefs';
  static const String debriefDropdownCache  = 'debrief_dropdown_cache';
  static const String profileCache          = 'profile_cache';         // ← ADD

  // ── Cache keys ─────────────────────────────────────────────────────────
  static const String dropdownCacheKey        = 'cache';
  static const String debriefDropdownCacheKey = 'cache';
  static const String profileCacheKey         = 'profile';             // ← ADD

  // ── Box accessors ──────────────────────────────────────────────────────
  static Box<PendingSubmissionModel>     get pendingBox =>
      Hive.box<PendingSubmissionModel>(pendingSubmissions);

  static Box<CachedDropdownModel>        get dropdownBox =>
      Hive.box<CachedDropdownModel>(dropdownCache);

  static Box<PendingDebriefModel>        get pendingDebriefBox =>
      Hive.box<PendingDebriefModel>(pendingDebriefs);

  static Box<CachedDebriefDropdownModel> get debriefDropdownBox =>
      Hive.box<CachedDebriefDropdownModel>(debriefDropdownCache);

  static Box<ProfileHiveModel>           get profileBox =>             // ← ADD
  Hive.box<ProfileHiveModel>(profileCache);

  // ── One-time init ──────────────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(PendingSubmissionModelAdapter());
    Hive.registerAdapter(CachedDropdownModelAdapter());
    Hive.registerAdapter(PendingDebriefModelAdapter());
    Hive.registerAdapter(CachedDebriefDropdownModelAdapter());
    Hive.registerAdapter(ProfileHiveModelAdapter());                   // ← ADD

    await Hive.openBox<PendingSubmissionModel>(pendingSubmissions);
    await Hive.openBox<CachedDropdownModel>(dropdownCache);
    await Hive.openBox<PendingDebriefModel>(pendingDebriefs);
    await Hive.openBox<CachedDebriefDropdownModel>(debriefDropdownCache);
    await Hive.openBox<ProfileHiveModel>(profileCache);                // ← ADD
  }
}