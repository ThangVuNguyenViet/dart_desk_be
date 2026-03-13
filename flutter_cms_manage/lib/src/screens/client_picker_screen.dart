import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';

class ClientPickerScreen extends StatelessWidget {
  final ManageCoordinator coordinator;

  const ClientPickerScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final clients = userClients.watch(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flutter CMS',
                    style: theme.textTheme.h2
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Select a project', style: theme.textTheme.muted),
                const SizedBox(height: 24),
                ...clients.map((client) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () =>
                            coordinator.replace(OverviewRoute(client.slug)),
                        child: ShadCard(
                          child: Row(
                            children: [
                              ShadAvatar(
                                '',
                                size: const Size(40, 40),
                                placeholder: Text(
                                  client.name.isNotEmpty
                                      ? client.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(client.name,
                                        style: theme.textTheme.large),
                                    Text(client.slug,
                                        style: theme.textTheme.muted),
                                  ],
                                ),
                              ),
                              Icon(LucideIcons.chevronRight,
                                  color: theme.colorScheme.mutedForeground),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
