import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'api_layout.dart';
import 'overview_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';
import 'not_found_route.dart';

class ManageCoordinator extends Coordinator<ManageRoute> {
  String clientSlug = '';

  late final manageStack = NavigationPath<ManageRoute>('manage');

  late final apiStack = NavigationPath<ManageRoute>('api');

  @override
  List<StackPath> get paths => [...super.paths, manageStack, apiStack];

  @override
  void defineLayout() {
    RouteLayout.defineLayout(ManageLayout, ManageLayout.new);
    RouteLayout.defineLayout(ApiLayout, ApiLayout.new);
  }

  @override
  ManageRoute parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return NotFoundRoute();

    clientSlug = segments.first;
    final rest = segments.skip(1).toList();

    return switch (rest) {
      [] => OverviewRoute(clientSlug),
      ['overview'] => OverviewRoute(clientSlug),
      ['api', 'tokens'] => TokensRoute(clientSlug),
      ['settings'] => SettingsRoute(clientSlug),
      _ => NotFoundRoute(),
    };
  }
}
