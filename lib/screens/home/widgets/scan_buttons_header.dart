import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/devices_cubit.dart';

class ScanButtonsHeader extends StatelessWidget {
  const ScanButtonsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => context.read<DevicesCubit>().startScan(),
          child: const Text("Start Scan"),
        ),
        ElevatedButton(
          onPressed: () => context.read<DevicesCubit>().stopScan(),
          child: const Text("Stop Scan"),
        ),
      ],
    );
  }
}
