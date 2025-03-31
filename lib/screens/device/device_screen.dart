import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_cubit.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/devices_cubit.dart';
import 'package:flutter_blue_plus_playground/screens/device/widgets/device_details_widget.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';

class DeviceScreen extends StatelessWidget {
  final BleDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select<DevicesCubit, bool>(
      (cubit) => cubit.state.isDeviceConnected(device),
    );
    return BlocProvider(create: (_) => DeviceServicesCubit(BleService(), []),
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.displayName),
          actions: [
            if (device.isConnectable)
            ElevatedButton(
              onPressed: () {
                if (isConnected) {
                  context.read<DevicesCubit>().disconnectFromDevice();
                } else {
                  context.read<DevicesCubit>().connectToDevice(device);
                }
              },
              child: Text(isConnected ? 'Disconnect' : 'Connect'),
            ),
            const SizedBox(width: 48),
          ],
        ),
        body: DeviceDetailsWidget(device: device),
      ),
    );
  }
}
