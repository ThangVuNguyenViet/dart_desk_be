import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';

class SetupWizardScreen extends StatefulWidget {
  final ManageCoordinator coordinator;

  const SetupWizardScreen({super.key, required this.coordinator});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _createProject() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final slug = _generateSlug(name);

    if (slug.length < 3) {
      setState(() => _error = 'Project name is too short to generate a valid slug.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = await serverpodClient.cmsClient.createClientWithOwner(
        name: name,
        slug: slug,
      );

      // Reload clients from server and update state
      userClients.reload();
      await userClients.future;
      authState.value = AuthState.ready;

      if (mounted) {
        widget.coordinator.replace(OverviewRoute(client.slug));
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        if (message.contains('already taken')) {
          setState(() => _error = 'Slug "$slug" is already taken. Try a different name.');
        } else if (message.contains('reserved')) {
          setState(() => _error = 'This name uses a reserved word. Try a different name.');
        } else {
          setState(() => _error = 'Failed to create project. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ShadCard(
          width: 460,
          title: const Text('Welcome! Create your project',
              style: TextStyle(fontSize: 20)),
          description: const Text(
            'Give your CMS project a name. You can configure everything else later.',
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ShadForm(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    ShadAlert.destructive(title: Text(_error!)),
                    const SizedBox(height: 16),
                  ],
                  ShadInputFormField(
                    id: 'name',
                    label: const Text('Project Name'),
                    controller: _nameController,
                    placeholder: const Text('My Awesome Project'),
                    validator: (value) {
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_nameController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Slug: ${_generateSlug(_nameController.text)}',
                      style: theme.textTheme.muted,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ShadButton(
                    width: double.infinity,
                    enabled: !_isLoading,
                    onPressed: _createProject,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
