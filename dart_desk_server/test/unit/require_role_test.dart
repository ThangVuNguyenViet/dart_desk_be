import 'package:dart_desk_server/src/auth/require_role.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('RoleGuard', () {
    test('isAllowed returns true when role is in allowed list', () {
      expect(
        RoleGuard.isAllowed(ClientRole.owner, [ClientRole.admin, ClientRole.owner]),
        isTrue,
      );
    });

    test('isAllowed returns false when role is not in allowed list', () {
      expect(
        RoleGuard.isAllowed(ClientRole.viewer, [ClientRole.admin, ClientRole.owner]),
        isFalse,
      );
    });

    test('destructiveRoles contains owner and admin', () {
      expect(RoleGuard.destructiveRoles, contains(ClientRole.owner));
      expect(RoleGuard.destructiveRoles, contains(ClientRole.admin));
      expect(RoleGuard.destructiveRoles.length, 2);
    });

    test('writeRoles contains owner, admin, editor (member)', () {
      expect(RoleGuard.writeRoles, contains(ClientRole.owner));
      expect(RoleGuard.writeRoles, contains(ClientRole.admin));
      expect(RoleGuard.writeRoles, contains(ClientRole.member));
    });
  });
}
