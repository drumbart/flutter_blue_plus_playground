import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/devices/devices_state.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final BleService bleService;

  DevicesCubit(this.bleService) : super(DevicesState()) {
    _listenForChanges();
  }

  void _listenForChanges() {
    bleService.isScanningStream.listen(
      (result) => emit(state.copyWith(isScanning: result)),
      onError: (error) => emit(state.copyWith(
        error: error.toString(),
        connectionState: ConnectionState.error,
      )),
    );

    bleService.scanResultsStream.listen(
      (results) => emit(state.copyWith(
        bleDevices: _sortDevices(results.map((e) => BleDevice.fromScanResult(e)).toList()),
      )),
      onError: (error) {
        print('Error in scan results stream: $error');
        emit(state.copyWith(
        error: error.toString(),
        connectionState: ConnectionState.error,
      ));
      },
    );

    bleService.connectedDeviceStream.listen(
      (device) {
        if (device == null && state.connectionState == ConnectionState.connected) {
          emit(state.copyWith(
            connectedDevice: null,
            connectionState: ConnectionState.disconnected,
          ));
        }
      },
      onError: (error) => emit(state.copyWith(
        error: error.toString(),
        connectionState: ConnectionState.error,
      )),
    );
  }

  List<BleDevice> _sortDevices(List<BleDevice> devices) {
    return devices..sort((a, b) {
      if (a.displayName.contains("ESP32")) return -1;
      if (b.displayName.contains("ESP32")) return 1;
      return 0;
    });
  }

  void startScan() {
    if (state.isScanning) return;
    
    try {
      emit(state.copyWith(
        isScanning: true,
        error: null,
      ));
      bleService.startScan();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isScanning: false,
      ));
    }
  }

  void stopScan() {
    if (!state.isScanning) return;
    
    try {
      emit(state.copyWith(
        isScanning: false,
        error: null,
      ));
      bleService.stopScan();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isScanning: true,
      ));
    }
  }

  Future<void> connectToDevice(BleDevice device) async {
    if (state.isConnecting || state.isConnected) return;
    
    try {
      emit(state.copyWith(
        error: null,
        connectionState: ConnectionState.connecting,
      ));
      
      final connected = await bleService.connectToDevice(device.scanResult.device);
      
      emit(state.copyWith(
        connectedDevice: connected ? device : null,
        connectionState: connected ? ConnectionState.connected : ConnectionState.error,
        error: connected ? null : 'Failed to connect to device',
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        connectionState: ConnectionState.error,
      ));
    }
  }

  Future<void> disconnectFromDevice() async {
    if (state.connectedDevice == null || state.isDisconnecting) return;
    
    try {
      emit(state.copyWith(
        error: null,
        connectionState: ConnectionState.disconnecting,
      ));
      
      await bleService.disconnectFromDevice(state.connectedDevice!.scanResult.device);
      
      emit(state.copyWith(
        connectedDevice: null,
        connectionState: ConnectionState.disconnected,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        connectionState: ConnectionState.error,
      ));
    }
  }

  @override
  Future<void> close() {
    if (state.connectedDevice != null) {
      disconnectFromDevice();
    }
    if (state.isScanning) {
      stopScan();
    }
    bleService.dispose();
    return super.close();
  }
}
