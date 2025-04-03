import 'dart:async' show StreamSubscription;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';

class LEDCubit extends Cubit<LEDState> {
  final LEDState initialState;
  StreamSubscription<List<int>>? _subscription;

  LEDCubit(this.initialState) : super(initialState);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void toggle(bool isOn) {
    final newVal = isOn ? '1' : '0';
    state.led.characteristic.write(newVal.codeUnits, withoutResponse: false).then((value) {
      emit(state.copyWith(isOn: isOn));
    }).catchError((error) {
      print("Error writing LED state: $error");
    });
  }

  void readAndSetLEDState() {
    final char = state.led.characteristic;

    // Listen to notifications
    _subscription = char.onValueReceived.listen((value) {
      if (isClosed) return;
      final valueStr = String.fromCharCodes(value);
      final parsed = valueStr == '1';
      emit(state.copyWith(isOn: parsed));
    }, cancelOnError: true);

    // First read current LED state
    char.read().then((value) {
      final valueStr = String.fromCharCodes(value);
      final parsed = valueStr == '1';
      emit(state.copyWith(isOn: parsed));
    }).catchError((error) {
      print("Error reading initial LED state: $error");
    });

    // Then enable notifications
    char.setNotifyValue(true).catchError((error) {
      print("Error enabling LED notifications: $error");
      return false;
    });
  }
}
