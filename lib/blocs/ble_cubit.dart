import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_playground/blocs/ble_state.dart';
import 'package:flutter_blue_plus_playground/models/ble_device.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';

class BleCubit extends Cubit<BleState> {
  final BleService bleService;

  BleCubit(this.bleService) : super(BleState()) {
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
                if (a.displayName == "ESP32-BLE") return -1;
                if (b.displayName == "ESP32-BLE") return 1;
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

  Future<void> connectToDevice(BluetoothDevice device) async {
    final connected = await bleService.connectToDevice(device);
    emit(state.copyWith(connectedDevice: connected));
  }

  Future<void> disconnectFromDevice() async {
    await bleService.disconnectFromDevice(state.connectedDevice!);
    emit(state.copyWith(connectedDevice: null));
  }
}
