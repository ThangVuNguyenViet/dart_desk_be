import 'package:flutter/material.dart';

import 'manage_route.dart';
import 'manage_coordinator.dart';
import 'manage_layout.dart';
import '../screens/deployments_screen.dart';

class DeploymentsRoute extends ManageRoute {
  final String clientSlug;
  DeploymentsRoute(this.clientSlug);

  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/deployments');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      DeploymentsScreen(coordinator: coordinator);
}
