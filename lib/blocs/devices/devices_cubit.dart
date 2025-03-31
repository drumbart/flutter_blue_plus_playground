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
    bleService.isScanningStream.listen((result) {
      emit(state.copyWith(isScanning: result));
    });

    bleService.scanResultsStream.listen(
      (results) {
        emit(
          state.copyWith(
            bleDevices: results.map((e) => BleDevice.fromScanResult(e)).toList()
              ..sort((a, b) {
                if (a.displayName.contains("ESP32")) return -1;
                if (b.displayName.contains("ESP32")) return 1;
                return 0;
              }),
          ),
        );
      },
    );
  }

  void startScan() {
    emit(state.copyWith(isScanning: true));
    bleService.startScan();
  }

  void stopScan() {
    emit(state.copyWith(isScanning: false));
    bleService.stopScan();
  }

  Future<void> connectToDevice(BleDevice device) async {
    final connected = await bleService.connectToDevice(device.scanResult.device);
    emit(state.copyWith(connectedDevice: connected ? device : null));
  }

  Future<void> disconnectFromDevice() async {
    await bleService.disconnectFromDevice(state.connectedDevice!.scanResult.device);
    emit(state.copyWith(connectedDevice: null));
  }
}
