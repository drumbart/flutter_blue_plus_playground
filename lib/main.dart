import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/ble_cubit.dart';
import 'package:flutter_blue_plus_playground/navigation/router.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';
import 'package:flutter_blue_plus_playground/theme/theme.dart';

void main() {
  runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleCubit(BleService()),
      child: MaterialApp.router(
        theme: appTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
