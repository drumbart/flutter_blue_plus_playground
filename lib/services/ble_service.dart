import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleException implements Exception {
  final String message;
  final dynamic originalError;

  BleException(this.message, [this.originalError]);

  @override
  String toString() => 'BleException: $message${originalError != null ? ' (Original error: $originalError)' : ''}';
}

class BleService {
  final StreamController<List<ScanResult>> _scanResultsController = StreamController.broadcast();
  final StreamController<bool> _isScanningController = StreamController.broadcast();
  final StreamController<BluetoothDevice?> _connectedDeviceController = StreamController.broadcast();
  final StreamController<BluetoothAdapterState> _adapterStateController = StreamController.broadcast();
  
  final Duration scanTimeout;
  BluetoothDevice? _connectedDevice;
  bool _isDisposed = false;

  Stream<List<ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<bool> get isScanningStream => _isScanningController.stream;
  Stream<BluetoothDevice?> get connectedDeviceStream => _connectedDeviceController.stream;
  Stream<BluetoothAdapterState> get adapterStateStream => _adapterStateController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  BleService({this.scanTimeout = const Duration(seconds: 10)}) {
    _listenForChanges();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    _scanResultsController.close();
    _isScanningController.close();
    _connectedDeviceController.close();
    _adapterStateController.close();
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw BleException('BleService has been disposed');
    }
  }

  void _listenForChanges() {
    FlutterBluePlus.scanResults.listen(
      (results) {
        _checkDisposed();
        _scanResultsController.add(results);
      },
      onError: (error) {
        _checkDisposed();
        _scanResultsController.addError(
          BleException('Failed to receive scan results', error),
        );
      },
    );

    FlutterBluePlus.isScanning.listen(
      (result) {
        _checkDisposed();
        _isScanningController.add(result);
      },
      onError: (error) {
        _checkDisposed();
        _isScanningController.addError(
          BleException('Failed to receive scanning state', error),
        );
      },
    );

    FlutterBluePlus.adapterState.listen(
      (state) {
        _checkDisposed();
        _adapterStateController.add(state);
      },
      onError: (error) {
        _checkDisposed();
        _adapterStateController.addError(
          BleException('Failed to receive adapter state', error),
        );
      },
    );

    FlutterBluePlus.connectedDevices.listen(
      (devices) {
        _checkDisposed();
        if (devices.isEmpty && _connectedDevice != null) {
          _connectedDevice = null;
          _connectedDeviceController.add(null);
        }
      },
      onError: (error) {
        _checkDisposed();
        _connectedDeviceController.addError(
          BleException('Failed to receive connected devices', error),
        );
      },
    );
  }

  Future<void> startScan() async {
    _checkDisposed();
    
    try {
      final adapterState = await FlutterBluePlus.adapterState.firstWhere(
        (state) => state == BluetoothAdapterState.on,
        orElse: () => throw BleException('Bluetooth adapter is not available'),
      );
      
      if (adapterState != BluetoothAdapterState.on) {
        throw BleException('Bluetooth adapter is not turned on');
      }
      
      FlutterBluePlus.startScan(timeout: scanTimeout);
    } catch (e) {
      throw BleException('Failed to start scan', e);
    }
  }

  void stopScan() {
    _checkDisposed();
    
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      throw BleException('Failed to stop scan', e);
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    _checkDisposed();
    
    try {
      if (_connectedDevice != null) {
        await disconnectFromDevice(_connectedDevice!);
      }
      
      await device.connect();
      _connectedDevice = device;
      _connectedDeviceController.add(device);
      return true;
    } catch (e) {
      throw BleException('Failed to connect to device', e);
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    _checkDisposed();
    
    try {
      await device.disconnect();
      if (_connectedDevice?.remoteId == device.remoteId) {
        _connectedDevice = null;
        _connectedDeviceController.add(null);
      }
    } catch (e) {
      throw BleException('Failed to disconnect from device', e);
    }
  }

  Future<List<BluetoothService>> loadServicesForDevice(BluetoothDevice device) async {
    _checkDisposed();
    
    try {
      return await device.discoverServices();
    } catch (e) {
      throw BleException('Failed to discover services', e);
    }
  }
}
