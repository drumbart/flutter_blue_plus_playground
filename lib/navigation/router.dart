import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/screens/device/device_screen.dart';
import 'package:flutter_blue_plus_playground/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

enum NavigationState {
  homeScreen("/"),
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
      builder: (_, state) => DeviceScreen(device: state.extra as BleDevice),
    ),
  ],
  redirect: (_, state) async {
    if (state.matchedLocation == '/') {
      return NavigationState.homeScreen.route;
    }
    return null;
  },
);
