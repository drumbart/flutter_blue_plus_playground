import 'dart:ui' show Color;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothCharacteristic;

Map<String, Type> ledCharacteristicMap = {
  'ff000000-1234-5678-1234-56789abcdef0': LEDRed,
  '00ff0000-1234-5678-1234-56789abcdef0': LEDGreen,
  'ffff0000-1234-5678-1234-56789abcdef0': LEDYellow,
};

abstract class LED {
  final Color color;
  final String name;
  final BluetoothCharacteristic characteristic;

  static LED init(Type type, BluetoothCharacteristic characteristic) {
    if (type == LEDRed) {
      return LEDRed(characteristic);
    } else if (type == LEDGreen) {
      return LEDGreen(characteristic);
    } else if (type == LEDYellow) {
      return LEDYellow(characteristic);
    }
    throw Exception('Unknown LED type: $type');
  }

  LED({required this.color, required this.name, required this.characteristic});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LED &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          name == other.name &&
          characteristic == other.characteristic;

  @override
  int get hashCode => color.hashCode ^ name.hashCode ^ characteristic.hashCode;

  @override
  String toString() {
    return 'LED{color: $color, name: $name, characteristic: $characteristic}';
  }
}

class LEDRed extends LED {
  LEDRed(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFFFF0000),
          name: '🔴 Red LED',
          characteristic: characteristic,
        );
}

class LEDGreen extends LED {
  LEDGreen(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFF00FF00),
          name: '🟢 Green LED',
          characteristic: characteristic,
        );
}

class LEDYellow extends LED {
  LEDYellow(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFFFFFF00),
          name: '🟡 Yellow LED',
          characteristic: characteristic,
        );
}
