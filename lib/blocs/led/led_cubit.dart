import 'package:flutter/material.dart' show Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';

class LEDCubit extends Cubit<LEDState> {
  LEDCubit() : super(LEDState(led: LED(color: Colors.red), isOn: false));

  void setLedState(bool isOn) {
    emit(state.copyWith(isOn: isOn));
  }

  void toggleLed() {
    emit(state.copyWith(isOn: !state.isOn));
  }
}
