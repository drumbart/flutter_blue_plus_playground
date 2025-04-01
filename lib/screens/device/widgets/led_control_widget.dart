import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_playground/models/led.dart' show LED;

class LedControlWidget<T extends LED> extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const LedControlWidget({super.key, required this.isOn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isOn,
      onChanged: onChanged,
    );
  }
}
