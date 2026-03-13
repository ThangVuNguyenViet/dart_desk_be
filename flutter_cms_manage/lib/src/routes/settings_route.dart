import 'package:flutter/material.dart';

import 'manage_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/settings_screen.dart';

class SettingsRoute extends ManageRoute {
  final String clientSlug;
  SettingsRoute(this.clientSlug);

  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/settings');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SettingsScreen(coordinator: coordinator);
}
