import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/ble_cubit.dart';
import 'package:flutter_blue_plus_playground/screens/home/widgets/device_tile_widget.dart';

class DevicesListWidget extends StatelessWidget {
  const DevicesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BleCubit>().state;
    return state.bleDevices.isEmpty
        ? const Center(child: Text("No devices found."))
        : ListView.builder(
            itemCount: state.bleDevices.length,
            itemBuilder: (context, index) {
              final device = state.bleDevices[index];
              return DeviceTileWidget(
                title: device.name ?? device.id,
                connectButtonText: state.isDeviceConnected(device) ? "Disconnect" : "Connect",
                showConnectButton: device.isConnectable,
                onTilePressed: () {},
                onConnectButtonPressed: () {
                  if (state.isDeviceConnected(device)) {
                    context.read<BleCubit>().disconnectFromDevice();
                  } else {
                    context.read<BleCubit>().connectToDevice(device.scanResult.device);
                  }
                },
              );
            },
          );
  }
}
