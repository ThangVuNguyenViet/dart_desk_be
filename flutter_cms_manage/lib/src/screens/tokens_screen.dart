import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class TokensScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const TokensScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tokens — coming soon'));
  }
}
