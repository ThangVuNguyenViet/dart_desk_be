import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final apiUrl =
      serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  // Create client with new IDP auth session manager
  client = Client(apiUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Initialize auth and Google sign-in
  await client.auth.initialize();
  await client.auth.initializeGoogleSignIn();

  serverUrl = serverUrlFromEnv.isEmpty
      ? 'http://$localhost:8082'
      : serverUrlFromEnv.replaceAll(':8080', ':8082');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FlutterCmsAuth(
        client: client,
        title: 'Welcome to Flutter CMS',
        subtitle: 'Sign in to manage your content',
        child: const MyHomePage(title: 'Flutter CMS'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  UserProfileModel? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
          await client.modules.serverpod_auth_core.userProfileInfo.get();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _profile?.fullName ?? _profile?.userName ?? _profile?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),
              if (_loadingProfile)
                const CircularProgressIndicator()
              else
                Text(
                  'Welcome, $displayName!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              if (_profile?.email != null) ...[
                const SizedBox(height: 8),
                Text(
                  _profile!.email!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'You are successfully authenticated with Google!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Server is running and ready to accept requests.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
