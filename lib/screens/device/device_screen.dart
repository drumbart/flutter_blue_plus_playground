import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/blocs/ble_cubit.dart';

class DeviceScreen extends StatelessWidget {
  final BleDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select<BleCubit, bool>(
      (cubit) => cubit.state.isDeviceConnected(device),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(device.displayName),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (isConnected) {
                context.read<BleCubit>().disconnectFromDevice();
              } else {
                context.read<BleCubit>().connectToDevice(device.scanResult.device);
              }
            },
            child: Text(isConnected ? 'Disconnect' : 'Connect'),
          ),
          const SizedBox(width: 48),
        ],
      ),
      body: Center(
        child: Text('Details of ${device.displayName}'),
      ),
    );
  }
}
