import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
}
