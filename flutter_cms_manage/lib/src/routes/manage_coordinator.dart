import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'api_layout.dart';
import 'overview_route.dart';
import 'deployments_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';
import 'not_found_route.dart';
import 'login_route.dart';
import 'setup_wizard_route.dart';
import 'client_picker_route.dart';

class ManageCoordinator extends Coordinator<ManageRoute> {
  String clientSlug = '';

  late final manageStack = NavigationPath<ManageRoute>.createWith(
    coordinator: this,
    label: 'manage',
  )..bindLayout(ManageLayout.new);

  late final apiStack = NavigationPath<ManageRoute>.createWith(
    coordinator: this,
    label: 'api',
  )..bindLayout(ApiLayout.new);

  @override
  List<StackPath> get paths => [...super.paths, manageStack, apiStack];

  @override
  ManageRoute? parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;

    // 1. Root URL → client picker
    if (segments.isEmpty) return ClientPickerRoute();

    // 2. Reserved paths (not client slugs)
    if (segments.first == 'login') return LoginRoute();
    if (segments.first == 'setup') return SetupWizardRoute();

    // 3. Everything else: first segment is clientSlug
    final slug = segments.first;
    if (slug.isEmpty) return ClientPickerRoute();
    clientSlug = slug;
    final rest = segments.skip(1).toList();

    return switch (rest) {
      [] => OverviewRoute(clientSlug),
      ['overview'] => OverviewRoute(clientSlug),
      ['api', 'tokens'] => TokensRoute(clientSlug),
      ['deployments'] => DeploymentsRoute(clientSlug),
      ['settings'] => SettingsRoute(clientSlug),
      _ => NotFoundRoute(),
    };
  }
}
