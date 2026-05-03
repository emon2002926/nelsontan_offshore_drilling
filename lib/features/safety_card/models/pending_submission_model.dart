import 'package:hive/hive.dart';



class PendingSubmissionModel extends HiveObject {
  @HiveField(0)  final String   localId;
  @HiveField(1)  final int      cardTypeId;
  @HiveField(2)  final int      areaId;
  @HiveField(3)  final List<int> hazardIds;
  @HiveField(4)  final String   description;
  @HiveField(5)  final String   riskSeverity;
  @HiveField(6)  final bool     actionTaken;
  @HiveField(7)  final bool     immediateAction;
  @HiveField(8)  final bool     submitAnonymously;
  @HiveField(9)  final String?  localImagePath;
  @HiveField(10) final DateTime createdAt;
  @HiveField(11)       String   syncStatus;
  @HiveField(12)       int      retryCount;

  PendingSubmissionModel({
    required this.localId,
    required this.cardTypeId,
    required this.areaId,
    required this.hazardIds,
    required this.description,
    required this.riskSeverity,
    required this.actionTaken,
    required this.immediateAction,
    required this.submitAnonymously,
    this.localImagePath,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
    this.retryCount = 0,
  });
}

class SyncStatus {
  static const String pending = 'pending';
  static const String syncing = 'syncing';
  static const String failed  = 'failed';
}