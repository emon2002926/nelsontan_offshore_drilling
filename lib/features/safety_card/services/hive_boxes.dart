import 'package:hive_flutter/hive_flutter.dart';

import '../models/cached_dropdown_model.dart';
import '../models/pending_submission_model.dart';


import 'package:hive_flutter/hive_flutter.dart';

import 'adapters/cached_dropdown_adapter.dart';
import 'adapters/pending_submission_adapter.dart';



class HiveBoxes {
  HiveBoxes._();

  static const String dropdownCache    = 'dropdown_cache';
  static const String dropdownCacheKey = 'cache';
  static const String pendingSubmissions = 'pending_submissions';

  static Box<CachedDropdownModel> get dropdownBox =>
      Hive.box<CachedDropdownModel>(dropdownCache);

  static Box<PendingSubmissionModel> get pendingBox =>
      Hive.box<PendingSubmissionModel>(pendingSubmissions);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CachedDropdownModelAdapter());
    Hive.registerAdapter(PendingSubmissionModelAdapter());
    await Hive.openBox<CachedDropdownModel>(dropdownCache);
    await Hive.openBox<PendingSubmissionModel>(pendingSubmissions);
  }
}