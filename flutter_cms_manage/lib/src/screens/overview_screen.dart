import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/tokens_route.dart';

class OverviewScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const OverviewScreen({super.key, required this.coordinator});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    try {
      deploymentService.loadDeployments();
    } catch (_) {
      // client not ready yet
    }
  }

  ManageCoordinator get coordinator => widget.coordinator;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slugValue = currentClientSlug.watch(context);
    final clientState = currentClient.watch(context);
    final client = clientState.value;
    final slug = client?.slug ?? slugValue;

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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _DocumentStatCard()),
                const SizedBox(width: 16),
                Expanded(child: _MemberStatCard()),
                const SizedBox(width: 16),
                Expanded(child: _DeploymentStatCard()),
              ],
            ),
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
                      launchUrl(Uri.parse('https://$slug.dartdesk.dev'));
                    },
                    child: Text('Open Studio ($slug.dartdesk.dev)'),
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

// ---------------------------------------------------------------------------
// Document stat card
// ---------------------------------------------------------------------------

class _DocumentStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final count = documentCount.watch(context);
    final value = count.value?.toString() ?? '\u2014';

    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents',
                style: theme.textTheme.muted
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Icon(LucideIcons.fileText,
                  size: 16, color: theme.colorScheme.mutedForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.h3),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Member stat card
// ---------------------------------------------------------------------------

class _MemberStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final count = memberCount.watch(context);
    final value = count.value?.toString() ?? '\u2014';

    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Members',
                style: theme.textTheme.muted
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Icon(LucideIcons.users,
                  size: 16, color: theme.colorScheme.mutedForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.h3),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deployment stat card
// ---------------------------------------------------------------------------

class _DeploymentStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    CmsDeployment? active;
    try {
      final service = deploymentService;
      service.deployments.watch(context);
      active = service.activeDeployment;
    } catch (_) {
      // client not ready
    }

    final version = active != null ? 'v${active.version}' : '\u2014';
    final subtitle = active?.createdAt != null
        ? DateFormat('MMM d, yyyy').format(active!.createdAt!)
        : 'No active deployment';

    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deployments',
                style: theme.textTheme.muted
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Icon(LucideIcons.rocket, size: 16,
                  color: theme.colorScheme.mutedForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(version, style: theme.textTheme.h3),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
