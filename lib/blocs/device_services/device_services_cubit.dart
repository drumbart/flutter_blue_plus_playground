import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothDevice, BluetoothService;
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_state.dart';
import 'package:flutter_blue_plus_playground/services/ble_service.dart';

class DeviceServicesCubit extends Cubit<DeviceServicesState> {
  final BleService bleService;

  DeviceServicesCubit(this.bleService, List<BluetoothService> services) : super(DeviceServicesState(services: services));

  Future<void> loadServicesForDevice(BluetoothDevice device) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final services = await bleService.loadServicesForDevice(device);
      emit(state.copyWith(services: services, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
