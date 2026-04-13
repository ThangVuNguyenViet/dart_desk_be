import 'package:test/test.dart';
import 'package:dart_desk_server/src/services/purge_service.dart';

void main() {
  group('PurgeService', () {
    test('cutoffDate returns correct date based on retention days', () {
      final cutoff = PurgeService.cutoffDate(retentionDays: 30);
      final expected = DateTime.now().subtract(const Duration(days: 30));
      expect(cutoff.difference(expected).inSeconds.abs(), lessThan(2));
    });

    test('cutoffDate with 0 retention returns now', () {
      final cutoff = PurgeService.cutoffDate(retentionDays: 0);
      final now = DateTime.now();
      expect(cutoff.difference(now).inSeconds.abs(), lessThan(2));
    });
  });
}
