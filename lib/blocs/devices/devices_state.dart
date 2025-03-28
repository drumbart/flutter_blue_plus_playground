import 'package:flutter_blue_plus_playground/models/ble_device.dart';

class DevicesState {
  final bool isScanning;
  final List<BleDevice> bleDevices;
  final BleDevice? connectedDevice;

  bool isDeviceConnected(BleDevice device) => connectedDevice == null ? false : connectedDevice!.id == device.id;

  List<BleDevice> get allDevices =>
      connectedDevice != null ? [connectedDevice!, ...bleDevices.where((d) => d.id != connectedDevice!.id)] : bleDevices;

  DevicesState({
    this.isScanning = false,
    this.bleDevices = const [],
    this.connectedDevice,
  });

  DevicesState copyWith({
    bool? isScanning,
    List<BleDevice>? bleDevices,
    BleDevice? connectedDevice,
  }) {
    return DevicesState(
      isScanning: isScanning ?? this.isScanning,
      bleDevices: bleDevices ?? this.bleDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }
}
