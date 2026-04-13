import 'package:dart_desk_server/src/services/migration_service.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late MigrationService service;

  setUp(() {
    service = MigrationService();
  });

  group('renameField', () {
    test('renames a top-level field', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'primaryColor': '#FF0000', 'other': 'value'},
        operations: [
          MigrationOperation(type: 'renameField', from: 'primaryColor', to: 'mainColor'),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'mainColor': '#FF0000', 'other': 'value'});
      expect(result.changes, ['renameField: primaryColor -> mainColor']);
    });

    test('renames a nested field', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'metadata': {'author': 'Jane', 'version': 3}},
        operations: [
          MigrationOperation(type: 'renameField', from: 'metadata.author', to: 'metadata.writer'),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'metadata': {'writer': 'Jane', 'version': 3}});
    });

    test('renames a nested object with all sub-keys', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'old': {'a': 1, 'b': 2}},
        operations: [
          MigrationOperation(type: 'renameField', from: 'old', to: 'new'),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'new': {'a': 1, 'b': 2}});
    });

    test('skips when field not found', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'other': 'value'},
        operations: [
          MigrationOperation(type: 'renameField', from: 'missing', to: 'new'),
        ],
      );
      expect(result.status, 'skipped');
      expect(result.reason, 'no matching fields found');
    });
  });

  group('deleteField', () {
    test('deletes a top-level field', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'keep': 'yes', 'remove': 'me'},
        operations: [
          MigrationOperation(type: 'deleteField', path: 'remove'),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'keep': 'yes'});
    });

    test('deletes a nested field and its sub-keys', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'metadata': {'author': 'Jane', 'version': 3}, 'title': 'Hello'},
        operations: [
          MigrationOperation(type: 'deleteField', path: 'metadata'),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'title': 'Hello'});
    });

    test('skips when field not found', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'keep': 'yes'},
        operations: [
          MigrationOperation(type: 'deleteField', path: 'missing'),
        ],
      );
      expect(result.status, 'skipped');
    });
  });

  group('setField', () {
    test('sets a new field', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'existing': 'value'},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'existing': 'value', 'version': 2});
    });

    test('overwrites an existing field', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'version': 1},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'version': 2});
    });
  });

  group('multiple operations', () {
    test('applies multiple operations in order', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {'oldName': 'hello', 'legacy': true},
        operations: [
          MigrationOperation(type: 'renameField', from: 'oldName', to: 'newName'),
          MigrationOperation(type: 'deleteField', path: 'legacy'),
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'newName': 'hello', 'version': 2});
      expect(result.changes, hasLength(3));
    });
  });

  group('empty document', () {
    test('setField works on empty document', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 1),
        ],
      );
      expect(result.status, 'modified');
      expect(result.newData, {'version': 1});
    });

    test('rename on empty document is skipped', () {
      final result = service.applyOperations(
        documentId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        title: 'Test Doc',
        data: {},
        operations: [
          MigrationOperation(type: 'renameField', from: 'a', to: 'b'),
        ],
      );
      expect(result.status, 'skipped');
    });
  });
}
