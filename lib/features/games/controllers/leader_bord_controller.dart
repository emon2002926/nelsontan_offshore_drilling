import 'package:get/get.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import 'package:intl/intl.dart';


class LeaderboardController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final isLoading = false.obs;
  final currentWeek = 1.obs;
  final players = <Map<String, dynamic>>[].obs;

  // Podium order: [silver(left), gold(center), bronze(right)]
  List<Map<String, dynamic>> get podiumPlayers {
    if (players.length < 3) return [];
    final sorted = List<Map<String, dynamic>>.from(players)
      ..sort((a, b) => (b['totalScore'] as int).compareTo(a['totalScore'] as int));
    return [sorted[1], sorted[0], sorted[2]];
  }

  // Weekly ranked list
  List<Map<String, dynamic>> get weeklyRankedPlayers {
    final sorted = List<Map<String, dynamic>>.from(players)
      ..sort((a, b) => (b['weeklyScore'] as int).compareTo(a['weeklyScore'] as int));
    return sorted;
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isLoading.value = true;
    try {
      final raw = await _api.get(
        '/game/leaderboard',
        headers: {"Authorization": "Bearer $token"},
      );

      final data = raw['data'];

      // ── Parse week number from weekRange.from ──
      final fromStr = data['weekRange']['from'] as String;
      final fromDate = DateTime.parse(fromStr);
      currentWeek.value = _isoWeekNumber(fromDate);

      // ── Map leaderboard entries ──
      final leaderboard = data['leaderboard'] as List<dynamic>;
      players.value = leaderboard.map((entry) {
        return <String, dynamic>{
          'name': entry['user']['name'] as String,
          'totalScore': entry['totalScore'] as int,
          'weeklyScore': entry['weeklyScore'] ?? entry['totalScore'] ?? 0,
          'hazards': entry['hazards'] ?? 0,
        };
      }).toList();

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load leaderboard. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLeaderboard() async => await fetchLeaderboard();

  /// ISO-8601 week number
  int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}