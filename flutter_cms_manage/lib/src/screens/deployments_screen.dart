import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

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
    final service = deploymentService;
    final loading = service.isLoading.watch(context);
    final deployments = service.deployments.watch(context);

    return SingleChildScrollView(
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
                  onPressed: () {},
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (deployments.isEmpty)
            _EmptyState()
          else
            _DeploymentsTable(
              deployments: deployments,
              onActivate: (version) => service.activateVersion(version),
              onDelete: (version) => service.deleteVersion(version),
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
    return ShadTable(
      columnCount: 6,
      rowCount: deployments.length + 1,
      header: (context, column) {
        return ShadTableCell.header(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              ['Version', 'Status', 'Size', 'Commit', 'Deployed', 'Actions'][
                  column],
              style: theme.textTheme.muted
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
      builder: (context, index) {
        final d = deployments[index.row];
        final isActive = d.status == DeploymentStatus.active;

        return ShadTableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: switch (index.column) {
              0 => Text('v${d.version}',
                  style: theme.textTheme.small.copyWith(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal)),
              1 => isActive
                  ? ShadBadge(child: Text(d.status.name))
                  : ShadBadge.secondary(child: Text(d.status.name)),
              2 => Text(
                  d.fileSize != null ? _formatBytes(d.fileSize!) : '-'),
              3 => Text(
                  d.commitHash?.substring(0, 7) ?? '-',
                  style: theme.textTheme.small
                      .copyWith(fontFamily: 'monospace'),
                ),
              4 => Text(
                  d.createdAt != null
                      ? DateFormat('MMM d, yyyy HH:mm').format(d.createdAt!)
                      : '-',
                ),
              5 => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isActive &&
                        d.status != DeploymentStatus.uploading) ...[
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        child: const Text('Activate'),
                        onPressed: () => onActivate(d.version),
                      ),
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        child: Icon(LucideIcons.trash2,
                            size: 14,
                            color: theme.colorScheme.destructive),
                        onPressed: () => onDelete(d.version),
                      ),
                    ],
                    if (isActive)
                      Text('Current', style: theme.textTheme.muted),
                  ],
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
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
