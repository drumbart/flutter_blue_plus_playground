import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/enums/led_color.dart';

class LEDCubit extends Cubit<LEDState> {
  LEDCubit() : super(LEDState(ledColor: LEDColor.red, isOn: false));

  void setLedState(bool isOn) {
    emit(state.copyWith(isOn: isOn));
  }

  void toggleLed() {
    emit(state.copyWith(isOn: !state.isOn));
  }
}
