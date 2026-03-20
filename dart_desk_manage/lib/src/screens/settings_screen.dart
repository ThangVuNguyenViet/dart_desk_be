import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../routes/manage_coordinator.dart';

class SettingsScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const SettingsScreen({super.key, required this.coordinator});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'My Project');
    _descriptionController = TextEditingController(
      text: 'A content management project.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Settings', style: theme.textTheme.h3),
          const SizedBox(height: 4),
          Text(
            'Manage your project configuration and preferences.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),

          // General settings card
          ShadCard(
            title: const Text('General'),
            description: const Text(
              'Basic information about your project.',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadInputFormField(
                      id: 'name',
                      controller: _nameController,
                      label: const Text('Project Name'),
                      placeholder: const Text('e.g. My CMS Project'),
                      validator: (value) {
                        if (value.isEmpty) return 'Project name is required.';
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'description',
                      controller: _descriptionController,
                      label: const Text('Description'),
                      placeholder: const Text(
                        'A short description of your project',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'slug',
                      label: const Text('Slug'),
                      initialValue: widget.coordinator.clientSlug,
                      readOnly: true,
                      enabled: false,
                      description: const Text(
                        'The project slug is used in URLs and cannot be changed.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Active status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Status',
                                style: theme.textTheme.small.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isActive
                                    ? 'Project is active and accessible.'
                                    : 'Project is deactivated. APIs will return errors.',
                                style: theme.textTheme.muted,
                              ),
                            ],
                          ),
                        ),
                        ShadSwitch(
                          value: _isActive,
                          onChanged: (value) {
                            if (!value) {
                              _showDeactivateConfirmDialog();
                            } else {
                              setState(() => _isActive = true);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ShadButton(
                      enabled: !_saving,
                      onPressed: _saveSettings,
                      leading: _saving
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                      child: Text(_saving ? 'Saving...' : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Danger zone card
          ShadCard(
            title: Row(
              children: [
                Icon(
                  LucideIcons.triangleAlert,
                  size: 18,
                  color: Colors.red.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: theme.textTheme.h4.copyWith(
                    color: Colors.red.shade300,
                  ),
                ),
              ],
            ),
            description: const Text(
              'Irreversible actions that affect your entire project.',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Project',
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Permanently delete this project, all its documents, '
                            'media files, and API tokens. This cannot be undone.',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShadButton.destructive(
                      leading: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(LucideIcons.trash2, size: 16),
                      ),
                      onPressed: _showDeleteConfirmDialog,
                      child: const Text('Delete Project'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _saving = true);

    // TODO: Integrate with backend API to persist settings
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _saving = false);
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Settings saved'),
          description: Text('Your project settings have been updated.'),
        ),
      );
    }
  }

  Future<void> _showDeactivateConfirmDialog() async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Deactivate Project'),
        description: const Text(
          'Are you sure you want to deactivate this project? '
          'All API requests will be rejected until reactivated.',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Deactivate'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _isActive = false);
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Delete Project'),
        description: const Text(
          'This action is permanent and cannot be undone. '
          'All documents, media files, and API tokens will be lost.\n\n'
          'Are you sure you want to delete this project?',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Delete Project'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // TODO: Integrate with backend API to delete project
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Project deleted'),
          description: Text('The project has been permanently removed.'),
        ),
      );
    }
  }
}
