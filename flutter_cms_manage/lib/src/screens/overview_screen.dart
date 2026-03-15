import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../routes/manage_coordinator.dart';
import '../routes/tokens_route.dart';

class OverviewScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const OverviewScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slug = coordinator.clientSlug;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text('Project Overview', style: theme.textTheme.h3),
          const SizedBox(height: 4),
          Text(
            'View project details and quick stats at a glance.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),

          // Quick stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.keyRound,
                  label: 'API Tokens',
                  value: '\u2014',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.fileText,
                  label: 'Documents',
                  value: '\u2014',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: LucideIcons.users,
                  label: 'Team Members',
                  value: '\u2014',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Project details card
          ShadCard(
            title: const Text('Project Details'),
            description:
                const Text('Configuration and identifiers for this project.'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Slug',
                    value: slug,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Project ID',
                    value: slug,
                    copyable: true,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Status',
                    child: ShadBadge(
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      foregroundColor: Colors.green,
                      child:
                          const Text('Active', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick links
          ShadCard(
            title: const Text('Quick Links'),
            description:
                const Text('Jump to commonly used sections of your project.'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ShadButton.outline(
                    leading: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(LucideIcons.externalLink, size: 16),
                    ),
                    onPressed: () {
                      // TODO: Open Studio URL
                    },
                    child: const Text('Open Studio'),
                  ),
                  ShadButton.outline(
                    leading: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(LucideIcons.keyRound, size: 16),
                    ),
                    onPressed: () {
                      coordinator
                          .pushOrMoveToTop(TokensRoute(slug));
                    },
                    child: const Text('Manage API Tokens'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.muted
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 16, color: theme.colorScheme.mutedForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.h3,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool copyable;
  final Widget? child;

  const _DetailRow({
    required this.label,
    this.value,
    this.copyable = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.muted
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        if (child != null)
          child!
        else ...[
          Text(
            value ?? '',
            style: theme.textTheme.small.copyWith(
              fontFamily: copyable ? 'monospace' : null,
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value ?? ''));
                ShadToaster.of(context).show(
                  const ShadToast(
                    title: Text('Copied to clipboard'),
                  ),
                );
              },
              child: Icon(LucideIcons.copy, size: 14),
            ),
          ],
        ],
      ],
    );
  }
}
