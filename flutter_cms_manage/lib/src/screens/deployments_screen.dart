import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';

class DeploymentsScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const DeploymentsScreen({super.key, required this.coordinator});

  @override
  State<DeploymentsScreen> createState() => _DeploymentsScreenState();
}

class _DeploymentsScreenState extends State<DeploymentsScreen> {
  @override
  void initState() {
    super.initState();
    deploymentService.loadDeployments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slug = currentClientSlug.watch(context);
    final service = deploymentService;
    final loading = service.isLoading.watch(context);
    final deployments = service.deployments.watch(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Deployments', style: theme.textTheme.h3),
              const Spacer(),
              if (service.activeDeployment != null)
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.externalLink, size: 14),
                      const SizedBox(width: 8),
                      const Text('Open Live Site'),
                    ],
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse('https://$slug.dartdesk.dev'));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (deployments.isEmpty)
            Expanded(child: _EmptyState())
          else
            Expanded(
              child: _DeploymentsTable(
                deployments: deployments,
                onActivate: (version) => service.activateVersion(version),
                onDelete: (version) => service.deleteVersion(version),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.cloudUpload, size: 48,
                  color: theme.colorScheme.mutedForeground),
              const SizedBox(height: 16),
              Text('No deployments yet', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              Text(
                'Install the CLI and deploy your first studio:',
                style: theme.textTheme.muted,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  'dart pub global activate flutter_cms_cli\nflutter_cms deploy',
                  style: theme.textTheme.small
                      .copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeploymentsTable extends StatelessWidget {
  final List<CmsDeployment> deployments;
  final ValueChanged<int> onActivate;
  final ValueChanged<int> onDelete;

  const _DeploymentsTable({
    required this.deployments,
    required this.onActivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadTable.list(
      columnSpanExtent: (index) => switch (index) {
        0 => const FixedTableSpanExtent(100), // Version
        1 => const FixedTableSpanExtent(120), // Status
        2 => const FixedTableSpanExtent(100), // Size
        3 => const FixedTableSpanExtent(200), // Deployed
        4 => const RemainingTableSpanExtent(), // Actions
        _ => const RemainingTableSpanExtent(),
      },
      header: [
        for (final h in ['Version', 'Status', 'Size', 'Deployed', 'Actions'])
          ShadTableCell.header(
            child: Text(h,
                style: theme.textTheme.muted
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
      ],
      children: [
        for (final d in deployments)
          [
            ShadTableCell(
              child: Text('v${d.version}',
                  style: theme.textTheme.small.copyWith(
                      fontWeight: d.status == DeploymentStatus.active
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ),
            ShadTableCell(
              child: d.status == DeploymentStatus.active
                  ? ShadBadge(child: Text(d.status.name))
                  : ShadBadge.secondary(child: Text(d.status.name)),
            ),
            ShadTableCell(
              child:
                  Text(d.fileSize != null ? _formatBytes(d.fileSize!) : '-'),
            ),
            ShadTableCell(
              child: Text(
                d.createdAt != null
                    ? DateFormat('MMM d, yyyy HH:mm').format(d.createdAt!)
                    : '-',
              ),
            ),
            ShadTableCell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (d.status != DeploymentStatus.active &&
                      d.status != DeploymentStatus.uploading) ...[
                    ShadButton.ghost(
                      size: ShadButtonSize.sm,
                      child: const Text('Activate'),
                      onPressed: () => onActivate(d.version),
                    ),
                    ShadButton.ghost(
                      key: ValueKey('delete_deployment_${d.version}'),
                      size: ShadButtonSize.sm,
                      child: Icon(LucideIcons.trash2,
                          size: 14, color: theme.colorScheme.destructive),
                      onPressed: () => onDelete(d.version),
                    ),
                  ],
                  if (d.status == DeploymentStatus.active)
                    Text('Current', style: theme.textTheme.muted),
                ],
              ),
            ),
          ],
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
