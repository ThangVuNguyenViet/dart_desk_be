/// Seeds E2E test data into the development database via docker exec.
/// Run with: dart run bin/seed_e2e.dart
/// Requires: dev postgres running (docker compose up -d postgres)
import 'dart:io';
import 'package:dbcrypt/dbcrypt.dart';

Future<String> psql(String sql) async {
  final result = await Process.run('docker', [
    'compose', 'exec', '-T', 'postgres',
    'psql', '-U', 'postgres', '-d', 'flutter_cms_be',
    '-t', '-c', sql,
  ]);
  if (result.exitCode != 0) {
    throw Exception('psql error: ${result.stderr}');
  }
  return result.stdout.toString().trim();
}

void main() async {
  const clientSlug = 'e2e-test';
  const clientName = 'E2E Test Client';
  const knownToken = 'cms_ad_e2e_test_token_for_integration_testing_2026';
  final hash = DBCrypt().hashpw(knownToken, DBCrypt().gensalt());
  final prefix = knownToken.substring(0, 16);

  try {
    // Check if client exists
    final existingId = await psql(
      "SELECT id FROM cms_clients WHERE slug = '\$clientSlug';",
    );

    if (existingId.isNotEmpty) {
      print('Client "$clientSlug" already exists (id: $existingId)');
    } else {
      final insertOutput = await psql("""
INSERT INTO cms_clients (name, slug, "apiTokenHash", "apiTokenPrefix", "isActive", "createdAt", "updatedAt")
VALUES ('$clientName', '$clientSlug', '$hash', '$prefix', true, now(), now())
RETURNING id;
""");
      print('Created client: $clientName (id: ${insertOutput.trim()})');
    }

    print('');
    print('Client slug: $clientSlug');
    print('API Token:   $knownToken');
    print('');
    print('To run the Flutter app against E2E:');
    print('  cd examples/cms_app');
    print('  flutter run -d chrome --web-port=60366 \\');
    print('    --dart-define=SERVER_URL=http://localhost:8080/ \\');
    print('    --dart-define=CMS_CLIENT_ID=$clientSlug \\');
    print('    --dart-define=CMS_API_TOKEN=$knownToken');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
