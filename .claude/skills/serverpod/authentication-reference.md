# Serverpod Authentication Reference

## Overview

Serverpod provides built-in authentication support with multiple providers. User authentication comes ready out-of-the-box, making it easy to secure your application.

## Supported Authentication Methods

### 1. Email & Password Authentication
The foundational authentication method using traditional credentials.

**Features:**
- User registration
- Login with email/password
- Password hashing and security
- Password reset functionality
- Email verification

### 2. Google Sign-In
OAuth authentication through Google accounts.

**Features:**
- One-click Google Sign-In
- Access to Google user profile
- Extended API integration for user resources
- Automatic account creation

### 3. Apple Sign-In
Apple's authentication for iOS and macOS applications.

**Features:**
- Native Apple Sign-In experience
- Privacy-focused authentication
- Seamless iOS/macOS integration
- Automatic account creation

### 4. Firebase Authentication
Integration with Firebase Auth services.

**Features:**
- Multiple provider support through Firebase
- Real-time authentication state
- Firebase ecosystem integration

## Setup Recommendation

The documentation emphasizes starting with the initial setup and email/password authentication before implementing provider-specific integrations. This sequential approach ensures a solid foundation.

**Recommended Learning Path:**
1. Initial authentication setup
2. Email & password implementation
3. OAuth providers (Google, Apple)
4. Extended integrations and customization

## Session Management

Serverpod handles sessions through the `Session` object, which is available in all endpoint methods.

### Session Object Features

- **User Authentication State**: Check if user is logged in
- **User Information**: Access authenticated user details
- **Database Access**: Query user data
- **Security**: Built-in security measures

### Basic Session Usage

```dart
class UserEndpoint extends Endpoint {
  Future<String> getProfile(Session session) async {
    // Check if user is authenticated
    if (!session.isUserSignedIn) {
      throw Exception('User not authenticated');
    }

    // Access authenticated user
    final userId = session.userId;
    final userInfo = await session.auth.getUserInfo(userId);

    return 'Hello ${userInfo.userName}';
  }
}
```

## Requiring Authentication

### Endpoint-Level Authentication

```dart
class SecureEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> secureMethod(Session session) async {
    // This method requires authentication
    return 'Secure data';
  }
}
```

### Base Class for Authenticated Endpoints

```dart
abstract class LoggedInEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
}

// All endpoints extending this base class require authentication
class UserProfileEndpoint extends LoggedInEndpoint {
  Future<UserProfile> getProfile(Session session) async {
    // User is guaranteed to be authenticated here
    final userId = session.userId!;
    return await UserProfile.db.findById(session, userId);
  }
}
```

## Password Access

Access configuration passwords through the session:

```dart
final apiKey = session.passwords['api_key'];
```

Passwords are stored in `config/passwords.yaml` and should never be committed to version control.

## Authentication Flow

### Registration Flow

1. User provides credentials
2. Server validates and hashes password
3. User account created in database
4. Optional: Send verification email
5. Session created and returned to client

### Login Flow

1. User provides credentials
2. Server validates credentials
3. Session token generated
4. Token returned to client
5. Client includes token in subsequent requests

### OAuth Flow (Google/Apple)

1. User initiates OAuth flow
2. Redirect to provider (Google/Apple)
3. User authenticates with provider
4. Provider returns authorization code
5. Server exchanges code for user info
6. User account created/updated
7. Session token returned to client

## Security Best Practices

1. **Use HTTPS**: Always use secure connections in production
2. **Password Security**: Serverpod automatically hashes passwords
3. **Session Tokens**: Store securely on client-side
4. **Token Expiration**: Implement session timeout
5. **Secure Config**: Never commit `passwords.yaml` to git
6. **Rate Limiting**: Implement login attempt limiting
7. **Email Verification**: Verify user emails before full access
8. **Two-Factor Auth**: Consider adding 2FA for sensitive operations

## Client-Side Implementation

After setting up server authentication, use the generated client:

```dart
// Initialize client with session management
final client = Client(
  'http://localhost:8080/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
);

// Sign in
final result = await client.modules.auth.email.authenticate(
  email: 'user@example.com',
  password: 'password123',
);

// Check authentication status
final isSignedIn = await client.modules.auth.status.isSignedIn();

// Sign out
await client.modules.auth.signOut();
```

## Database Tables

Authentication typically involves these tables:
- `users` - User account information
- `user_sessions` - Active session tokens
- `user_images` - User profile images (optional)
- Provider-specific tables for OAuth data

## Resources

- **Setup Guide**: https://docs.serverpod.dev/tutorials/guides/authentication
- **API Reference**: https://pub.dev/documentation/serverpod/latest/
- **GitHub Examples**: https://github.com/serverpod/serverpod

## Common Patterns

### Protected Resource Access

```dart
Future<List<Document>> getUserDocuments(Session session) async {
  if (!session.isUserSignedIn) {
    throw Exception('Unauthorized');
  }

  return await Document.db.find(
    session,
    where: (t) => t.userId.equals(session.userId),
  );
}
```

### Role-Based Access Control

```dart
Future<void> adminAction(Session session) async {
  final user = await User.db.findById(session, session.userId!);

  if (user?.role != 'admin') {
    throw Exception('Insufficient permissions');
  }

  // Perform admin action
}
```

### Custom Authentication Logic

```dart
Future<bool> validateCustomToken(Session session, String token) async {
  // Custom token validation logic
  final isValid = await verifyToken(token);

  if (isValid) {
    // Set session authentication state
    await session.auth.signInUser(userId);
    return true;
  }

  return false;
}
```
