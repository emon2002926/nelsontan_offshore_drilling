import 'package:hive/hive.dart';

class PendingDebriefModel extends HiveObject {
  @HiveField(0) final String localId;
  @HiveField(1) final int    activityId;
  @HiveField(2) final int    typeOfDevriefId;  // typo matches API
  @HiveField(3) final List<Map> questionAnswer; // [{'question': ..., 'answer': ...}]
  @HiveField(4) final bool   submitAnonymously;
  @HiveField(5) final DateTime createdAt;
  @HiveField(6)       String syncStatus;
  @HiveField(7)       int    retryCount;

  PendingDebriefModel({
    required this.localId,
    required this.activityId,
    required this.typeOfDevriefId,
    required this.questionAnswer,
    required this.submitAnonymously,
    required this.createdAt,
    this.syncStatus = 'pending',
    this.retryCount = 0,
  });
}
