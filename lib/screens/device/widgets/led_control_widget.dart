import 'package:flutter/material.dart';

class LedControlWidget extends StatelessWidget {
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
