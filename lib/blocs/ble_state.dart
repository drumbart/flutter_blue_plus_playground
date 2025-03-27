import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothDevice;
import 'package:flutter_blue_plus_playground/models/ble_device.dart';

class BleState {
  final bool isScanning;
  final List<BleDevice> scanResults;
  BluetoothDevice? connectedDevice;

  BleState({
    this.isScanning = false,
    this.scanResults = const [],
    this.connectedDevice,
  });

  BleState copyWith({
    bool? isScanning,
    List<BleDevice>? scanResults,
    BluetoothDevice? connectedDevice,
  }) {
    return BleState(
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleState &&
          runtimeType == other.runtimeType &&
          isScanning == other.isScanning &&
          scanResults == other.scanResults &&
          connectedDevice == other.connectedDevice;

  @override
  int get hashCode => isScanning.hashCode ^ scanResults.hashCode ^ connectedDevice.hashCode;
}