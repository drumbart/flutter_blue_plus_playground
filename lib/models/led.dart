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
    debugPrint('LED $name toggled to: ${isOn ? "ON" : "OFF"}');
    await _writeState();
  }

  // Set the LED state
  Future<void> setState(bool state) async {
    isOn = state;
    await _writeState();
  }

  // Write the current state to the BLE characteristic
  Future<void> _writeState([List<int>? data]) async {
    try {
      if (data != null) {
        // If data is provided, write it directly (for RGB color updates)
        debugPrint('Writing data to characteristic: $data');
        await characteristic.write(data);
      } else {
        // Otherwise, write the current state (on/off)
        debugPrint('Writing state to characteristic: ${isOn ? "1" : "0"}');
        await characteristic.write(isOn ? [1] : [0]);
      }
    } catch (e) {
      debugPrint('Error writing to characteristic: $e');
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
  
  // Override the toggle method to handle RGB LED specifically
  @override
  Future<void> toggle() async {
    isOn = !isOn;
    debugPrint('RGB LED toggled to: ${isOn ? "ON" : "OFF"}');
    
    if (isOn) {
      // When turning on, send the current color
      // Convert from 0.0-1.0 range to 0-255 range
      final data = [
        1, 
        (selectedColor.r * 255).round(), 
        (selectedColor.g * 255).round(), 
        (selectedColor.b * 255).round()
      ];
      debugPrint('Sending color data on toggle: $data');
      await characteristic.write(data);
    } else {
      // When turning off, just send 0
      debugPrint('Sending OFF command on toggle');
      await characteristic.write([0]);
    }
  }
  
  // Override the _writeState method to handle RGB color
  @override
  Future<void> _writeState([List<int>? data]) async {
    try {
      if (data != null) {
        // If data is provided, write it directly
        debugPrint('Writing RGB data to characteristic: $data');
        await characteristic.write(data);
      } else {
        // If no data provided, use the current state
        if (isOn) {
          // Convert from 0.0-1.0 range to 0-255 range
          final data = [
            1, 
            (selectedColor.r * 255).round(), 
            (selectedColor.g * 255).round(), 
            (selectedColor.b * 255).round()
          ];
          debugPrint('Sending current color data: $data');
          await characteristic.write(data);
        } else {
          debugPrint('Sending OFF command');
          await characteristic.write([0]);
        }
      }
    } catch (e) {
      debugPrint('Error writing to RGB LED: $e');
    }
  }
  
  // Method to update the selected color
  Future<void> updateColor(Color color) async {
    debugPrint('updateColor called with color: R=${color.r}, G=${color.g}, B=${color.b}');
    
    // Store the new color
    selectedColor = color;
    
    // Send the color data to the ESP32 regardless of LED state
    try {
      // Convert color values from 0.0-1.0 range to 0-255 range
      final data = [
        1, 
        (color.r * 255).round(), 
        (color.g * 255).round(), 
        (color.b * 255).round()
      ];
      debugPrint('Sending data to ESP32: $data');
      
      // If the LED is off, turn it on with the new color
      if (!isOn) {
        isOn = true;
        debugPrint('RGB LED was OFF, turning it ON with the new color');
      }
      
      await characteristic.write(data);
      debugPrint('Successfully sent RGB color: R=${(color.r * 255).round()}, G=${(color.g * 255).round()}, B=${(color.b * 255).round()}');
    } catch (e) {
      debugPrint('Error sending RGB color to ESP32: $e');
    }
  }
}
