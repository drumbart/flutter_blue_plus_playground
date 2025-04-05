import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_playground/models/led.dart';

/// Factory class for creating UI widgets for different LED types
class LedUIFactory {
  /// Creates a UI widget for the given LED
  static Widget buildUI(LED led) {
    if (led is LEDRGB) {
      return _buildRGBLedUI(led);
    } else {
      return _buildStandardLedUI(led);
    }
  }

  /// Builds a standard UI for single-color LEDs
  static Widget _buildStandardLedUI(LED led) {
    return ListTile(
      leading: Icon(
        led.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
        color: led.color,
      ),
      title: Text(led.name),
      trailing: Switch(
        value: led.isOn,
        onChanged: (value) => led.setState(value),
        activeColor: led.color,
      ),
    );
  }

  /// Builds a UI for RGB LEDs with color picker
  static Widget _buildRGBLedUI(LEDRGB led) {
    return ExpansionTile(
      leading: Icon(
        led.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
        color: led.selectedColor,
      ),
      title: Text(led.name),
      trailing: Switch(
        value: led.isOn,
        onChanged: (value) => led.setState(value),
        activeColor: led.selectedColor,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Color:'),
              const SizedBox(height: 8),
              ColorPicker(
                color: led.selectedColor,
                onColorChanged: (color) {
                  led.updateColor(color);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple color picker widget
class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    Key? key,
    required this.color,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Color preview
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        // RGB sliders
        _buildSlider('Red', _color.r.toDouble(), (value) {
          setState(() {
            _color = Color.fromARGB(255, value.round(), _color.g.toInt(), _color.b.toInt());
            widget.onColorChanged(_color);
          });
        }),
        _buildSlider('Green', _color.g.toDouble(), (value) {
          setState(() {
            _color = Color.fromARGB(255, _color.r.toInt(), value.round(), _color.b.toInt());
            widget.onColorChanged(_color);
          });
        }),
        _buildSlider('Blue', _color.b.toDouble(), (value) {
          setState(() {
            _color = Color.fromARGB(255, _color.r.toInt(), _color.g.toInt(), value.round());
            widget.onColorChanged(_color);
          });
        }),
        const SizedBox(height: 16),
        // Preset colors
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorButton(Colors.red),
            _buildColorButton(Colors.green),
            _buildColorButton(Colors.blue),
            _buildColorButton(Colors.yellow),
            _buildColorButton(Colors.purple),
            _buildColorButton(Colors.orange),
            _buildColorButton(Colors.white),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = color;
          widget.onColorChanged(_color);
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _color == color ? Colors.black : Colors.grey,
            width: _color == color ? 2 : 1,
          ),
        ),
      ),
    );
  }
}