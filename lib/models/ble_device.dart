import 'package:flutter_blue_plus/flutter_blue_plus.dart' show ScanResult;

class BleDevice {
  final ScanResult scanResult;
  final bool isConnectable;

  String get id => scanResult.device.remoteId.str;
  String? get name => scanResult.device.platformName.isEmpty ? null : scanResult.device.platformName;

  BleDevice({required this.scanResult, required this.isConnectable});

  static BleDevice fromScanResult(ScanResult scanResult) {
    return BleDevice(
      scanResult: scanResult,
      isConnectable: scanResult.device.platformName == "ESP32-BLE",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice &&
          runtimeType == other.runtimeType &&
          scanResult == other.scanResult &&
          isConnectable == other.isConnectable;

  @override
  int get hashCode => scanResult.hashCode ^ isConnectable.hashCode;

  @override
  String toString() {
    return 'BleDevice{scanResult: $scanResult, isConnectable: $isConnectable}';
  }
}
