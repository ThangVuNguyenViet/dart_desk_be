/// Seeds E2E test data into the development database via docker exec.
/// Run with: dart run bin/seed_e2e.dart
/// Requires: dev postgres running (docker compose up -d postgres)
library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';

Future<String> psql(String sql) async {
  final result = await Process.run('docker', [
    'compose',
    'exec',
    '-T',
    'postgres',
    'psql',
    '-U',
    'postgres',
    '-d',
    'flutter_cms_be',
    '-t',
    '-c',
    sql,
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
      developer.log('Client "$clientSlug" already exists (id: $existingId)');
    } else {
      final insertOutput = await psql("""
INSERT INTO cms_clients (name, slug, "apiTokenHash", "apiTokenPrefix", "isActive", "createdAt", "updatedAt")
VALUES ('$clientName', '$clientSlug', '$hash', '$prefix', true, now(), now())
RETURNING id;
""");
      developer.log('Created client: $clientName (id: ${insertOutput.trim()})');
    }

    developer.log('');
    developer.log('Client slug: $clientSlug');
    developer.log('API Token:   $knownToken');
    developer.log('');
    developer.log('To run the Flutter app against E2E:');
    developer.log('  cd examples/cms_app');
    developer.log('  flutter run -d chrome -t lib/main_e2e.dart');
    developer.log('');
    developer.log(
        'Defaults are baked into main_e2e.dart. Override via --dart-define if needed.');
  } catch (e) {
    developer.log('Error: $e');
    exit(1);
  }
}
