import 'dart:ui' show Color;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothCharacteristic;

Map<String, Type> ledCharacteristicMap = {
  'ff000000-1234-5678-1234-56789abcdef0': LEDRed,
  'ffff0000-1234-5678-1234-56789abcdef0': LEDYellow,
  '00ff0000-1234-5678-1234-56789abcdef0': LEDGreen,
  'ffffffff-1234-5678-1234-56789abcdef0': LEDRGB,
};

abstract class LED {
  final Color color;
  final String name;
  final BluetoothCharacteristic characteristic;
  bool isOn = false;

  static LED init(Type type, BluetoothCharacteristic characteristic) {
    if (type == LEDRed) {
      return LEDRed(characteristic);
    } else if (type == LEDGreen) {
      return LEDGreen(characteristic);
    } else if (type == LEDYellow) {
      return LEDYellow(characteristic);
    } else if (type == LEDRGB) {
      return LEDRGB(characteristic);
    }
    throw Exception('Unknown LED type: $type');
  }

  LED({required this.color, required this.name, required this.characteristic});

  // Toggle the LED state
  Future<void> toggle() async {
    isOn = !isOn;
    await _writeState();
  }

  // Set the LED state
  Future<void> setState(bool state) async {
    isOn = state;
    await _writeState();
  }

  // Write the current state to the BLE characteristic
  Future<void> _writeState() async {
    try {
      await characteristic.write([isOn ? 1 : 0]);
    } catch (e) {
      debugPrint('Error writing to LED: $e');
    }
  }

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
    return 'LED{color: $color, name: $name, characteristic: $characteristic, isOn: $isOn}';
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

class LEDRGB extends LED {
  Color selectedColor = const Color(0xFFFFFFFF);
  
  LEDRGB(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFFFFFFFF),
          name: '🌈 RGB LED',
          characteristic: characteristic,
        );
  
  // Override the _writeState method to handle RGB color
  @override
  Future<void> _writeState() async {
    try {
      if (isOn) {
        // For now, we'll just send the on/off state
        // Later we'll update the Arduino code to handle RGB values
        await characteristic.write([1]);
      } else {
        await characteristic.write([0]);
      }
    } catch (e) {
      debugPrint('Error writing to RGB LED: $e');
    }
  }
  
  // Method to update the selected color
  void updateColor(Color color) {
    selectedColor = color;
    // We'll implement color sending to the Arduino later
  }
}
