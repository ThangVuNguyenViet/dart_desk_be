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

    group('getCurrentUser', () {
      test('returns user when User record exists', () async {
        await factory.ensureTestUser();
        final authed = factory.authenticatedSession();

        final user = await endpoints.user.getCurrentUser(authed, clientId: TestDataFactory.testClientId);

        expect(user, isNotNull);
        // Email comes from the pre-inserted test record
        expect(user!.email, equals('test@example.com'));
      });

      test('throws when no User record exists', () async {
        final authed = factory.authenticatedSession(
          userIdentifier: 'new-user',
        );

        expect(
          () => endpoints.user.getCurrentUser(authed, clientId: TestDataFactory.testClientId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getUserCount', () {
      test('returns count of active users', () async {
        await factory.ensureTestUser();
        final authed = factory.authenticatedSession();

        final count = await endpoints.user.getUserCount(authed, clientId: TestDataFactory.testClientId);

        expect(count, greaterThanOrEqualTo(1));
      });
    });

    group('user association with documents', () {
      test('document tracks createdByUserId', () async {
        final user = await factory.ensureTestUser();
        final authed = factory.authenticatedSession();

        final doc = await endpoints.document.createDocument(
          authed, 'assoc_test', 'User Assoc Doc', {},
          isDefault: false,
        );

        expect(doc.createdByUserId, equals(user.id));
      });
    });
  });
}
