import 'package:flutter_blue_plus_playground/enums/led_color.dart';

class LEDState {
  final LEDColor ledColor;
  final bool isOn;

  LEDState({required this.ledColor, required this.isOn});

  LEDState copyWith({LEDColor? ledColor, bool? isOn}) {
    return LEDState(
      ledColor: ledColor ?? this.ledColor,
      isOn: isOn ?? this.isOn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LEDState && runtimeType == other.runtimeType && ledColor == other.ledColor && isOn == other.isOn;

  @override
  int get hashCode => ledColor.hashCode ^ isOn.hashCode;

  @override
  String toString() {
    return 'LEDState(isOn: $isOn)';
  }
}
