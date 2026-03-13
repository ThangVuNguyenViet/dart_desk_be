import 'package:flutter/material.dart';

import 'api_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/tokens_screen.dart';

class TokensRoute extends ManageRoute {
  final String clientSlug;
  TokensRoute(this.clientSlug);

  @override
  Type get layout => ApiLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/api/tokens');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      TokensScreen(coordinator: coordinator);
}
