const Map<String, LEDColor> ledCharacteristicMap = {
  'ff000000-1234-5678-1234-56789abcdef0': LEDColor.red,
  '00ff0000-1234-5678-1234-56789abcdef0': LEDColor.green,
  'ffff0000-1234-5678-1234-56789abcdef0': LEDColor.yellow,
};

enum LEDColor {
  red,
  green,
  yellow;

  String colorLabel() {
    return switch (this) {
      LEDColor.red => '🔴 Red LED',
      LEDColor.green => '🟢 Green LED',
      LEDColor.yellow => '🟡 Yellow LED',
    };
  }
}