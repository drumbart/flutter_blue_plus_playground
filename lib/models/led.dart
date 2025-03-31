import 'dart:ui' show Color;

class LED {
  Color color;

  LED({required this.color});

  @override
  bool operator ==(Object other) => identical(this, other) || other is LED && runtimeType == other.runtimeType && color == other.color;

  @override
  int get hashCode => color.hashCode;

  @override
  String toString() {
    return 'LED{color: $color}';
  }
}
