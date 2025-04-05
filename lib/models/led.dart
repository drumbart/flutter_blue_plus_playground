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
          name: 'Red LED',
          characteristic: characteristic,
        );
}

class LEDGreen extends LED {
  LEDGreen(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFF00FF00),
          name: 'Green LED',
          characteristic: characteristic,
        );
}

class LEDYellow extends LED {
  LEDYellow(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFFFFFF00),
          name: 'Yellow LED',
          characteristic: characteristic,
        );
}

class LEDRGB extends LED {
  Color selectedColor = const Color(0xFFFFFFFF);
  
  LEDRGB(BluetoothCharacteristic characteristic)
      : super(
          color: const Color(0xFFFFFFFF),
          name: 'RGB LED',
          characteristic: characteristic,
        );
  
  // Override the _writeState method to handle RGB color
  @override
  Future<void> _writeState() async {
    try {
      if (isOn) {
        // Send the current RGB color when turning on
        await characteristic.write([
          1, // Indicates this is a color update
          selectedColor.red,
          selectedColor.green,
          selectedColor.blue,
        ]);
        debugPrint('Sent RGB color on toggle: R=${selectedColor.red}, G=${selectedColor.green}, B=${selectedColor.blue}');
      } else {
        // Just send 0 to turn off the LED
        await characteristic.write([0]);
      }
    } catch (e) {
      debugPrint('Error writing to RGB LED: $e');
    }
  }
  
  // Method to update the selected color
  Future<void> updateColor(Color color) async {
    selectedColor = color;
    
    // Only send the color if the LED is on
    if (isOn) {
      try {
        // Send RGB values to the ESP32
        // Format: [1, R, G, B] where R, G, B are values from 0-255
        await characteristic.write([
          1, // Indicates this is a color update
          color.red,
          color.green,
          color.blue,
        ]);
        debugPrint('Sent RGB color: R=${color.red}, G=${color.green}, B=${color.blue}');
      } catch (e) {
        debugPrint('Error sending RGB color to ESP32: $e');
      }
    }
  }
}
