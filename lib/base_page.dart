import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/features/games/views/game_page.dart';
import 'package:nelsontan_offshore_drilling/features/home/views/home_screen.dart';
import 'package:nelsontan_offshore_drilling/features/profile/views/profile_page.dart';
import 'package:nelsontan_offshore_drilling/features/videos/views/videos_page.dart';

import 'core/widgets/bottom_navigation/bottom_navigation.dart';
import 'features/safety_card/views/safety_card_screen.dart';
import 'features/videos/controllers/video_manager.dart';

  class BasePage extends StatefulWidget {
    const BasePage({super.key});
    @override
    State<BasePage> createState() => BasePageState();
  }

  class BasePageState extends State<BasePage> {
    int currentIndex = 0;
    int lastTapTime = 0;

    final homeNavKey = GlobalKey<NavigatorState>();
    final cardsNavKey = GlobalKey<NavigatorState>();
    final gameNavKey = GlobalKey<NavigatorState>();
    final videosNavKey = GlobalKey<NavigatorState>();
    final profileNavKey = GlobalKey<NavigatorState>();

    // 🔥 Declare controllers here

    @override
    void initState() {
      super.initState();
      // 🔥 Initialize controllers in initState

    }

    void onTabSelected(int index) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // ✅ Pause all videos when leaving the Videos tab
      if (currentIndex == 3 && index != 3) {
        VideoManager.to.pauseAll();
      }

      if (index == currentIndex && currentTime - lastTapTime < 500) {
        if (index == 0) {
          homeNavKey.currentState?.popUntil((route) => route.isFirst);
        } else if (index == 1) {
          cardsNavKey.currentState?.popUntil((route) => route.isFirst);
        } else if (index == 2) {
          gameNavKey.currentState?.popUntil((route) => route.isFirst);
        } else if (index == 3) {
          videosNavKey.currentState?.popUntil((route) => route.isFirst);
        } else if (index == 4) {
          profileNavKey.currentState?.popUntil((route) => route.isFirst);
        }
      } else {
        setState(() => currentIndex = index);
      }

      lastTapTime = currentTime;
    }

    @override
    Widget build(BuildContext context) {
      final screens = [
        HomeScreen(),
        SafetyCardScreen(),
        GamePage(),
        VideosPage(),
        ProfilePage()
      ];

      return Scaffold(
        backgroundColor: Colors.grey,
        extendBody: true,
        body: WillPopScope(
          onWillPop: () {
            if (currentIndex == 0 && homeNavKey.currentState!.canPop()) {
              homeNavKey.currentState?.pop();
              return Future.value(false);
            } else if (currentIndex == 1 && cardsNavKey.currentState!.canPop()) {
              cardsNavKey.currentState?.pop();
              return Future.value(false);
            } else if (currentIndex == 2 && gameNavKey.currentState!.canPop()) {
              gameNavKey.currentState?.pop();
              return Future.value(false);
            } else if (currentIndex == 3 && videosNavKey.currentState!.canPop()) {
              videosNavKey.currentState?.pop();
              return Future.value(false);
            }else if (currentIndex == 4 && profileNavKey.currentState!.canPop()) {
              profileNavKey.currentState?.pop();
              return Future.value(false);
            }

            return Future.value(true);
          },
          child: IndexedStack(
            index: currentIndex,
            children: [
              Navigator(
                key: homeNavKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [MaterialPageRoute(builder: (context) => screens[0])];
                },
              ),
              Navigator(
                key: cardsNavKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [MaterialPageRoute(builder: (context) => screens[1])];
                },
              ),
              Navigator(
                key: gameNavKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [MaterialPageRoute(builder: (context) => screens[2])];
                },
              ),
              Navigator(
                key: videosNavKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [MaterialPageRoute(builder: (context) => screens[3])];
                },
              ),
              Navigator(
                key: profileNavKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [MaterialPageRoute(builder: (context) => screens[4])];
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomBottomNavigationBar(
              currentIndex: currentIndex,
              onTabSelected: onTabSelected,
            ),
          ],
        ),
      );
    }


  }