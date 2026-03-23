/// Seeds E2E test data into the development database via docker exec.
/// Run with: dart run bin/seed_e2e.dart
/// Requires: dev postgres running (docker compose up -d postgres)
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';

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
    'dart_desk_be',
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
  const projectSlug = 'e2e-test';
  const projectName = 'E2E Test Project';
  const knownToken = 'cms_w_e2e_test_token_for_integration_testing_2026';
  final hash = sha256.convert(utf8.encode(knownToken)).toString();

  try {
    // Check if project exists
    final existingId = await psql(
      "SELECT id FROM projects WHERE slug = '$projectSlug';",
    );

    if (existingId.isNotEmpty) {
      developer.log('Project "$projectSlug" already exists (id: $existingId)');
    } else {
      final insertOutput = await psql("""
INSERT INTO projects (name, slug, "isActive", "createdAt", "updatedAt")
VALUES ('$projectName', '$projectSlug', true, now(), now())
RETURNING id;
""");
      final projectId = insertOutput.trim();
      developer.log('Created project: $projectName (id: $projectId)');

      // Insert API token
      final suffix = knownToken.substring(knownToken.length - 4);
      await psql("""
INSERT INTO api_tokens ("clientId", name, "tokenHash", "tokenPrefix", "tokenSuffix", role, "isActive", "createdAt")
VALUES ($projectId, 'E2E Test Token', '$hash', 'cms_w_', '$suffix', 'write', true, now())
ON CONFLICT DO NOTHING;
""");
    }

    developer.log('');
    developer.log('Project slug: $projectSlug');
    developer.log('API Token:    $knownToken');
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
