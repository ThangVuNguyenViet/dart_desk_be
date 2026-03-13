import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A dialog for creating a new API token.
///
/// Provides a form with token name, role selector (viewer/editor/admin),
/// and calls [onCreateToken] with the selected values.
class CreateTokenDialog extends StatefulWidget {
  final void Function(String name, String role, DateTime? expiresAt)
      onCreateToken;

  const CreateTokenDialog({super.key, required this.onCreateToken});

  @override
  State<CreateTokenDialog> createState() => _CreateTokenDialogState();
}

class _CreateTokenDialogState extends State<CreateTokenDialog> {
  final _formKey = GlobalKey<ShadFormState>();
  final _nameController = TextEditingController();
  String _selectedRole = 'viewer';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadDialog(
      constraints: const BoxConstraints(maxWidth: 480),
      title: const Text('Create API Token'),
      description: const Text(
        'Create a new token to authenticate API requests.',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              widget.onCreateToken(
                _nameController.text.trim(),
                _selectedRole,
                null,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create Token'),
        ),
      ],
      child: ShadForm(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ShadInputFormField(
              id: 'name',
              controller: _nameController,
              label: const Text('Token Name'),
              placeholder: const Text('e.g. Production API Key'),
              validator: (value) {
                if (value.isEmpty) return 'Token name is required.';
                if (value.length < 3) {
                  return 'Name must be at least 3 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Role', style: theme.textTheme.small),
            const SizedBox(height: 8),
            _RoleSelector(
              selectedRole: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleCard(
          role: 'viewer',
          label: 'Viewer',
          description: 'Read-only access',
          color: Colors.blue,
          isSelected: selectedRole == 'viewer',
          onTap: () => onChanged('viewer'),
        ),
        const SizedBox(width: 8),
        _RoleCard(
          role: 'editor',
          label: 'Editor',
          description: 'Read & write',
          color: Colors.green,
          isSelected: selectedRole == 'editor',
          onTap: () => onChanged('editor'),
        ),
        const SizedBox(width: 8),
        _RoleCard(
          role: 'admin',
          label: 'Admin',
          description: 'Full access',
          color: Colors.orange,
          isSelected: selectedRole == 'admin',
          onTap: () => onChanged('admin'),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final String label;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.label,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.border,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
