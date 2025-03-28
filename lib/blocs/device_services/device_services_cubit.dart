import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/device_services/device_services_state.dart';

class DeviceCharacteristicsCubit extends Cubit<DeviceServicesState> {
  DeviceCharacteristicsCubit() : super(DeviceServicesState());

  void getDeviceCharacteristics() {}
}
