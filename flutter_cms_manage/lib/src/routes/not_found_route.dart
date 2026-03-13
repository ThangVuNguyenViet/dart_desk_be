import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import 'overview_route.dart';

class NotFoundRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/404');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page not found', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          ShadButton(
            child: const Text('Go Home'),
            onPressed: () => coordinator.push(
              OverviewRoute(coordinator.clientSlug),
            ),
          ),
        ],
      ),
    );
  }
}
