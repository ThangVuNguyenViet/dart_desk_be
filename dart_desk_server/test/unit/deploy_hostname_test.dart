import 'package:test/test.dart';
import 'package:dart_desk_server/src/util/deploy_hostname.dart';

void main() {
  group('isValidDeployHostname', () {
    test('accepts a typical hostname', () {
      expect(isValidDeployHostname('acme-blog'), isTrue);
    });
    test('rejects hostname starting with digit', () {
      expect(isValidDeployHostname('1acme'), isFalse);
    });
    test('rejects hostname starting with hyphen', () {
      expect(isValidDeployHostname('-acme'), isFalse);
    });
    test('rejects hostname ending with hyphen', () {
      expect(isValidDeployHostname('acme-'), isFalse);
    });
    test('rejects uppercase', () {
      expect(isValidDeployHostname('Acme'), isFalse);
    });
    test('rejects underscore', () {
      expect(isValidDeployHostname('a_cme'), isFalse);
    });
    test('rejects too short', () {
      expect(isValidDeployHostname('ab'), isFalse);
    });
    test('rejects too long', () {
      expect(isValidDeployHostname('a' + 'b' * 63), isFalse);
    });
    test('accepts 63 chars', () {
      expect(isValidDeployHostname('a' + 'b' * 61 + 'c'), isTrue);
    });
    test('rejects xn- prefix (punycode reserved)', () {
      expect(isValidDeployHostname('xn-foo'), isFalse);
    });
    test('accepts xn followed by non-hyphen', () {
      expect(isValidDeployHostname('xnet'), isTrue);
    });
  });

  group('isReservedDeployHostname', () {
    test('blocks api', () {
      expect(isReservedDeployHostname('api'), isTrue);
    });
    test('blocks www', () {
      expect(isReservedDeployHostname('www'), isTrue);
    });
    test('does not block ordinary names', () {
      expect(isReservedDeployHostname('acme-blog'), isFalse);
    });
    test('case-insensitive', () {
      expect(isReservedDeployHostname('API'), isTrue);
    });
  });

  group('slugifyForHostname', () {
    test('lowercases and collapses non-alphanumeric runs', () {
      expect(slugifyForHostname('Acme Blog!'), equals('acme-blog'));
    });
    test('strips leading/trailing hyphens', () {
      expect(slugifyForHostname('--acme--'), equals('acme'));
    });
  });

  group('deriveDeployHostnameCandidates', () {
    test('first candidate is the base', () {
      final it = deriveDeployHostnameCandidates('acme-demo').iterator;
      it.moveNext();
      expect(it.current, equals('acme-demo'));
    });
    test('subsequent candidates have suffix', () {
      final list = deriveDeployHostnameCandidates('acme-demo').take(4).toList();
      expect(list, equals(['acme-demo', 'acme-demo-2', 'acme-demo-3', 'acme-demo-4']));
    });
    test('caps at 100', () {
      expect(deriveDeployHostnameCandidates('a').length, equals(100));
    });
  });
}
