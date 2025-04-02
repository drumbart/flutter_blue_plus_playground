import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_state.dart';
import 'package:flutter_blue_plus_playground/factories/led_characteristics_factory.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';
import 'package:flutter_blue_plus_playground/screens/device/widgets/led_control_widget.dart';

class DeviceDetailsWidget extends StatelessWidget {
  final BleDevice bleDevice;

  const DeviceDetailsWidget({super.key, required this.bleDevice});

  @override
  Widget build(BuildContext context) {
    context.read<DeviceServicesCubit>().loadServicesForDevice(bleDevice.scanResult.device);
    return BlocBuilder<DeviceServicesCubit, DeviceServicesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.services.isEmpty) {
          return const Center(child: Text('No services found.'));
        } else {
          final leds = LEDCharacteristicsFactory.createLEDs(services: state.services);
          return ListView.builder(
            itemCount: leds.length,
            itemBuilder: (context, index) {
              final led = leds[index];
              return LedControlWidget(led: led);
            },
          );
        }
      },
    );
  }
}
