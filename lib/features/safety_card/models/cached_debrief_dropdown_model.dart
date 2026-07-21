import 'package:hive/hive.dart';

class CachedDebriefDropdownModel extends HiveObject {
  @HiveField(0) final List<Map> activities;
  @HiveField(1) final List<Map> debriefTypes;
  @HiveField(2) final DateTime  cachedAt;
  @HiveField(3) final List<Map> questions; // [{'id': ..., 'question': ..., 'placeholder': ...}]

  CachedDebriefDropdownModel({
    required this.activities,
    required this.debriefTypes,
    required this.cachedAt,
    this.questions = const [],
  });
}