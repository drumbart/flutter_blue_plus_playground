import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothDevice;
import 'package:flutter_blue_plus_playground/models/ble_device.dart';

class DevicesState {
  final bool isScanning;
  final List<BleDevice> bleDevices;
  final BluetoothDevice? connectedDevice;

  bool isDeviceConnected(BleDevice device) => connectedDevice == null ? false : connectedDevice!.remoteId.str == device.id;

  DevicesState({
    this.isScanning = false,
    this.bleDevices = const [],
    this.connectedDevice,
  });

  DevicesState copyWith({
    bool? isScanning,
    List<BleDevice>? bleDevices,
    BluetoothDevice? connectedDevice,
  }) {
    return DevicesState(
      isScanning: isScanning ?? this.isScanning,
      bleDevices: bleDevices ?? this.bleDevices,
      connectedDevice: connectedDevice,
    );
  }
}