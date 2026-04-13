import 'package:dart_desk_server/src/generated/protocol.dart';

class RateLimiter {
  final int maxAttempts;
  final Duration windowDuration;
  final Map<String, List<DateTime>> _attempts = {};

  RateLimiter({
    required this.maxAttempts,
    required this.windowDuration,
  });

  bool isAllowed(String key) {
    final now = DateTime.now();
    final cutoff = now.subtract(windowDuration);

    _attempts.putIfAbsent(key, () => []);
    _attempts[key]!.removeWhere((t) => t.isBefore(cutoff));

    if (_attempts[key]!.length >= maxAttempts) {
      return false;
    }

    _attempts[key]!.add(now);
    return true;
  }

  void check(String key) {
    if (!isAllowed(key)) {
      throw ApiException(
        message: 'Too many requests. Please try again later.',
        code: 429,
        errorCode: 'RATE_LIMITED',
      );
    }
  }
}
