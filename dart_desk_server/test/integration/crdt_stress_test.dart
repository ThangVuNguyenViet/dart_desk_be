@Tags(['stress'])
library;

import 'dart:convert';
import 'dart:math';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/plugin/dart_desk_session.dart';
import 'package:dart_desk_server/src/services/document_crdt_service.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('CRDT stress test', (sessionBuilder, endpoints) {
    late TestDataFactory factory;
    late DocumentCrdtService crdtService;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      crdtService = DartDeskSession.registry.documentCrdtService;
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    test('200 fields, 2000 operations, reconstruct and compact', () async {
      final authed = factory.authenticatedSession();
      final session = sessionBuilder.build();
      final random = Random(42); // Fixed seed for reproducibility

      // 1. Create initial document with ~200 fields (simulating a complex CMS page)
      final initialData = <String, dynamic>{};
      for (var s = 0; s < 10; s++) {
        final section = <String, dynamic>{};
        for (var b = 0; b < 5; b++) {
          section['block_$b'] = <String, dynamic>{
            'title': 'Section $s Block $b',
            'content': 'Lorem ipsum dolor sit amet, section $s block $b.',
            'visible': true,
            'order': b,
          };
        }
        initialData['section_$s'] = section;
      }

      final doc = await factory.createTestDocument(
        title: 'Stress Test Doc',
        data: initialData,
      );

      // Record intermediate HLC for history check later
      String? midpointHlc;

      // 2. Apply ~2000 CRDT operations in batches
      final fieldPaths = <String>[];
      for (var s = 0; s < 10; s++) {
        for (var b = 0; b < 5; b++) {
          fieldPaths.addAll([
            'section_$s.block_$b.title',
            'section_$s.block_$b.content',
            'section_$s.block_$b.visible',
            'section_$s.block_$b.order',
          ]);
        }
      }

      for (var batch = 0; batch < 100; batch++) {
        final updates = <String, dynamic>{};
        for (var i = 0; i < 20; i++) {
          final path = fieldPaths[random.nextInt(fieldPaths.length)];
          // Split dot-path to build nested map for updateDocumentData
          final keys = path.split('.');
          dynamic target = updates;
          for (var k = 0; k < keys.length - 1; k++) {
            (target as Map<String, dynamic>)[keys[k]] ??= <String, dynamic>{};
            target = target[keys[k]];
          }
          // Set a variety of value types
          final valueType = random.nextInt(3);
          dynamic value;
          if (valueType == 0) {
            value = 'updated_batch_${batch}_i_$i';
          } else if (valueType == 1) {
            value = random.nextInt(10000);
          } else {
            value = random.nextBool();
          }
          (target as Map<String, dynamic>)[keys.last] = value;
        }

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          updates,
        );

        // Capture HLC at midpoint
        if (batch == 50) {
          midpointHlc = await crdtService.getCurrentHlc(session, doc.id!);
        }
      }

      // 3. Verify getCurrentState returns valid data
      final stopwatch = Stopwatch()..start();
      final currentState = await crdtService.getCurrentState(session, doc.id!);
      stopwatch.stop();

      expect(currentState, isNotEmpty);
      expect(currentState.keys.where((k) => k.startsWith('section_')).length, equals(10));

      // Performance guard: should complete well under 15 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(15000),
        reason: 'getCurrentState took ${stopwatch.elapsedMilliseconds}ms, expected < 15000ms',
      );

      // 4. Verify getStateAtHlc for historical reconstruction
      if (midpointHlc != null) {
        final historicalState = await crdtService.getStateAtHlc(
          session,
          doc.id!,
          midpointHlc,
        );
        expect(historicalState, isNotEmpty);
        // Historical state should have the same top-level structure
        expect(historicalState.keys.where((k) => k.startsWith('section_')).length, equals(10));
      }

      // 5. Verify reconstructFromOperations matches getCurrentState
      // Get all operations
      final allOpsResult = await session.db.unsafeQuery(
        r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 ORDER BY hlc ASC',
        parameters: QueryParameters.positional([doc.id!]),
      );
      final allOps = allOpsResult
          .map((row) => DocumentCrdtOperation.fromJson(row.toColumnMap()))
          .toList();

      final reconstructed = crdtService.reconstructFromOperations(
        allOps,
        initialState: {},
      );
      expect(jsonEncode(reconstructed), equals(jsonEncode(currentState)));

      // 6. Test compaction
      final opCountBefore = await crdtService.getOperationCount(session, doc.id!);
      expect(opCountBefore, greaterThan(1000));

      await crdtService.compactOperations(session, doc.id!, threshold: 100);

      final opCountAfter = await crdtService.getOperationCount(session, doc.id!);
      expect(opCountAfter, lessThan(opCountBefore));

      // State should still be correct after compaction
      final stateAfterCompaction = await crdtService.getCurrentState(session, doc.id!);
      expect(jsonEncode(stateAfterCompaction), equals(jsonEncode(currentState)));
    });
  });
}
