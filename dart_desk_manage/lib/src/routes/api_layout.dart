import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'manage_coordinator.dart';

class ApiLayout extends ManageRoute with RouteLayout<ManageRoute> {
  @override
  Type get layout => ManageLayout;

  @override
  NavigationPath<ManageRoute> resolvePath(ManageCoordinator coordinator) =>
      coordinator.apiStack;

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return ApiShell(
      coordinator: coordinator,
      child: super.build(coordinator, context),
    );
  }
}

class ApiShell extends StatelessWidget {
  final ManageCoordinator coordinator;
  final Widget child;

  const ApiShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        Container(
          width: 180,
          decoration: BoxDecoration(
            border:
                Border(right: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SidebarItem(
                    icon: LucideIcons.key, label: 'Tokens', isActive: true),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem(
      {required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: isActive
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isActive
                      ? theme.colorScheme.foreground
                      : theme.colorScheme.mutedForeground,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
