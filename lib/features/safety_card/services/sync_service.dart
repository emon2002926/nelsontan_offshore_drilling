import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../models/pending_submission_model.dart';
import 'connectivity_service.dart';
import 'hive_boxes.dart';



class SyncService extends GetxService {

  final ApiServices          _api          = Get.find<ApiServices>();
  final ConnectivityService  _connectivity = Get.find<ConnectivityService>();

  final RxInt  pendingCount = 0.obs; // drives badge in UI
  final RxBool isSyncing    = false.obs;

  static const int _maxRetries = 3;

  late final StreamSubscription<void> _connectionSubscription;

  @override
  void onInit() {
    super.onInit();
    _refreshPendingCount();

    // Trigger sync whenever device comes back online
    _connectionSubscription = _connectivity.onConnected.listen((_) {
      processPendingQueue();
    });

    // Also attempt sync on app start if already online
    if (_connectivity.isOnline.value) {
      processPendingQueue();
    }
  }

  // ── Called by SafetyCardController after saving to Hive ──────────────
  void refreshPendingCount() => _refreshPendingCount();

  void _refreshPendingCount() {
    pendingCount.value = HiveBoxes.pendingBox.values
        .where((s) => s.syncStatus != SyncStatus.failed)
        .length;
  }

  // ── Core sync logic ───────────────────────────────────────────────────
  Future<void> processPendingQueue() async {
    if (isSyncing.value) return; // prevent concurrent runs
    if (!_connectivity.isOnline.value) return;

    final pending = HiveBoxes.pendingBox.values
        .where((s) => s.syncStatus == SyncStatus.pending)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // oldest first

    if (pending.isEmpty) return;

    isSyncing.value = true;
    int successCount = 0;

    for (final submission in pending) {
      final uploaded = await _uploadSingle(submission);
      if (uploaded) successCount++;
    }

    isSyncing.value = false;
    _refreshPendingCount();

    if (successCount > 0) {
      CustomSnackBar.success(
        '$successCount card${successCount > 1 ? 's' : ''} synced successfully!',
      );
    }

    final failedCount = HiveBoxes.pendingBox.values
        .where((s) => s.syncStatus == SyncStatus.failed)
        .length;
    if (failedCount > 0) {
      CustomSnackBar.error(
        '$failedCount card${failedCount > 1 ? 's' : ''} failed to sync. Tap to retry.',
      );
    }
  }

  Future<bool> _uploadSingle(PendingSubmissionModel submission) async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return false;

    // Mark as syncing so UI reflects it
    submission.syncStatus = SyncStatus.syncing;
    await submission.save();

    try {
      final fields = <String, String>{
        'cardTypeId':        submission.cardTypeId.toString(),
        'areaId':            submission.areaId.toString(),
        'hazardId':          submission.hazardIds.first.toString(),
        'description':       submission.description,
        'riskSeverity':      submission.riskSeverity,
        'actionTaken':       submission.actionTaken.toString(),
        'immediateAction':   submission.immediateAction.toString(),
        'submitAnonymously': submission.submitAnonymously.toString(),
      };

      final imageFile = submission.localImagePath != null
          ? File(submission.localImagePath!)
          : null;

      await _api.postFormData(
        '/card-submission/create',
        headers: {'Authorization': 'Bearer $token'},
        fields: fields,
        imageFile: imageFile,
        imageFieldName: 'media',
      );

      // Success — remove from Hive permanently
      await submission.delete();
      return true;

    } catch (_) {
      submission.retryCount++;

      if (submission.retryCount >= _maxRetries) {
        submission.syncStatus = SyncStatus.failed;
      } else {
        // Back to pending — will retry next time device comes online
        submission.syncStatus = SyncStatus.pending;
      }

      await submission.save();
      return false;
    }
  }

  // ── Manual retry for 'failed' records (call from UI) ─────────────────
  Future<void> retryFailed() async {
    final failed = HiveBoxes.pendingBox.values
        .where((s) => s.syncStatus == SyncStatus.failed)
        .toList();

    for (final submission in failed) {
      submission.syncStatus = SyncStatus.pending;
      submission.retryCount = 0;
      await submission.save();
    }

    _refreshPendingCount();
    await processPendingQueue();
  }

  @override
  void onClose() {
    _connectionSubscription.cancel();
    super.onClose();
  }
}