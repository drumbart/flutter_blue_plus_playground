import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';
import 'package:flutter_blue_plus_playground/factories/led_ui_factory.dart';

class LedControlWidget extends StatelessWidget {
  final LED led;

  const LedControlWidget({super.key, required this.led});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LEDCubit(LEDState(led: led, isOn: false)),
      child: const _LEDControlContent(),
    );
  }
}

class _LEDControlContent extends StatelessWidget {
  const _LEDControlContent();

  @override
  Widget build(BuildContext context) {
    context.read<LEDCubit>().readAndSetLEDState();
    final state = context.watch<LEDCubit>().state;
    
    // Use the LED UI factory to build the appropriate UI
    return LedUIFactory.buildUI(state.led);
  }
}