import 'dart:convert';
import 'package:test/test.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/services/document_crdt_service.dart';

/// Helper to build a DocumentCrdtOperation for testing.
DocumentCrdtOperation putOp(String fieldPath, dynamic value, {String hlc = '2026-01-01T00:00:00.000Z-0000-test'}) {
  return DocumentCrdtOperation(
    documentId: 1,
    hlc: hlc,
    nodeId: 'test-node',
    operationType: CrdtOperationType.put,
    fieldPath: fieldPath,
    fieldValue: jsonEncode(value),
  );
}

DocumentCrdtOperation deleteOp(String fieldPath, {String hlc = '2026-01-01T00:00:00.000Z-0000-test'}) {
  return DocumentCrdtOperation(
    documentId: 1,
    hlc: hlc,
    nodeId: 'test-node',
    operationType: CrdtOperationType.delete,
    fieldPath: fieldPath,
  );
}

void main() {
  late DocumentCrdtService service;

  setUp(() {
    service = DocumentCrdtService('test-node');
  });

  group('reconstructFromOperations', () {
    test('empty state with no operations returns empty map', () {
      final result = service.reconstructFromOperations(
        [],
        initialState: {},
      );
      expect(result, equals({}));
    });

    test('round-trip: operations reconstruct nested map', () {
      final ops = [
        putOp('user.name', 'John'),
        putOp('user.email', 'john@example.com'),
        putOp('title', 'Hello'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result, equals({
        'user': {'name': 'John', 'email': 'john@example.com'},
        'title': 'Hello',
      }));
    });

    test('deeply nested structures (3-4 levels) reconstruct correctly', () {
      final ops = [
        putOp('page.sections.hero.title', 'Welcome'),
        putOp('page.sections.hero.subtitle', 'Start here'),
        putOp('page.sections.content.blocks.text', 'Hello world'),
        putOp('page.metadata.seo.description', 'A test page'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['page']['sections']['hero']['title'], equals('Welcome'));
      expect(result['page']['sections']['content']['blocks']['text'], equals('Hello world'));
      expect(result['page']['metadata']['seo']['description'], equals('A test page'));
    });

    test('mixed types preserved through JSON encode/decode', () {
      final ops = [
        putOp('str', 'hello'),
        putOp('num_int', 42),
        putOp('num_double', 3.14),
        putOp('flag', true),
        putOp('items', ['a', 'b', 'c']),
        putOp('nullable', null),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['str'], equals('hello'));
      expect(result['num_int'], equals(42));
      expect(result['num_double'], equals(3.14));
      expect(result['flag'], isTrue);
      expect(result['items'], equals(['a', 'b', 'c']));
      expect(result['nullable'], isNull);
    });

    test('multiple puts to same field path: last value wins', () {
      final ops = [
        putOp('name', 'Alice', hlc: '2026-01-01T00:00:01.000Z-0000-test'),
        putOp('name', 'Bob', hlc: '2026-01-01T00:00:02.000Z-0000-test'),
        putOp('name', 'Charlie', hlc: '2026-01-01T00:00:03.000Z-0000-test'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['name'], equals('Charlie'));
    });

    test('delete operations remove fields without affecting siblings', () {
      final ops = [
        putOp('user.name', 'John'),
        putOp('user.email', 'john@test.com'),
        putOp('title', 'Hello'),
        deleteOp('user.email'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['user'], equals({'name': 'John'}));
      expect(result['title'], equals('Hello'));
    });

    test('operations merge with initial state', () {
      final initialState = {
        'existing': 'value',
        'nested': {'keep': 'this'},
      };

      final ops = [
        putOp('new_field', 'added'),
        putOp('nested.extra', 'appended'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: initialState,
      );

      expect(result['existing'], equals('value'));
      expect(result['new_field'], equals('added'));
      expect(result['nested']['keep'], equals('this'));
      expect(result['nested']['extra'], equals('appended'));
    });
  });
}
