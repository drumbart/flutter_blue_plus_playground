import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_playground/screens/home/widgets/devices_loader_widget.dart';
import 'package:flutter_blue_plus_playground/screens/home/widgets/devices_list_widget.dart';
import 'package:flutter_blue_plus_playground/screens/home/widgets/scan_buttons_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ESP32 BLE Playground")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ScanButtonsHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  const DevicesLoaderWidget(),
                  Expanded(child: const DevicesListWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
