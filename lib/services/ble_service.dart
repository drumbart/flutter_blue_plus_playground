import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final StreamController<List<ScanResult>> _scanResultsController = StreamController.broadcast();
  final StreamController<bool> _isScanningController = StreamController.broadcast();

  Stream<List<ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<bool> get isScanningStream => _isScanningController.stream;

  BleService() {
    _listenForChanges();
  }

  void dispose() {
    _scanResultsController.close();
    _isScanningController.close();
  }

  void _listenForChanges() {
    FlutterBluePlus.scanResults.listen((results) {
      _scanResultsController.add(results);
    });

    FlutterBluePlus.isScanning.listen((result) {
      _isScanningController.add(result);
    });
  }

  void startScan() async {
    await FlutterBluePlus.adapterState.firstWhere((state) => state == BluetoothAdapterState.on);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  /// \@throws Exception if there is an error connecting to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      return true;
    } catch (e) {
      print("Error connecting to device: $e");
      rethrow;
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    return await device.disconnect();
  }

  /// \@throws Exception if there is an error discovering services.
  Future<List<BluetoothService>> loadServicesForDevice(BluetoothDevice device) async {
    try {
      return await device.discoverServices();
    } catch (e) {
      print("Error discovering services: $e");
      rethrow;
    }
  }
}
