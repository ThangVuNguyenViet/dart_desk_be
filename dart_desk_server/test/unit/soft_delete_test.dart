import 'package:test/test.dart';
import 'package:dart_desk_server/src/services/soft_delete.dart';

void main() {
  group('SoftDelete', () {
    test('softDelete sets deletedAt to current time', () {
      final now = DateTime.now();
      final result = SoftDelete.timestamp();
      expect(result.difference(now).inSeconds.abs(), lessThan(2));
    });
  });
}
