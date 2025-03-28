import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/ble_devices_cubit.dart';

class DevicesLoaderWidget extends StatelessWidget {
  const DevicesLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BleDevicesCubit>().state;
    return state.isScanning
        ? const Center(
            child: Column(
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 16),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
