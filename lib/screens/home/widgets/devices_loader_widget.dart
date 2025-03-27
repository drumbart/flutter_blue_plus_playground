import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_playground/blocs/ble_cubit.dart';

class DevicesLoaderWidget extends StatelessWidget {
  const DevicesLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BleCubit>().state;
    return state.isScanning ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
  }
}
