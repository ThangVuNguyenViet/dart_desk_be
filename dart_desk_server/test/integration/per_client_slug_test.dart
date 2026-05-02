import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Per-client project slug uniqueness', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    test('two different clients can have projects with the same slug', () async {
      final session = sessionBuilder.build();

      final alphaId = UuidValue.fromString('00000000-0000-4000-8000-000000000a01');
      final betaId = UuidValue.fromString('00000000-0000-4000-8000-000000000b01');

      final alpha = await factory.ensureTestClient(
        clientId: alphaId,
        name: 'Alpha Client',
        slug: 'alpha',
      );
      final beta = await factory.ensureTestClient(
        clientId: betaId,
        name: 'Beta Client',
        slug: 'beta',
      );

      // Both clients create a project with slug 'demo' — should succeed.
      final alphaProject = await Project.db.insertRow(
        session,
        Project(
          clientId: alpha.id!,
          name: 'Demo',
          slug: 'demo',
          deployHostname: 'alpha-demo',
          isActive: true,
        ),
      );
      final betaProject = await Project.db.insertRow(
        session,
        Project(
          clientId: beta.id!,
          name: 'Demo',
          slug: 'demo',
          deployHostname: 'beta-demo',
          isActive: true,
        ),
      );

      expect(alphaProject.id, isNotNull);
      expect(betaProject.id, isNotNull);
      expect(alphaProject.deployHostname, equals('alpha-demo'));
      expect(betaProject.deployHostname, equals('beta-demo'));
      expect(alphaProject.id, isNot(equals(betaProject.id)));
    });

    test('same client cannot have two active projects with the same slug', () async {
      final session = sessionBuilder.build();

      final clientId = UuidValue.fromString('00000000-0000-4000-8000-000000000c01');
      await factory.ensureTestClient(
        clientId: clientId,
        name: 'Gamma Client',
        slug: 'gamma',
      );

      // First project — succeeds.
      await Project.db.insertRow(
        session,
        Project(
          clientId: clientId,
          name: 'Demo',
          slug: 'demo',
          deployHostname: 'gamma-demo',
          isActive: true,
        ),
      );

      // Second project with same client + same slug — must throw due to
      // the partial unique index projects_client_slug_active_idx.
      await expectLater(
        () => Project.db.insertRow(
          session,
          Project(
            clientId: clientId,
            name: 'Demo Duplicate',
            slug: 'demo',
            deployHostname: 'gamma-demo-2',
            isActive: true,
          ),
        ),
        throwsA(anything),
      );
    });
  });
}
