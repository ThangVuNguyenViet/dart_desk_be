import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import 'create_token_dialog.dart';
import 'token_reveal_dialog.dart';

class TokensScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const TokensScreen({super.key, required this.coordinator});

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      await tokenService.loadTokens();
    } catch (_) {
      // tokenService getter throws if no client selected; ignore on init
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final clientState = currentClient.watch(context);
    if (clientState.value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tokenList = tokenService.tokens.watch(context);
    final loading = tokenService.isLoading.watch(context);
    final errorMsg = tokenService.error.watch(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API Tokens', style: theme.textTheme.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Manage API tokens for authenticating requests to your project.',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              ShadButton(
                leading: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(LucideIcons.plus, size: 16),
                ),
                onPressed: _showCreateDialog,
                child: const Text('Add API Token'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Error banner
          if (errorMsg != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.circleAlert, size: 16,
                      color: Colors.red.shade300),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(errorMsg,
                        style: TextStyle(color: Colors.red.shade300)),
                  ),
                ],
              ),
            ),

          // Content
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (tokenList.isEmpty)
            _EmptyState(onCreateToken: _showCreateDialog)
          else
            _TokenTable(
              tokens: tokenList,
              onToggleActive: _toggleActive,
              onRegenerate: _regenerateToken,
              onDelete: _deleteToken,
            ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showShadDialog(
      context: context,
      builder: (context) => CreateTokenDialog(
        onCreateToken: (name, role, expiresAt) async {
          final result = await tokenService.createToken(
            name: name,
            role: role,
            expiresAt: expiresAt,
          );
          if (result != null && mounted) {
            _showTokenRevealDialog(result.token.name, result.plaintextToken);
          }
        },
      ),
    );
  }

  void _showTokenRevealDialog(String name, String token) {
    showShadDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TokenRevealDialog(
        tokenName: name,
        tokenValue: token,
      ),
    );
  }

  Future<void> _toggleActive(CmsApiToken token) async {
    await tokenService.updateToken(
      tokenId: token.id!,
      isActive: !token.isActive,
    );
  }

  Future<void> _regenerateToken(CmsApiToken token) async {
    final confirmed = await _showConfirmDialog(
      title: 'Regenerate Token',
      description:
          'This will invalidate the current token "${token.name}" and generate a new one. '
          'Any applications using the old token will stop working.',
    );
    if (confirmed && mounted) {
      final result = await tokenService.regenerateToken(token.id!);
      if (result != null && mounted) {
        _showTokenRevealDialog(result.token.name, result.plaintextToken);
      }
    }
  }

  Future<void> _deleteToken(CmsApiToken token) async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Token',
      description:
          'Are you sure you want to delete "${token.name}"? '
          'This action cannot be undone.',
    );
    if (confirmed) {
      await tokenService.deleteToken(token.id!);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String description,
  }) async {
    final result = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text(title),
        description: Text(description),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateToken;
  const _EmptyState({required this.onCreateToken});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.keyRound, size: 48,
                color: theme.colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text('No API Tokens', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text(
              'Create your first API token to start making authenticated requests.',
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShadButton(
              leading: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(LucideIcons.plus, size: 16),
              ),
              onPressed: onCreateToken,
              child: const Text('Add API Token'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Token table
// ---------------------------------------------------------------------------

class _TokenTable extends StatelessWidget {
  final List<CmsApiToken> tokens;
  final ValueChanged<CmsApiToken> onToggleActive;
  final ValueChanged<CmsApiToken> onRegenerate;
  final ValueChanged<CmsApiToken> onDelete;

  const _TokenTable({
    required this.tokens,
    required this.onToggleActive,
    required this.onRegenerate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Name',
                      style: theme.textTheme.small
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Role',
                      style: theme.textTheme.small
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Token',
                      style: theme.textTheme.small
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Created',
                      style: theme.textTheme.small
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Status',
                      style: theme.textTheme.small
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table rows
          ...tokens.map((token) {
            final isLast = token == tokens.last;
            return Column(
              children: [
                _TokenRow(
                  token: token,
                  dateFormat: dateFormat,
                  onToggleActive: () => onToggleActive(token),
                  onRegenerate: () => onRegenerate(token),
                  onDelete: () => onDelete(token),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final CmsApiToken token;
  final DateFormat dateFormat;
  final VoidCallback onToggleActive;
  final VoidCallback onRegenerate;
  final VoidCallback onDelete;

  const _TokenRow({
    required this.token,
    required this.dateFormat,
    required this.onToggleActive,
    required this.onRegenerate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(LucideIcons.key, size: 14,
                    color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    token.name,
                    style: theme.textTheme.small
                        .copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Role
          Expanded(
            flex: 2,
            child: _RoleBadge(role: token.role),
          ),
          // Token prefix
          Expanded(
            flex: 2,
            child: Text(
              '${token.tokenPrefix}...${token.tokenSuffix}',
              style: theme.textTheme.muted.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          // Created
          Expanded(
            flex: 2,
            child: Text(
              token.createdAt != null
                  ? dateFormat.format(token.createdAt!)
                  : '-',
              style: theme.textTheme.muted,
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: _StatusBadge(isActive: token.isActive),
          ),
          // Actions
          SizedBox(
            width: 48,
            child: _ActionsMenu(
              onToggleActive: onToggleActive,
              onRegenerate: onRegenerate,
              onDelete: onDelete,
              isActive: token.isActive,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      'admin' => (Colors.orange, 'Admin'),
      'editor' => (Colors.green, 'Editor'),
      _ => (Colors.blue, 'Viewer'),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: ShadBadge.outline(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: isActive
          ? ShadBadge(
              backgroundColor: Colors.green.withValues(alpha: 0.15),
              foregroundColor: Colors.green,
              child: const Text('Active', style: TextStyle(fontSize: 12)),
            )
          : ShadBadge.secondary(
              child: const Text('Inactive', style: TextStyle(fontSize: 12)),
            ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final VoidCallback onToggleActive;
  final VoidCallback onRegenerate;
  final VoidCallback onDelete;
  final bool isActive;

  const _ActionsMenu({
    required this.onToggleActive,
    required this.onRegenerate,
    required this.onDelete,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.ellipsisVertical, size: 16),
      tooltip: 'Actions',
      onSelected: (value) {
        switch (value) {
          case 'toggle':
            onToggleActive();
          case 'regenerate':
            onRegenerate();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isActive ? LucideIcons.pause : LucideIcons.play,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(isActive ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'regenerate',
          child: Row(
            children: [
              Icon(LucideIcons.refreshCw, size: 14),
              const SizedBox(width: 8),
              const Text('Regenerate'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 14, color: Colors.red.shade300),
              const SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(color: Colors.red.shade300)),
            ],
          ),
        ),
      ],
    );
  }
}
