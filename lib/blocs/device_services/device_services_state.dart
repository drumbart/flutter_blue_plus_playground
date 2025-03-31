import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothService;

class DeviceServicesState {
  final List<BluetoothService> services;
  final bool isLoading;
  final String? error;

  DeviceServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
  });

  DeviceServicesState copyWith({
    List<BluetoothService>? services,
    bool? isLoading,
    String? error,
  }) {
    return DeviceServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
