import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:signals/signals_flutter.dart';
import 'package:zenrouter/zenrouter.dart';

import '../providers/manage_providers.dart';
import 'manage_coordinator.dart';
import 'manage_route.dart';
import 'overview_route.dart';
import 'settings_route.dart';
import 'deployments_route.dart';
import 'tokens_route.dart';

class ManageLayout extends ManageRoute with RouteLayout<ManageRoute> {
  @override
  NavigationPath<ManageRoute> resolvePath(ManageCoordinator coordinator) =>
      coordinator.manageStack;

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return ManageShell(
      coordinator: coordinator,
      child: super.build(coordinator, context),
    );
  }
}

class ManageShell extends StatefulWidget {
  final ManageCoordinator coordinator;
  final Widget child;

  const ManageShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  State<ManageShell> createState() => _ManageShellState();
}

class _ManageShellState extends State<ManageShell> {
  String _initializedSlug = '';

  @override
  void initState() {
    super.initState();
    _initClient();
  }

  @override
  void didUpdateWidget(ManageShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coordinator.clientSlug != _initializedSlug) {
      _initClient();
    }
  }

  void _initClient() {
    final slug = widget.coordinator.clientSlug;
    if (slug.isNotEmpty && slug != _initializedSlug) {
      _initializedSlug = slug;
      initClientContext(slug);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _TopBar(coordinator: widget.coordinator),
          _ProjectHeader(coordinator: widget.coordinator),
          _TabNavigation(coordinator: widget.coordinator),
          const Divider(height: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _TopBar({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slug = currentClientSlug.watch(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Flutter CMS',
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ShadButton.ghost(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Open Studio ($slug.dartdesk.dev)'),
                const SizedBox(width: 4),
                Icon(LucideIcons.externalLink, size: 14),
              ],
            ),
            onPressed: () {
              launchUrl(Uri.parse('https://$slug.dartdesk.dev'));
            },
          ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            key: const ValueKey('logout_button'),
            onPressed: () => logout(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 14,
                  child: Text('U', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.logOut, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _ProjectHeader({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slugValue = currentClientSlug.watch(context);
    final clientState = currentClient.watch(context);
    final client = clientState.value;
    final name = client?.name ?? slugValue;
    final slug = client?.slug ?? slugValue;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.h3),
              Text('Project ID: $slug', style: theme.textTheme.muted),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabNavigation extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _TabNavigation({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final slug = coordinator.clientSlug;

    return ListenableBuilder(
      listenable:
          Listenable.merge([coordinator.manageStack, coordinator.apiStack]),
      builder: (context, _) {
        final path = coordinator.currentUri.path;
        final isOverview =
            path.endsWith('/overview') || path == '/$slug';
        final isDeployments = path.endsWith('/deployments');
        final isTokens = path.contains('/api/');
        final isSettings = path.endsWith('/settings');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _TabButton(
                  label: 'Overview',
                  isActive: isOverview,
                  onPressed: () => coordinator.push(OverviewRoute(slug))),
              _TabButton(
                  label: 'Deployments',
                  isActive: isDeployments,
                  onPressed: () =>
                      coordinator.push(DeploymentsRoute(slug))),
              _TabButton(
                  label: 'API',
                  isActive: isTokens,
                  onPressed: () => coordinator.push(TokensRoute(slug))),
              _TabButton(
                  label: 'Settings',
                  isActive: isSettings,
                  onPressed: () => coordinator.push(SettingsRoute(slug))),
            ],
          ),
        );
      },
    );
  }

}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ShadButton.ghost(
        size: ShadButtonSize.sm,
        decoration: isActive
            ? ShadDecoration(
                border: ShadBorder(
                  bottom: ShadBorderSide(
                      color: theme.colorScheme.primary, width: 2),
                ),
              )
            : null,
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.foreground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
