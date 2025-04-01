import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';

class LEDCharacteristicsFactory {
  static List<LED> createLEDs({required List<BluetoothService> services}) {
    final leds = <LED>[];
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        final type = ledCharacteristicMap[characteristic.uuid.toString().toLowerCase()];
        if (type != null) {
          leds.add(LED.init(type, characteristic));
        }
      }
    }
    return leds;
  }

  static List<BlocProvider<LEDCubit<T>>> createLEDProviders<T extends LED>({required List<T> leds}) {
    print("LEDs: ${leds.map((l) => l.runtimeType)}");
    final providers = <BlocProvider<LEDCubit<T>>>[];
    for (T led in leds) {
      final ledCubit = LEDCubit<T>(LEDState<T>(led: led, isOn: false));
      providers.add(BlocProvider<LEDCubit<T>>(create: (context) => ledCubit));
    }
    print('LED providers created: ${providers.map((p) => p.runtimeType)}');
    return providers;
  }
}
