import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';



class ConnectivityService extends GetxService {

  final RxBool isOnline = false.obs;

  final _onConnectedController = StreamController<void>.broadcast();
  Stream<void> get onConnected => _onConnectedController.stream;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  // Called from main() with await before runApp — guarantees correct
  // initial state before any controller reads isOnline
  Future<ConnectivityService> init() async {
    final results = await Connectivity().checkConnectivity();
    isOnline.value = _hasConnection(results);
    _listenToChanges();
    return this;
  }

  void _listenToChanges() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final wasOffline = !isOnline.value;
      isOnline.value   = _hasConnection(results);

      if (wasOffline && isOnline.value) {
        _onConnectedController.add(null);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
    r == ConnectivityResult.mobile   ||
        r == ConnectivityResult.wifi     ||
        r == ConnectivityResult.ethernet);
  }

  @override
  void onClose() {
    _subscription.cancel();
    _onConnectedController.close();
    super.onClose();
  }
}