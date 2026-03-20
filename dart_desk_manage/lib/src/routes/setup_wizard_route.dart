import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/setup_wizard_screen.dart';

class SetupWizardRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/setup');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SetupWizardScreen(coordinator: coordinator);
}
