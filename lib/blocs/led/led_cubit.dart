import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';

class LEDCubit extends Cubit<LEDState> {
  final LEDState initialState;

  LEDCubit(this.initialState) : super(initialState);

  void setLedState(bool isOn) {
    emit(state.copyWith(isOn: isOn));
  }

  void toggleLed() {
    emit(state.copyWith(isOn: !state.isOn));
  }
}
