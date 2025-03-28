import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothDevice;
import 'package:flutter_blue_plus_playground/models/ble_device.dart';

class BleState {
  final bool isScanning;
  final List<BleDevice> bleDevices;
  final BluetoothDevice? connectedDevice;

  bool isDeviceConnected(BleDevice device) => connectedDevice == null ? false : connectedDevice!.remoteId.str == device.id;

  BleState({
    this.isScanning = false,
    this.bleDevices = const [],
    this.connectedDevice,
  });

  BleState copyWith({
    bool? isScanning,
    List<BleDevice>? bleDevices,
    BluetoothDevice? connectedDevice,
  }) {
    return BleState(
      isScanning: isScanning ?? this.isScanning,
      bleDevices: bleDevices ?? this.bleDevices,
      connectedDevice: connectedDevice,
    );
  }
}