import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_playground/screens/device/device_screen.dart';
import 'package:flutter_blue_plus_playground/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

enum NavigationState {
  homeScreen("/homeScreen"),
  deviceScreen("/deviceScreen");

  final String route;

  const NavigationState(this.route);
}

final globalNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: globalNavigatorKey,
  routes: [
    GoRoute(
      path: NavigationState.homeScreen.route,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: NavigationState.deviceScreen.route,
      builder: (_, __) => const DeviceScreen(),
    ),
  ],
  redirect: (_, state) async {
    if (state.matchedLocation == '/') {
      return NavigationState.homeScreen.route;
    }
    return null;
  },
);
