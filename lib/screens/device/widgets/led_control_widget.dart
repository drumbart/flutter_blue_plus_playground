import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';

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
    return ListTile(
      title: Text(state.led.name),
      trailing: Switch(
        thumbColor: WidgetStateProperty.all(state.led.color),
        trackColor: WidgetStateProperty.all(Colors.white10),
        value: state.isOn,
        onChanged: (value) => context.read<LEDCubit>().toggle(value),
      ),
    );
  }
}