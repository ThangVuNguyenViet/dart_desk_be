import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_coordinator.dart';
import 'overview_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';
import '../providers/manage_providers.dart';

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

class ManageShell extends StatelessWidget {
  final ManageCoordinator coordinator;
  final Widget child;

  const ManageShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _TopBar(coordinator: coordinator),
          _ProjectHeader(coordinator: coordinator),
          _TabNavigation(coordinator: coordinator),
          const Divider(height: 1),
          Expanded(child: child),
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
                const Text('Open Studio'),
                const SizedBox(width: 4),
                Icon(LucideIcons.externalLink, size: 14),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            onPressed: () => logout(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadAvatar(
                  'U',
                  size: const Size(28, 28),
                  placeholder: const Text('U'),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ShadAvatar(
            '',
            size: const Size(48, 48),
            placeholder: Text(
              coordinator.clientSlug.isNotEmpty
                  ? coordinator.clientSlug[0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coordinator.clientSlug, style: theme.textTheme.h3),
              Text('Project ID: ${coordinator.clientSlug}',
                  style: theme.textTheme.muted),
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
        final activeRoute = coordinator.root.activeRoute;
        final isOverview = activeRoute is OverviewRoute;
        final isTokens = _isTokensActive(coordinator);
        final isSettings = activeRoute is SettingsRoute;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _TabButton(
                  label: 'Overview',
                  isActive: isOverview,
                  onPressed: () => coordinator.push(OverviewRoute(slug))),
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

  bool _isTokensActive(ManageCoordinator coordinator) {
    final apiRoute = coordinator.apiStack.activeRoute;
    return apiRoute is TokensRoute;
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
