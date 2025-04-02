import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';

class LEDCubit extends Cubit<LEDState> {
  final LEDState initialState;

  LEDCubit(this.initialState) : super(initialState);

  void toggle(bool isOn) {
    emit(state.copyWith(isOn: isOn));
  }
}
