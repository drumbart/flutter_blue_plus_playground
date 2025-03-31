import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/enums/led_color.dart';

class LEDCharacteristicsFactory {
  static List<BlocProvider<LEDCubit>> createLEDCubits({required List<BluetoothService> services}) {
    final cubits = <BlocProvider<LEDCubit>>[];
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        final ledColor = ledCharacteristicMap[characteristic.uuid.toString().toLowerCase()];
        if (ledColor != null) {
          cubits.add(
            BlocProvider<LEDCubit>(
              create: (context) => LEDCubit(LEDState(ledColor: ledColor, isOn: false)),
            ),
          );
        }
      }
    }
    return cubits;
  }
}
