import 'package:serverpod/serverpod.dart';

/// Typed extension on [Session] for accessing auth scopes.
extension DartDeskSessionExt on Session {
  int? get clientId {
    final activeScopes = authenticated?.scopes ?? {};
    for (final scope in activeScopes) {
      final name = scope.name;
      if (name != null && name.startsWith('client:')) {
        return int.tryParse(name.substring(7));
      }
    }
    return null;
  }

  int? get projectId {
    final activeScopes = authenticated?.scopes ?? {};
    for (final scope in activeScopes) {
      final name = scope.name;
      if (name != null && name.startsWith('project:')) {
        return int.tryParse(name.substring(8));
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
