import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/client_picker_screen.dart';

class ClientPickerRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      ClientPickerScreen(coordinator: coordinator);
}
