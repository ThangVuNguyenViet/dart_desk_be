import 'package:test/test.dart';
import 'package:dart_desk_server/src/services/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    late RateLimiter limiter;

    setUp(() {
      limiter = RateLimiter(maxAttempts: 3, windowDuration: Duration(minutes: 1));
    });

    test('allows requests under limit', () {
      expect(limiter.isAllowed('key1'), isTrue);
      expect(limiter.isAllowed('key1'), isTrue);
      expect(limiter.isAllowed('key1'), isTrue);
    });

    test('blocks requests over limit', () {
      limiter.isAllowed('key1');
      limiter.isAllowed('key1');
      limiter.isAllowed('key1');
      expect(limiter.isAllowed('key1'), isFalse);
    });

    test('different keys have separate limits', () {
      limiter.isAllowed('key1');
      limiter.isAllowed('key1');
      limiter.isAllowed('key1');
      expect(limiter.isAllowed('key1'), isFalse);
      expect(limiter.isAllowed('key2'), isTrue);
    });
  });
}
