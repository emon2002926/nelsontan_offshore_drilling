import 'package:hive/hive.dart';

class PendingDebriefModel extends HiveObject {
  @HiveField(0) final String localId;
  @HiveField(1) final int    activityId;
  @HiveField(2) final int    typeOfDevriefId;
  @HiveField(3) final String whatHappend;      // typo matches API
  @HiveField(4) final String whatWorkedWell;
  @HiveField(5) final String whatImproved;
  @HiveField(6) final bool   submitAnonymously;
  @HiveField(7) final DateTime createdAt;
  @HiveField(8)       String syncStatus;
  @HiveField(9)       int    retryCount;

  PendingDebriefModel({
    required this.localId,
    required this.activityId,
    required this.typeOfDevriefId,
    required this.whatHappend,
    required this.whatWorkedWell,
    required this.whatImproved,
    required this.submitAnonymously,
    required this.createdAt,
    this.syncStatus = 'pending',
    this.retryCount = 0,
  });
}