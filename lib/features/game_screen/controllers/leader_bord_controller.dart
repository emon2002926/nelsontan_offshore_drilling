import 'package:get/get.dart';

class LeaderboardController extends GetxController {
  final isLoading = false.obs;
  final currentWeek = 42.obs;

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
    isLoading.value = true;

    // TODO: Replace with your API call
    await Future.delayed(const Duration(milliseconds: 500));

    players.value = [
      {'name': 'Eiden', 'totalScore': 2430, 'weeklyScore': 1250, 'hazards': 8, 'avatar': 'assets/images/avatar_eiden.png'},
      {'name': 'Emma Aria', 'totalScore': 1674, 'weeklyScore': 950, 'hazards': 6, 'avatar': 'assets/images/avatar_emma.png'},
      {'name': 'Jackson', 'totalScore': 1847, 'weeklyScore': 850, 'hazards': 4, 'avatar': 'assets/images/avatar_jackson.png'},
      {'name': 'Natalie', 'totalScore': 1320, 'weeklyScore': 750, 'hazards': 3, 'avatar': 'assets/images/avatar_natalie.png'},
      {'name': 'Hannah', 'totalScore': 1105, 'weeklyScore': 650, 'hazards': 1, 'avatar': 'assets/images/avatar_hannah.png'},
    ];

    isLoading.value = false;
  }

  Future<void> refreshLeaderboard() async => await fetchLeaderboard();
}