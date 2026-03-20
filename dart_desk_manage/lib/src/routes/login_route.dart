import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/login_screen.dart';

class LoginRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/login');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      const LoginScreen();
}
