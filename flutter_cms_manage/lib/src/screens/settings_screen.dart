import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class SettingsScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const SettingsScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings — coming soon'));
  }
}
