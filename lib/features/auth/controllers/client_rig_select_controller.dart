
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../models/client_rig_model.dart';
import '../views/account_status_screen.dart';
import '../views/signin_screen.dart';
import 'package:get/get.dart';

class ClientRigSelectController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final clients        = <ClientModel>[].obs;
  final rigs           = <RigModel>[].obs;
  final selectedClient = Rxn<ClientModel>();
  final selectedRig    = Rxn<RigModel>();
  final isLoadingData  = true.obs;
  final isSubmitting   = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClientsAndRigs();
  }

  Future<void> fetchClientsAndRigs() async {
    isLoadingData.value = true;
    try {
      final raw  = await _api.get('/company/with-rigs');
      final list = (raw["data"] as List<dynamic>? ?? [])
          .map((c) => ClientModel.fromJson(c))
          .toList();
      clients.assignAll(list);
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load clients. Please try again.');
    } finally {
      isLoadingData.value = false;
    }
  }

  void onClientChanged(ClientModel? client) {
    selectedClient.value = client;
    selectedRig.value    = null;
    rigs.assignAll(client?.rigs ?? []);
  }

  void onRigChanged(RigModel? rig) => selectedRig.value = rig;

  Future<void> submitRequest() async {
    final client = selectedClient.value;
    final rig    = selectedRig.value;

    if (client == null) {
      CustomSnackBar.warning('Please select a client');
      return;
    }
    if (rig == null) {
      CustomSnackBar.warning('Please select a rig');
      return;
    }

    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isSubmitting.value = true;
    try {
      await _api.post(
        '/user/with-rigs',
        headers: {"Authorization": "Bearer $token"},
        body: {"client": client.id, "rig": rig.id},
      );

      CustomSnackBar.success('Request submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      AppNavigation.pushAndClear(
        const AccountStatusScreen(status: AccountStatus.pending),
      );
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Something went wrong. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
