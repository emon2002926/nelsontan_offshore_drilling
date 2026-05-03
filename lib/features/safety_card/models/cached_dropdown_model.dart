import 'package:hive/hive.dart';

class CachedDropdownModel extends HiveObject {
  @HiveField(0) final List<Map> areas;
  @HiveField(1) final List<Map> cardTypes;
  @HiveField(2) final List<Map> hazards;
  @HiveField(3) final DateTime  cachedAt;

  CachedDropdownModel({
    required this.areas,
    required this.cardTypes,
    required this.hazards,
    required this.cachedAt,
  });
}