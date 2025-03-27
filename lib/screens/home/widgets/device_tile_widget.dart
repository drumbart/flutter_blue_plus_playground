import 'package:flutter/material.dart';

class DeviceTileWidget extends StatelessWidget {
  final String title;
  final String connectButtonText;
  final bool showConnectButton;
  final VoidCallback onTilePressed;
  final VoidCallback onConnectButtonPressed;

  const DeviceTileWidget({
    super.key,
    required this.title,
    required this.connectButtonText,
    required this.showConnectButton,
    required this.onTilePressed,
    required this.onConnectButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTilePressed,
      trailing: showConnectButton
          ? ElevatedButton(
              onPressed: onConnectButtonPressed,
              child: Text(connectButtonText),
            )
          : null,
    );
  }
}
