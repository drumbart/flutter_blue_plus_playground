import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/devices_cubit.dart';
import 'package:flutter_blue_plus_playground/navigation/router.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';
import 'package:flutter_blue_plus_playground/theme/theme.dart';

@pragma('vm:entry-point')
void appClipMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Flutter Blue Plus
  try {
    await FlutterBluePlus.turnOn();
  } catch (e) {
    print('Error initializing Flutter Blue Plus: $e');
  }
  
  runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DevicesCubit(BleService()),
      child: MaterialApp.router(
        theme: appTheme(),
        routerConfig: appRouter,
      ),
    );
  }
} 