import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

late final Client client;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  client.auth.initialize();

  runApp(
    MaterialApp(
      title: 'CMS Admin',
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(
        client: client,
        title: 'CMS Admin Dashboard',
        loginTitle: 'CMS Admin',
        loginSubtitle: 'Sign in with your admin account',
        sidebarItemCustomizations: const {
          'cms_clients': SidebarItemCustomization(
            label: 'Clients',
            icon: Icons.business,
          ),
          'cms_documents': SidebarItemCustomization(
            label: 'Documents',
            icon: Icons.article,
          ),
          'cms_document_datas': SidebarItemCustomization(
            label: 'Document Data',
            icon: Icons.data_object,
          ),
          'cms_users': SidebarItemCustomization(
            label: 'Users',
            icon: Icons.people,
          ),
          'document_versions': SidebarItemCustomization(
            label: 'Versions',
            icon: Icons.history,
          ),
          'media_files': SidebarItemCustomization(
            label: 'Media',
            icon: Icons.perm_media,
          ),
          'document_crdt_operations': SidebarItemCustomization(
            label: 'CRDT Ops',
            icon: Icons.sync,
          ),
          'document_crdt_snapshots': SidebarItemCustomization(
            label: 'CRDT Snapshots',
            icon: Icons.camera,
          ),
        },
      ),
    ),
  );
}
