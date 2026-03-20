import 'package:flutter/material.dart';

import 'manage_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/overview_screen.dart';

class OverviewRoute extends ManageRoute {
  final String clientSlug;
  OverviewRoute(this.clientSlug);

  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/overview');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      OverviewScreen(coordinator: coordinator);
}
