import 'package:serverpod/serverpod.dart';

/// Typed extension on [Session] for accessing auth scopes.
extension DartDeskSessionExt on Session {
  UuidValue? get clientId {
    final activeScopes = authenticated?.scopes ?? {};
    for (final scope in activeScopes) {
      final name = scope.name;
      if (name != null && name.startsWith('client:')) {
        try {
          return UuidValue.fromString(name.substring(7));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  UuidValue? get projectId {
    final activeScopes = authenticated?.scopes ?? {};
    for (final scope in activeScopes) {
      final name = scope.name;
      if (name != null && name.startsWith('project:')) {
        try {
          return UuidValue.fromString(name.substring(8));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  bool get canRead =>
      (authenticated?.scopes ?? {}).contains(const Scope('project.read'));

  bool get canWrite =>
      (authenticated?.scopes ?? {}).contains(const Scope('project.write'));

  String? get clientRole {
    final activeScopes = authenticated?.scopes ?? {};
    for (final scope in activeScopes) {
      final name = scope.name;
      if (name != null && name.startsWith('client.role:')) {
        return name.substring(12);
      }
    }
    return null;
  }

  bool get isClientAdmin {
    final role = clientRole;
    return role == 'owner' || role == 'admin';
  }
}
