import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_cubit.dart';
import 'package:flutter_blue_plus_playground/blocs/led/led_state.dart';
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
    return BlocBuilder<LEDCubit, LEDState>(
      builder: (context, state) {
        return ListTile(
          leading: Icon(
            state.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
            color: led.color,
          ),
          title: Text(led.name),
          trailing: Switch(
            value: state.isOn,
            onChanged: (value) => context.read<LEDCubit>().toggle(value),
            activeColor: led.color,
          ),
        );
      },
    );
  }

  /// Builds a UI for RGB LEDs with color picker
  static Widget _buildRGBLedUI(LEDRGB led) {
    return BlocBuilder<LEDCubit, LEDState>(
      builder: (context, state) {
        // Get the current color from the LED
        final currentColor = led.selectedColor;
        
        return ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(
            state.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
            color: currentColor,
          ),
          title: Text(led.name),
          trailing: Switch(
            value: state.isOn,
            onChanged: (value) => context.read<LEDCubit>().toggle(value),
            activeColor: currentColor,
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
                    color: currentColor,
                    onColorChanged: (color) async {
                      await led.updateColor(color);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Simple color picker widget
class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _color;
  // Add variables to track the current slider values
  late double _redValue;
  late double _greenValue;
  late double _blueValue;
  // Add a flag to track if we're currently dragging
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    _redValue = _color.red.toDouble();
    _greenValue = _color.green.toDouble();
    _blueValue = _color.blue.toDouble();
  }
  
  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _color = widget.color;
      _redValue = _color.red.toDouble();
      _greenValue = _color.green.toDouble();
      _blueValue = _color.blue.toDouble();
    }
  }

  // Method to update the color when a slider is released
  void _updateColor() {
    if (_isDragging) {
      setState(() {
        _color = Color.fromARGB(
          255, 
          _redValue.round().toInt(), 
          _greenValue.round().toInt(), 
          _blueValue.round().toInt()
        );
        widget.onColorChanged(_color);
      });
      _isDragging = false;
    }
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
        _buildSlider('Red', _redValue, (value) {
          setState(() {
            _redValue = value;
            // Update the preview color immediately
            _color = Color.fromARGB(
              255, 
              _redValue.round().toInt(), 
              _greenValue.round().toInt(), 
              _blueValue.round().toInt()
            );
          });
        }, () {
          _isDragging = true;
        }, () {
          _updateColor();
        }),
        _buildSlider('Green', _greenValue, (value) {
          setState(() {
            _greenValue = value;
            // Update the preview color immediately
            _color = Color.fromARGB(
              255, 
              _redValue.round().toInt(), 
              _greenValue.round().toInt(), 
              _blueValue.round().toInt()
            );
          });
        }, () {
          _isDragging = true;
        }, () {
          _updateColor();
        }),
        _buildSlider('Blue', _blueValue, (value) {
          setState(() {
            _blueValue = value;
            // Update the preview color immediately
            _color = Color.fromARGB(
              255, 
              _redValue.round().toInt(), 
              _greenValue.round().toInt(), 
              _blueValue.round().toInt()
            );
          });
        }, () {
          _isDragging = true;
        }, () {
          _updateColor();
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

  Widget _buildSlider(
    String label, 
    double value, 
    ValueChanged<double> onChanged,
    VoidCallback onDragStart,
    VoidCallback onDragEnd,
  ) {
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
          onChangeStart: (_) => onDragStart(),
          onChangeEnd: (_) => onDragEnd(),
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = color;
          _redValue = color.red.toDouble();
          _greenValue = color.green.toDouble();
          _blueValue = color.blue.toDouble();
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