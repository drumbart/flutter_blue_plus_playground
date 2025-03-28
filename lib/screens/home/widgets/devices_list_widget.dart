import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/ble_devices_cubit.dart';
import 'package:flutter_blue_plus_playground/navigation/router.dart';
import 'package:flutter_blue_plus_playground/screens/home/widgets/device_tile_widget.dart';
import 'package:go_router/go_router.dart';

class DevicesListWidget extends StatelessWidget {
  const DevicesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BleDevicesCubit>().state;
    return state.bleDevices.isEmpty
        ? const Center(child: Text("No devices found."))
        : ListView.builder(
            itemCount: state.bleDevices.length,
            itemBuilder: (context, index) {
              final device = state.bleDevices[index];
              return DeviceTileWidget(
                title: device.displayName,
                connectButtonText: state.isDeviceConnected(device) ? "Disconnect" : "Connect",
                showConnectButton: device.isConnectable,
                onTilePressed: () {
                  if (device.isConnectable) {
                    context.push(NavigationState.deviceScreen.route, extra: device);
                  }
                },
                onConnectButtonPressed: () {
                  if (state.isDeviceConnected(device)) {
                    context.read<BleDevicesCubit>().disconnectFromDevice();
                  } else {
                    context.read<BleDevicesCubit>().connectToDevice(device.scanResult.device);
                  }
                },
              );
            },
          );
  }
}
