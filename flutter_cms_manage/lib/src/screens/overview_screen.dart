import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class OverviewScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const OverviewScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Overview — coming soon'));
  }
}
