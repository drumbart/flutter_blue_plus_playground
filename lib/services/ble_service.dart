import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final StreamController<List<ScanResult>> _scanResultsController = StreamController.broadcast();
  final StreamController<bool> _isScanningController = StreamController.broadcast();

  Stream<List<ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<bool> get isScanningStream => _isScanningController.stream;

  // BluetoothCharacteristic? _targetCharacteristic;

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

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      return true;
    } catch (e) {
      print("Error connecting to device: $e");
      return false;
    }

    // List<BluetoothService> services = await device.discoverServices();
    // for (BluetoothService service in services) {
    //   if (service.uuid.toString().toLowerCase().contains("12345678")) {
    //     for (BluetoothCharacteristic characteristic in service.characteristics) {
    //       if (characteristic.uuid.toString().toLowerCase().contains("abcdef01")) {
    //         // _targetCharacteristic = characteristic;
    //         List<int> value = await characteristic.read();
    //         return String.fromCharCodes(value);
    //       }
    //     }
    //   }
    // }
    //
    // return null;
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    return await device.disconnect();
  }
}
