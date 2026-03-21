import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('User endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('ensureUser', () {
      test('creates user if not exists', () async {
        final authed = factory.authenticatedSession();
        final user = await endpoints.user.ensureUser(authed);

        expect(user.id, isNotNull);
        expect(user.email, isNotEmpty);
      });

      test('returns existing user on second call', () async {
        final authed = factory.authenticatedSession();
        final user1 = await endpoints.user.ensureUser(authed);
        final user2 = await endpoints.user.ensureUser(authed);

        expect(user1.id, equals(user2.id));
      });
    });

    group('getCurrentUser', () {
      test('returns user after ensureUser', () async {
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed);

        final user = await endpoints.user.getCurrentUser(authed);

        expect(user, isNotNull);
      });
    });

    group('getUserCount', () {
      test('returns count of active users', () async {
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed);

        final count = await endpoints.user.getUserCount(authed);

        expect(count, greaterThanOrEqualTo(1));
      });
    });

    group('user association with documents', () {
      test('document tracks createdByUserId', () async {
        final authed = factory.authenticatedSession();
        final user = await endpoints.user.ensureUser(authed);

        final doc = await endpoints.document.createDocument(
          authed, 'assoc_test', 'User Assoc Doc', {},
          isDefault: false,
        );

        expect(doc.createdByUserId, equals(user.id));
      });
    });
  });
}
