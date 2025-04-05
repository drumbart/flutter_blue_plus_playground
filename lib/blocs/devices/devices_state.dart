import 'package:flutter_blue_plus_playground/models/ble_device.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}

class DevicesState {
  final bool isScanning;
  final List<BleDevice> bleDevices;
  final BleDevice? connectedDevice;
  final String? error;
  final ConnectionState connectionState;

  bool get isConnected => connectionState == ConnectionState.connected;
  bool get isConnecting => connectionState == ConnectionState.connecting;
  bool get isDisconnecting => connectionState == ConnectionState.disconnecting;
  bool get hasError => error != null;

  bool isDeviceConnected(BleDevice device) => 
      isConnected && connectedDevice?.id == device.id;

  List<BleDevice> get allDevices =>
      connectedDevice != null ? [connectedDevice!, ...bleDevices.where((d) => d.id != connectedDevice!.id)] : bleDevices;

  DevicesState({
    this.isScanning = false,
    this.bleDevices = const [],
    this.connectedDevice,
    this.error,
    this.connectionState = ConnectionState.disconnected,
  });

  DevicesState copyWith({
    bool? isScanning,
    List<BleDevice>? bleDevices,
    BleDevice? connectedDevice,
    String? error,
    ConnectionState? connectionState,
  }) {
    return DevicesState(
      isScanning: isScanning ?? this.isScanning,
      bleDevices: bleDevices ?? this.bleDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      error: error,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
