import 'package:flutter_blue_plus_playground/models/led.dart';

class LEDState<T extends LED> {
  final T led;
  final bool isOn;

  LEDState({required this.led, required this.isOn});

  LEDState copyWith({T? led, bool? isOn}) {
    return LEDState(
      led: led ?? this.led,
      isOn: isOn ?? this.isOn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LEDState && runtimeType == other.runtimeType && led == other.led && isOn == other.isOn;

  @override
  int get hashCode => led.hashCode ^ isOn.hashCode;

  @override
  String toString() {
    return 'LEDState{led: $led, isOn: $isOn}';
  }
}
