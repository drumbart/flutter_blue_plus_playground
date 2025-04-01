import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_state.dart';
import 'package:flutter_blue_plus_playground/factories/led_characteristics_factory.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';

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
          final ledProviders = LEDCharacteristicsFactory.createLEDProviders(leds: leds);
          return MultiBlocProvider(
              providers: ledProviders,
              child: ListView.builder(
                itemCount: leds.length,
                itemBuilder: (context, index) {
                  final led = leds[index];
                  return ListTile(
                    title: Text(led.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // children: service.characteristics.map((characteristic) {
                      //   final isLedChar = characteristic.uuid.toString().toLowerCase().contains("redled01");
                      //   if (isLedChar) {
                      //     return StatefulBuilder(
                      //       builder: (context, setState) {
                      //         bool isOn = false;
                      //         characteristic.read().then((value) {
                      //           final valueStr = String.fromCharCodes(value);
                      //           final parsed = valueStr == '1';
                      //           if (parsed != isOn) {
                      //             setState(() {
                      //               isOn = parsed;
                      //             });
                      //           }
                      //         });
                      //         return Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Text('Characteristic: ${characteristic.uuid}'),
                      //             Switch(
                      //               value: isOn,
                      //               onChanged: (newValue) async {
                      //                 final newVal = newValue ? '1' : '0';
                      //                 await characteristic.write(newVal.codeUnits, withoutResponse: false);
                      //                 setState(() {
                      //                   isOn = newValue;
                      //                 });
                      //               },
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   } else {
                      //     return Text('Characteristic: ${characteristic.uuid}');
                      //   }
                      // }).toList(),
                    ),
                  );
                },
              ));
        }
      },
    );
  }
}
