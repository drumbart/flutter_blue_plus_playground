import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_state.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';

class DeviceDetailsWidget extends StatelessWidget {
  final BleDevice device;
  const DeviceDetailsWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    context.read<DeviceServicesCubit>().loadServicesForDevice(device.scanResult.device);
    return BlocBuilder<DeviceServicesCubit, DeviceServicesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.services.isEmpty) {
          return const Center(child: Text('No services found.'));
        } else {
          return ListView.builder(
            itemCount: state.services.length,
            itemBuilder: (context, index) {
              final service = state.services[index];
              return ListTile(
                title: Text('Service: ${service.uuid}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: service.characteristics.map((characteristic) {
                    return Text('Characteristic: ${characteristic.uuid}');
                  }).toList(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
