# Serverpod Authentication Reference

**Last Updated:** 2025-11-29 (Serverpod 2.9.2)
**Official Documentation:** https://docs.serverpod.dev/concepts/authentication/

## Overview

Serverpod provides the `serverpod_auth` module with built-in user management supporting email/password authentication and social sign-ins (Google, Apple, Firebase). The system automatically handles token management, request authentication, and user session persistence.

## Table of Contents

1. [Setup & Installation](#setup--installation)
2. [Google Sign-In](#google-sign-in)
3. [Authentication Basics](#authentication-basics)
4. [Working with Users](#working-with-users)
5. [Client-Side Integration](#client-side-integration)
6. [Session Management](#session-management)
7. [Custom Authentication Overrides](#custom-authentication-overrides)
8. [Security & Best Practices](#security--best-practices)

---

## Setup & Installation

### Server Setup

#### 1. Install Dependencies

Add to your server's `pubspec.yaml`:
```bash
dart pub add serverpod_auth_server
```

#### 2. Configure Server

Import and register the authentication handler in your main server file:

```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

void run(List<String> args) async {
  var pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,  // Add this line
  );

  await pod.start();
}
```

#### 3. Database Migration

Create and apply migrations for authentication tables:

```bash
serverpod create-migration
docker compose up --build --detach
dart run bin/main.dart --role maintenance --apply-migrations
```

This creates the necessary authentication tables including:
- `serverpod_user_info` - User account information
- `serverpod_auth_key` - Authentication keys/tokens
- `serverpod_email_auth` - Email/password credentials
- `serverpod_user_image` - User profile images
- Provider-specific tables for OAuth data

#### 4. Authentication Configuration

Customize authentication behavior using `AuthConfig`:

```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

void run(List<String> args) async {
  // Configure authentication settings
  auth.AuthConfig.set(auth.AuthConfig(
    minPasswordLength: 12,
    maxPasswordLength: 128,
    maxAllowedEmailSignInAttempts: 5,
    emailSignInFailureResetTime: Duration(minutes: 5),
    enableUserImages: true,
    userCanEditUserName: true,
    passwordResetExpirationTime: Duration(hours: 24),

    // Lifecycle callbacks
    onUserCreated: (session, userInfo) async {
      print('New user created: ${userInfo.userName}');
      // Custom logic when user is created
    },
    onUserUpdated: (session, userInfo, oldUserInfo) async {
      print('User updated: ${userInfo.userName}');
      // Custom logic when user is updated
    },
  ));

  var pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  await pod.start();
}
```

**Key Configuration Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `minPasswordLength` | Minimum password length | 8 |
| `maxPasswordLength` | Maximum password length | 128 |
| `maxAllowedEmailSignInAttempts` | Failed login attempts before lockout | 5 |
| `emailSignInFailureResetTime` | Time window for failed attempts | 5 minutes |
| `enableUserImages` | Allow profile picture uploads | true |
| `userCanEditUserName` | Allow username changes | true |
| `passwordResetExpirationTime` | Password reset code validity | 24 hours |
| `onUserCreated` | Callback when user is created | null |
| `onUserUpdated` | Callback when user is updated | null |

#### 5. Configuration File (Optional)

You can also configure authentication in your `config/development.yaml`:

```yaml
modules:
  serverpod_auth:
    sendValidationEmail: false    # Set to true in production
    extraSaltyHash: true          # Additional password hashing
    minPasswordLength: 8
```

---

## Google Sign-In

Serverpod provides built-in support for Google Sign-In authentication across iOS, Android, and Web platforms.

### Prerequisites

1. **Install authentication module** (already covered in Setup & Installation)
2. **Google Cloud Project** with OAuth 2.0 credentials configured

### Google Cloud Platform Setup

#### 1. Enable Google People API

1. Navigate to [Google Cloud Console](https://console.cloud.google.com/)
2. Go to **APIs & Services > Library**
3. Search for "Google People API"
4. Click **Enable**

#### 2. Configure OAuth Consent Screen

1. Go to **APIs & Services > OAuth consent screen**
2. Choose **External** user type (unless using Google Workspace)
3. Fill in required information:
   - App name
   - User support email
   - Developer contact email
4. Add required scopes:
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
   - `openid` (automatically included)
5. Add test user emails for development/testing
6. Save and continue

#### 3. Create OAuth 2.0 Credentials

Create credentials for each platform you're targeting:

**Web Application (Required for Server):**

1. Click **Create Credentials > OAuth client ID**
2. Select **Web application**
3. Add authorized JavaScript origins:
   - Development: `http://localhost:8082`
   - Production: `https://your-domain.com`
4. Add authorized redirect URIs:
   - Development: `http://localhost:8082/googlesignin`
   - Production: `https://your-domain.com/googlesignin`
5. Download JSON credentials file
6. **IMPORTANT**: Note the Client ID (you'll need this for the Flutter app)

**Android (Optional):**

1. Create **Android** OAuth client
2. Provide your app's package name
3. Get SHA-1 fingerprint:
   ```bash
   # Debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # Production keystore
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
   ```
4. Create the credential

**iOS (Optional):**

1. Create **iOS** OAuth client
2. Provide your iOS bundle ID
3. Create the credential
4. Download the `plist` file

### Server-Side Configuration

#### 1. Store Google Credentials Securely

**Option A: Using JSON file (Development):**

1. Rename downloaded JSON to `google_client_secret.json`
2. Place in `flutter_cms_be_server/config/` directory
3. Add to `.gitignore`:
   ```bash
   # .gitignore
   config/google_client_secret.json
   ```

**Option B: Using passwords.yaml (Recommended):**

Store the client secret in `config/passwords.yaml`:

```yaml
# config/passwords.yaml
development:
  googleClientSecret: 'GOCSPX-your-client-secret-here'

production:
  googleClientSecret: 'GOCSPX-your-production-secret'
```

The `google_client_secret.json` file contains a private key and **must never be committed to version control**.

#### 2. Register Google Sign-In Route

Add the Google Sign-In route in your server's `lib/server.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

void run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  // Register Google Sign-In route (REQUIRED for web authentication)
  pod.webServer.addRoute(auth.RouteGoogleSignIn(), '/googlesignin');

  await pod.start();
}
```

This route handles the OAuth callback from Google.

### Client-Side Configuration

#### 1. Install Required Packages

Add to your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  serverpod_auth_google_flutter: ^2.9.2
  serverpod_auth_shared_flutter: ^2.9.2
```

Run:
```bash
flutter pub add serverpod_auth_google_flutter
```

#### 2. Platform-Specific Setup

**iOS Setup:**

1. If you created iOS credentials, download `GoogleService-Info.plist`
2. Drag into your Xcode project (Runner target)
3. Add the server's client ID to the plist:
   ```xml
   <key>SERVER_CLIENT_ID</key>
   <string>YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
   ```
4. Register URL scheme in `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

**Android Setup:**

1. Download `google-services.json` (if you created Android credentials)
2. Place in `android/app/` directory
3. The SHA-1 fingerprint links your app to the OAuth credentials

**Web Setup:**

1. No additional configuration needed
2. The web client ID from server credentials is used
3. Ensure your domain is in authorized JavaScript origins

#### 3. Implement Google Sign-In Button

Use the `SignInWithGoogleButton` widget provided by Serverpod:

```dart
import 'package:flutter/material.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:your_project_client/your_project_client.dart';

class LoginPage extends StatelessWidget {
  final Client client;
  final SessionManager sessionManager;

  const LoginPage({
    required this.client,
    required this.sessionManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign In', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 32),

            // Google Sign-In Button
            SignInWithGoogleButton(
              caller: client.modules.auth,
              serverClientId: '491670473884-xxx.apps.googleusercontent.com',
              redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**SignInWithGoogleButton Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `caller` | `Caller` | Yes | Auth module caller from client |
| `serverClientId` | `String` | Yes | Web client ID from Google Cloud Console |
| `redirectUri` | `Uri` | Yes | OAuth redirect URI (matches server route) |
| `clientId` | `String` | No | Optional custom client ID for specific platforms |
| `additionalScopes` | `List<String>` | No | Additional Google API scopes to request |

#### 4. Handle Authentication State

The button automatically handles the sign-in flow. Listen to `SessionManager` for state changes:

```dart
class MyApp extends StatefulWidget {
  final SessionManager sessionManager;

  const MyApp({required this.sessionManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen for authentication changes
    widget.sessionManager.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget.sessionManager.isSignedIn
        ? HomePage(sessionManager: widget.sessionManager)
        : LoginPage(
            client: client,
            sessionManager: widget.sessionManager,
          ),
    );
  }
}
```

### Full Example: Complete Authentication Flow

```dart
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Serverpod client
  final client = Client(
    'http://localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  );

  // Initialize session manager
  final sessionManager = SessionManager(
    caller: client.modules.auth,
  );
  await sessionManager.initialize();

  runApp(MyApp(
    client: client,
    sessionManager: sessionManager,
  ));
}

class MyApp extends StatefulWidget {
  final Client client;
  final SessionManager sessionManager;

  const MyApp({
    required this.client,
    required this.sessionManager,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.sessionManager.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CMS',
      home: widget.sessionManager.isSignedIn
        ? HomePage(sessionManager: widget.sessionManager)
        : LoginPage(
            client: widget.client,
            sessionManager: widget.sessionManager,
          ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Client client;
  final SessionManager sessionManager;

  const LoginPage({
    required this.client,
    required this.sessionManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(32),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome to Flutter CMS',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                Text('Please sign in to continue'),
                SizedBox(height: 32),

                SignInWithGoogleButton(
                  caller: client.modules.auth,
                  serverClientId: '491670473884-xxx.apps.googleusercontent.com',
                  redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final SessionManager sessionManager;

  const HomePage({required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    final user = sessionManager.signedInUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await sessionManager.signOutDevice();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularUserImage(
              userInfo: user,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome, ${user?.userName ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (user?.email != null) ...[
              SizedBox(height: 8),
              Text(user!.email!),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Accessing Additional Google APIs

If you need to access other Google APIs (YouTube, Drive, etc.) on behalf of users:

#### 1. Add Scopes to OAuth Consent Screen

In Google Cloud Console, add required scopes (e.g., `https://www.googleapis.com/auth/youtube.readonly`).

#### 2. Request Scopes in Flutter

```dart
SignInWithGoogleButton(
  caller: client.modules.auth,
  serverClientId: '491670473884-xxx.apps.googleusercontent.com',
  redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
  additionalScopes: [
    'https://www.googleapis.com/auth/youtube.readonly',
  ],
)
```

#### 3. Use on Server-Side

```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import 'package:googleapis/youtube/v3.dart';

class YouTubeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<String>> getUserFavorites(Session session) async {
    final userId = await session.userId;

    // Get authenticated Google client
    final googleClient = await GoogleAuth.authClientForUser(
      session,
      userId!,
    );

    if (googleClient == null) {
      throw Exception('User not authenticated with Google');
    }

    // Use Google API
    final youTubeApi = YouTubeApi(googleClient);
    final favorites = await youTubeApi.playlistItems.list(
      ['snippet'],
      playlistId: 'LL', // Liked videos
    );

    return favorites.items?.map((item) => item.snippet?.title ?? '').toList() ?? [];
  }
}
```

### Troubleshooting

**Common Issues:**

1. **"redirect_uri_mismatch" error:**
   - Ensure redirect URI in Google Cloud Console exactly matches `http://localhost:8082/googlesignin`
   - Check that the route is registered in server.dart

2. **Button doesn't respond on mobile:**
   - Verify SHA-1 fingerprint is correct for Android
   - Check bundle ID matches for iOS
   - Ensure platform-specific credentials are created

3. **"unauthorized_client" error:**
   - Verify server client ID is correct
   - Check that google_client_secret.json is in the config directory
   - Ensure OAuth consent screen is properly configured

4. **Web authentication fails:**
   - Add your domain to authorized JavaScript origins
   - Check browser console for CORS errors
   - Verify redirect URI includes the domain

### Security Best Practices

1. **Never commit credentials to version control:**
   ```bash
   # .gitignore
   config/google_client_secret.json
   config/passwords.yaml
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

2. **Use different credentials for development and production**

3. **Store client secrets in passwords.yaml**, not in configuration files

4. **Validate redirect URIs** match exactly between client and server

5. **Use HTTPS in production** - never use HTTP for OAuth in production

---

### Client Setup

#### 1. Install Dependencies

Add to your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  serverpod_flutter: ^2.9.2
  serverpod_auth_shared_flutter: ^2.9.2
  your_project_client: ^1.0.0  # Your generated client package
```

For Dart-only apps (no Flutter):
```yaml
dependencies:
  serverpod_auth_client: ^2.9.2
```

#### 2. Initialize Client

Set up the client with authentication support during app startup:

```dart
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:your_project_client/your_project_client.dart';

// Create client with authentication key manager
var client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);

// Create session manager
var sessionManager = SessionManager(
  caller: client.modules.auth,
);

// Initialize session manager (restores previous session if available)
await sessionManager.initialize();
```

---

## Authentication Basics

### User Identification

The `Session` object provides access to authenticated user information in all endpoint methods.

#### Accessing User Information

```dart
class MyEndpoint extends Endpoint {
  Future<void> myMethod(Session session) async {
    // Get authentication info
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo != null) {
      // Access user identifier
      final userIdentifier = authenticationInfo.userIdentifier;

      // Convenience getter for user ID (converts to int)
      final userId = await session.userId;

      print('Authenticated user ID: $userId');
    }

    // Check if user is signed in
    if (session.isUserSignedIn) {
      print('User is authenticated');
    }
  }
}
```

**Session Properties:**

- `authenticated` - Returns `AuthenticationInfo` with user identifier
- `userId` - Convenience getter returning integer user ID
- `isUserSignedIn` - Boolean property checking authentication state

### Endpoint Security

#### Requiring Login

Make an entire endpoint require authentication by overriding `requireLogin`:

```dart
class MyEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  // All methods in this endpoint require authentication
  Future<String> secureMethod(Session session) async {
    // User is guaranteed to be authenticated here
    final userId = await session.userId;
    return 'Hello user $userId';
  }
}
```

#### Base Class for Authenticated Endpoints

Create a base class for all protected endpoints:

```dart
abstract class AuthenticatedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
}

// All endpoints extending this class require authentication
class UserProfileEndpoint extends AuthenticatedEndpoint {
  Future<UserInfo> getProfile(Session session) async {
    final userId = await session.userId;
    return await Users.findUserByUserId(session, userId!);
  }
}
```

### Authorization with Scopes

Implement role-based access control using scopes.

#### Defining Required Scopes

```dart
class AdminEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  // Only users with 'admin' scope can access this
  Future<void> adminAction(Session session) async {
    // Perform admin-only operations
  }
}
```

**Note:** Setting `requiredScopes` automatically requires login.

#### Managing User Scopes

```dart
// Grant admin scope to a user
await Users.updateUserScopes(
  session,
  userId: 123,
  scopes: {Scope.admin},
);

// Grant multiple scopes
await Users.updateUserScopes(
  session,
  userId: 456,
  scopes: {Scope.admin, Scope('moderator')},
);

// Remove all scopes
await Users.updateUserScopes(
  session,
  userId: 789,
  scopes: {},
);
```

#### Custom Scopes

Create custom scopes by extending the `Scope` class:

```dart
class CustomScopes {
  static const admin = Scope('admin');
  static const moderator = Scope('moderator');
  static const editor = Scope('editor');
  static const viewer = Scope('viewer');
}

// Use in endpoints
class ContentEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {CustomScopes.editor};
}
```

### Sign-In Methods (Server Side)

The `serverpod_auth` module provides built-in endpoints for authentication. These are typically called from the client, but you can also use them programmatically:

```dart
// Email authentication is handled by the auth module endpoints
// Access through: client.modules.auth (from client side)
```

### Sign-Out Methods

Serverpod provides two sign-out approaches:

#### Sign Out Single Device

```dart
await sessionManager.signOutDevice();
```

Removes authentication key for the current device only. Other devices remain signed in.

#### Sign Out All Devices

```dart
await sessionManager.signOutAllDevices();
```

Revokes all authentication keys for the user across all devices.

---

## Working with Users

### Accessing User Information

#### Get User ID

```dart
Future<void> myEndpoint(Session session) async {
  final userId = (await session.authenticated)?.userId;

  if (userId != null) {
    print('User ID: $userId');
  }
}
```

#### Get Complete User Info

```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

Future<void> myEndpoint(Session session) async {
  final userId = await session.userId;

  if (userId != null) {
    final userInfo = await Users.findUserByUserId(session, userId);

    if (userInfo != null) {
      print('Name: ${userInfo.userName}');
      print('Email: ${userInfo.email}');
      print('Created: ${userInfo.created}');
      print('Image URL: ${userInfo.imageUrl}');
      print('Scopes: ${userInfo.scopes}');
    }
  }
}
```

**UserInfo Properties:**

- `id` - User's unique ID
- `userIdentifier` - Unique identifier (usually same as ID)
- `userName` - User's display name
- `fullName` - User's full name
- `email` - User's email address
- `created` - Account creation timestamp
- `imageUrl` - Profile picture URL
- `scopes` - Set of user's permission scopes
- `blocked` - Whether user is blocked

### User Management Operations

#### Find User by Email

```dart
final userInfo = await Users.findUserByEmail(session, 'user@example.com');
```

#### Find User by Identifier

```dart
final userInfo = await Users.findUserByIdentifier(session, 'identifier');
```

#### Update User Information

```dart
// Update user name
userInfo.userName = 'New Name';
await Users.updateUserInfo(session, userInfo);

// Update scopes
await Users.updateUserScopes(
  session,
  userId: userInfo.id!,
  scopes: {Scope.admin},
);
```

#### Block/Unblock Users

```dart
// Block a user
userInfo.blocked = true;
await Users.updateUserInfo(session, userInfo);

// Unblock a user
userInfo.blocked = false;
await Users.updateUserInfo(session, userInfo);
```

### User Profile Images

#### Server-Side: Profile Picture Management

Profile images are handled automatically by the auth module. Images are stored in the database and accessible via `UserInfo.imageUrl`.

#### Client-Side: Display Profile Pictures

Use the `CircularUserImage` widget to display user avatars:

```dart
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

CircularUserImage(
  userInfo: sessionManager.signedInUser,
  size: 100,
)
```

#### Client-Side: Edit Profile Images

Use the `UserImageButton` widget for profile picture updates:

```dart
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

UserImageButton(
  sessionManager: sessionManager,
  size: 150,
)
```

This widget:
- Displays current profile image
- Handles image selection
- Uploads image to server
- Updates session manager automatically

---

## Client-Side Integration

### Session Manager

The `SessionManager` handles authentication state and user sessions on the client.

#### Initialization

```dart
import 'package:serverpod_flutter/serverpod_flutter.dart';

// Create client
var client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);

// Create and initialize session manager
var sessionManager = SessionManager(
  caller: client.modules.auth,
);

await sessionManager.initialize();
```

#### Check Authentication Status

```dart
// Check if user is signed in
bool isSignedIn = sessionManager.isSignedIn;

// Get signed-in user info
UserInfo? user = sessionManager.signedInUser;

if (user != null) {
  print('Logged in as: ${user.userName}');
  print('Email: ${user.email}');
}
```

#### Listen to Authentication Changes

```dart
// Add listener to track authentication state changes
sessionManager.addListener(() {
  if (sessionManager.isSignedIn) {
    print('User signed in: ${sessionManager.signedInUser?.userName}');
    // Update UI, navigate, etc.
  } else {
    print('User signed out');
    // Update UI, navigate to login, etc.
  }
});
```

**Use in Flutter:**

```dart
class MyApp extends StatefulWidget {
  final SessionManager sessionManager;

  const MyApp({required this.sessionManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen to auth changes and update UI
    widget.sessionManager.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget.sessionManager.isSignedIn
        ? HomePage()
        : LoginPage(),
    );
  }
}
```

### Email Authentication

#### Register New User

```dart
try {
  final userInfo = await sessionManager.registerUserWithEmail(
    userName: 'John Doe',
    email: 'john@example.com',
    password: 'SecurePassword123',
  );

  if (userInfo != null) {
    print('Registration successful: ${userInfo.userName}');
    // User is automatically signed in
  } else {
    print('Registration failed');
  }
} catch (e) {
  print('Registration error: $e');
}
```

#### Sign In with Email

```dart
try {
  final userInfo = await sessionManager.signInWithEmail(
    email: 'john@example.com',
    password: 'SecurePassword123',
  );

  if (userInfo != null) {
    print('Sign in successful: ${userInfo.userName}');
  } else {
    print('Invalid credentials');
  }
} catch (e) {
  print('Sign in error: $e');
}
```

#### Request Password Reset

```dart
try {
  await client.modules.auth.email.initiatePasswordReset(
    email: 'john@example.com',
  );

  print('Password reset email sent');
} catch (e) {
  print('Password reset error: $e');
}
```

#### Reset Password with Code

```dart
try {
  await client.modules.auth.email.resetPassword(
    verificationCode: 'code-from-email',
    password: 'NewSecurePassword456',
  );

  print('Password reset successful');
} catch (e) {
  print('Password reset error: $e');
}
```

### Making Authenticated API Calls

Once authenticated, all API calls automatically include the authentication token:

```dart
// The client automatically includes auth token in requests
if (sessionManager.isSignedIn) {
  // Call authenticated endpoints
  final documents = await client.document.getDocuments(
    'blog-post',
    limit: 10,
    offset: 0,
  );

  // Create resources (requires auth)
  final newDoc = await client.document.createDocument(
    'blog-post',
    'My Title',
    {'content': 'Hello world'},
    isDefault: false,
  );
}
```

### Sign Out

```dart
// Sign out from current device
await sessionManager.signOutDevice();

// Sign out from all devices
await sessionManager.signOutAllDevices();

// Check status
print('Signed in: ${sessionManager.isSignedIn}');  // false
```

### Register User Manually (Advanced)

For custom authentication flows, you can manually register a signed-in user:

```dart
await sessionManager.registerSignedInUser(
  userInfo,      // UserInfo object
  keyId,         // Authentication key ID
  authKey,       // Authentication key
);
```

---

## Session Management

### Session Object

The `Session` object is available in all endpoint methods and provides access to:

- Authentication state
- User information
- Database connection
- Logging
- Messages
- Storage

### Session Properties

```dart
class MyEndpoint extends Endpoint {
  Future<void> myMethod(Session session) async {
    // Authentication
    final isSignedIn = session.isUserSignedIn;
    final userId = await session.userId;
    final authInfo = await session.authenticated;

    // Database
    final db = session.db;

    // Logging
    session.log('Log message');

    // Messages (for real-time communication)
    await session.messages.authenticationRevoked(
      userId!,
      RevokedAuthenticationAuthId(authId: 123),
    );
  }
}
```

### Password Access

Access configuration passwords/secrets through the session:

```dart
final apiKey = session.passwords['api_key'];
final dbPassword = session.passwords['database_password'];
```

Passwords are stored in `config/passwords.yaml` and **should never be committed to version control**.

Add `config/passwords.yaml` to your `.gitignore`:

```yaml
# config/passwords.yaml
api_key: 'your-secret-api-key'
database_password: 'your-db-password'
stripe_secret: 'sk_test_...'
```

---

## Custom Authentication Overrides

### Custom Authentication Handler

Override the default authentication handler for custom token validation:

```dart
import 'package:serverpod/serverpod.dart';

AuthenticationInfo? customAuthenticationHandler(
  Session session,
  String token,
) {
  // Custom token validation logic
  final userData = validateCustomToken(token);

  if (userData != null) {
    return AuthenticationInfo(
      userData['userId'],              // User identifier
      {Scope('user'), Scope('admin')}, // User scopes
    );
  }

  return null; // Token invalid
}

void run(List<String> args) async {
  var pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: customAuthenticationHandler,  // Use custom handler
  );

  await pod.start();
}
```

**Handler Responsibilities:**
- Validate authentication token
- Return `AuthenticationInfo` if valid
- Return `null` if invalid
- The `userIdentifier` is converted to string internally
- Use the `userId` getter to convert back to int

### Revoking Authentication

When authentication needs to be revoked, use the session messages:

```dart
// Revoke all user authentication
await session.messages.authenticationRevoked(
  userId,
  RevokedAuthenticationUser(),
);

// Revoke specific authentication key/device
await session.messages.authenticationRevoked(
  userId,
  RevokedAuthenticationAuthId(authId: authenticationId),
);

// Revoke specific scope
await session.messages.authenticationRevoked(
  userId,
  RevokedAuthenticationScope(scopes: {Scope('admin')}),
);
```

### Custom Scopes with JWT

When using JWT tokens, extract and map scopes:

```dart
AuthenticationInfo? jwtAuthenticationHandler(
  Session session,
  String token,
) {
  final jwt = decodeJWT(token);

  if (jwt != null && jwt.isValid) {
    // Extract scopes from JWT claims
    final scopeStrings = jwt.claims['scopes'] as List<String>;
    final scopes = scopeStrings.map((s) => Scope(s)).toSet();

    return AuthenticationInfo(
      jwt.claims['sub'],  // User ID from JWT subject
      scopes,
    );
  }

  return null;
}
```

### Custom Client Authentication Key Manager

Implement custom token storage on the client:

```dart
class CustomAuthenticationKeyManager implements AuthenticationKeyManager {
  String? _authKey;

  @override
  Future<String?> get() async {
    // Retrieve auth key from custom storage
    return _authKey;
  }

  @override
  Future<void> put(String key) async {
    // Store auth key in custom storage
    _authKey = key;
  }

  @override
  Future<void> remove() async {
    // Remove auth key from storage
    _authKey = null;
  }
}
```

**Production Implementation:**

Use `FlutterAuthenticationKeyManager` from `serverpod_auth_shared_flutter` for secure, persistent storage:

```dart
var client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);
```

### Custom Authentication Scheme

Implement custom header format (e.g., OAuth Bearer tokens):

```dart
class BearerTokenKeyManager extends FlutterAuthenticationKeyManager {
  @override
  Future<String?> toHeaderValue(String? key) async {
    if (key == null) return null;

    // Custom header format
    return 'Bearer ${await exchangeForBearerToken(key)}';
  }

  Future<String> exchangeForBearerToken(String key) async {
    // Exchange stored key for Bearer token
    // This is just an example
    return key;
  }
}
```

**Server-side handling:**

```dart
AuthenticationInfo? bearerAuthenticationHandler(
  Session session,
  String authHeader,
) {
  // Parse custom header format
  if (authHeader.startsWith('Bearer ')) {
    final token = authHeader.substring(7);
    return validateBearerToken(token);
  }

  return null;
}
```

---

## Security & Best Practices

### 1. Use HTTPS in Production

Always use secure connections for production deployments:

```dart
var client = Client(
  'https://api.yourapp.com/',  // HTTPS, not HTTP
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);
```

### 2. Password Security

Serverpod automatically:
- Hashes passwords using bcrypt
- Salts passwords for additional security
- Supports `extraSaltyHash` for enhanced security

Configure in `AuthConfig`:
```dart
auth.AuthConfig.set(auth.AuthConfig(
  minPasswordLength: 12,  // Enforce strong passwords
  maxPasswordLength: 128,
));
```

### 3. Rate Limiting

Protect against brute force attacks:

```dart
auth.AuthConfig.set(auth.AuthConfig(
  maxAllowedEmailSignInAttempts: 5,
  emailSignInFailureResetTime: Duration(minutes: 5),
));
```

### 4. Token Security

- **Client-side**: Tokens are stored securely using `FlutterAuthenticationKeyManager` (uses Flutter Secure Storage)
- **Server-side**: Tokens are hashed in the database
- **Transport**: Always use HTTPS to prevent token interception

### 5. Email Verification

Enable email verification in production:

```yaml
# config/production.yaml
modules:
  serverpod_auth:
    sendValidationEmail: true
```

### 6. Session Timeout

Implement session expiration by tracking last activity:

```dart
class SessionTracking extends Endpoint {
  Future<void> trackActivity(Session session) async {
    if (session.isUserSignedIn) {
      final userId = await session.userId;

      // Update last activity timestamp
      await UserActivity.db.insertRow(
        session,
        UserActivity(
          userId: userId!,
          lastActivity: DateTime.now(),
        ),
      );
    }
  }
}
```

### 7. Secure Configuration

Never commit sensitive data:

```bash
# .gitignore
config/passwords.yaml
*.env
.env.*
```

Use environment-specific configuration:
- `config/development.yaml` - Local development
- `config/staging.yaml` - Staging environment
- `config/production.yaml` - Production (use secure values)

### 8. Scope-Based Authorization

Implement least-privilege principle:

```dart
// Only grant necessary scopes
await Users.updateUserScopes(
  session,
  userId: newUserId,
  scopes: {Scope('user')},  // Start with minimal permissions
);

// Admin actions require admin scope
class AdminEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {Scope.admin};
}
```

### 9. User Blocking

Implement user blocking for security:

```dart
Future<void> blockSuspiciousUser(Session session, int userId) async {
  final userInfo = await Users.findUserByUserId(session, userId);

  if (userInfo != null) {
    userInfo.blocked = true;
    await Users.updateUserInfo(session, userInfo);

    // Revoke all sessions
    await session.messages.authenticationRevoked(
      userId,
      RevokedAuthenticationUser(),
    );
  }
}
```

### 10. Audit Logging

Log authentication events:

```dart
auth.AuthConfig.set(auth.AuthConfig(
  onUserCreated: (session, userInfo) async {
    session.log('User created: ${userInfo.email}', level: LogLevel.info);

    // Store in audit log
    await AuditLog.db.insertRow(
      session,
      AuditLog(
        action: 'user_created',
        userId: userInfo.id,
        timestamp: DateTime.now(),
      ),
    );
  },
));
```

---

## Common Patterns

### Protected Resource Access

```dart
class DocumentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<Document>> getUserDocuments(Session session) async {
    final userId = await session.userId;

    return await Document.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }
}
```

### Role-Based Access Control

```dart
class AdminEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<void> deleteUser(Session session, int targetUserId) async {
    // Only admins can access this
    final userInfo = await Users.findUserByUserId(session, targetUserId);

    if (userInfo != null) {
      await Users.deleteUser(session, userInfo);
    }
  }
}
```

### Multi-Tenancy

```dart
class TenantEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<Project>> getTenantProjects(Session session) async {
    final userId = await session.userId;

    // Get user's tenant
    final user = await Users.findUserByUserId(session, userId!);
    final tenantId = user?.scopes
      .firstWhere((s) => s.name.startsWith('tenant:'))
      .name.split(':')[1];

    return await Project.db.find(
      session,
      where: (t) => t.tenantId.equals(tenantId),
    );
  }
}
```

### Service Account Authentication

```dart
class ServiceEndpoint extends Endpoint {
  Future<void> scheduledTask(Session session) async {
    // Validate service account token
    final serviceToken = session.httpRequest.headers['X-Service-Token'];
    final expectedToken = session.passwords['service_token'];

    if (serviceToken != expectedToken) {
      throw Exception('Unauthorized service request');
    }

    // Perform task as service account
    await performBackgroundJob();
  }
}
```

---

## Resources

- **Official Setup**: https://docs.serverpod.dev/concepts/authentication/setup
- **Authentication Basics**: https://docs.serverpod.dev/concepts/authentication/basics
- **Working with Users**: https://docs.serverpod.dev/concepts/authentication/working-with-users
- **Custom Overrides**: https://docs.serverpod.dev/concepts/authentication/custom-overrides
- **API Reference**: https://pub.dev/documentation/serverpod_auth_server/latest/
- **GitHub Examples**: https://github.com/serverpod/serverpod/tree/main/examples

---

## Quick Reference

### Server-Side Checklist

- [ ] Install `serverpod_auth_server` package
- [ ] Add `authenticationHandler` to Serverpod initialization
- [ ] Create and apply migrations
- [ ] Configure `AuthConfig` (optional)
- [ ] Set `requireLogin = true` on protected endpoints
- [ ] Use `requiredScopes` for role-based access

### Client-Side Checklist

- [ ] Install `serverpod_flutter` and `serverpod_auth_shared_flutter`
- [ ] Create client with `FlutterAuthenticationKeyManager`
- [ ] Initialize `SessionManager`
- [ ] Implement sign-in/sign-up UI
- [ ] Listen to `SessionManager` for auth state changes
- [ ] Handle authenticated API calls

### Common Methods

**Server:**
```dart
await session.userId                      // Get user ID
await Users.findUserByUserId()           // Get user info
await Users.updateUserScopes()           // Update permissions
session.messages.authenticationRevoked() // Revoke auth
```

**Client:**
```dart
sessionManager.isSignedIn                           // Check status
await sessionManager.signInWithEmail()              // Sign in
await sessionManager.registerUserWithEmail()        // Register
await sessionManager.signOutDevice()                // Sign out
sessionManager.signedInUser                         // Get user info
```
