# Invite Feature — Backend Plan (dart_desk_be)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current stub `MemberEndpoint.inviteMember` with a full email-link invite flow: pending Invite rows, email delivery, and a public InviteEndpoint with preview + accept that bridges into `serverpod_auth_idp` AuthUsers.

**Architecture:**
- New `Invite` model (Serverpod-managed) + new `InviteEndpoint` (public, `requireLogin = false`).
- `MemberEndpoint.inviteMember` no longer creates a `User`; it creates an Invite row and emails an accept link. The `User` row is created later, on accept.
- Email delivery: introduce a small `EmailSender` abstraction over the existing `EmailService` so tests can substitute a fake.
- Schema: a hand-edited partial unique index `invites_client_email_pending_idx WHERE accepted_at IS NULL AND revoked_at IS NULL` (Serverpod tooling can't express partial uniques, per `CLAUDE.md` standing rule).

**Tech Stack:** Dart, Serverpod 3.5+ (`serverpod_auth_idp_server`), PostgreSQL, `mailer` SMTP.

**Spec:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_cloud/dart_desk_manage/docs/superpowers/specs/2026-05-06-invite-feature-design.md` (working copy — gitignored). Read it for design rationale.

---

## Repo conventions to respect (read before starting)

- Project root: `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be`. Sub-packages: `dart_desk_server/` (server) and `dart_desk_client/` (generated client — committed).
- After ANY model change, run `dart run serverpod generate` from `dart_desk_server/`. This regenerates `dart_desk_server/lib/src/generated/` AND `dart_desk_client/lib/src/protocol/`. Both must be committed.
- After model changes, `dart run serverpod create-migration --tag <slug>` from `dart_desk_server/`.
- **`CLAUDE.md` standing rules** (READ): `dart_desk_be/CLAUDE.md` covers schema drift you MUST replay into every new migration's `definition.sql`:
  1. `published_documents.data_jsonb` generated column + `published_docs_data_gin` GIN index.
  2. Five `*_active_idx` partial unique indexes: `clients_slug_active_idx`, `documents_project_type_slug_active_idx`, `published_docs_project_type_slug_active_idx`, `projects_slug_active_idx`, `users_client_email_active_idx`.
  3. (NEW for this plan) `invites_client_email_pending_idx`.
- Tests run via `dart test test/integration/...` after `dart run serverpod generate`. The existing test harness uses `withServerpod(applyMigrations: true)` which bootstraps from the latest `definition.sql`.
- Conventional commits, no AI Co-Authored-By trailers.

---

## File Structure

**Created (server):**
- `dart_desk_server/lib/src/models/invite.spy.yaml`
- `dart_desk_server/lib/src/models/invite_preview.spy.yaml`
- `dart_desk_server/lib/src/models/invite_result.spy.yaml`
- `dart_desk_server/lib/src/services/email_sender.dart` (new abstraction + SMTP impl)
- `dart_desk_server/lib/src/services/invite_email.dart`
- `dart_desk_server/lib/src/endpoints/invite_endpoint.dart`
- `dart_desk_server/lib/src/auth/auth_user_resolver.dart` (helper to look up AuthUser by email across IDPs)
- `dart_desk_server/test/integration/member_endpoint_invite_test.dart`
- `dart_desk_server/test/integration/invite_endpoint_test.dart`
- `dart_desk_server/test/_support/fake_email_sender.dart`
- `dart_desk_server/migrations/<timestamp>-add-invites/migration.sql` (generated, then hand-edited)
- `dart_desk_server/migrations/<timestamp>-add-invites/definition.sql` (generated, then hand-edited)

**Modified (server):**
- `dart_desk_server/lib/src/endpoints/member_endpoint.dart` — replace `inviteMember`, add `listPendingInvites` / `resendInvite` / `revokeInvite`.
- `dart_desk_server/lib/server.dart` — wire `EmailSender` global, expose getter for endpoints, replace inline `_sendEmail` with the new sender.
- `dart_desk_server/config/development.yaml`, `staging.yaml`, `production.yaml` — add `manageBaseUrl`.

**Auto-regenerated:**
- `dart_desk_server/lib/src/generated/**` and `dart_desk_client/lib/src/protocol/**`.

---

## Task 1: Add Invite + InvitePreview + InviteResult models

**Files:**
- Create: `dart_desk_server/lib/src/models/invite.spy.yaml`
- Create: `dart_desk_server/lib/src/models/invite_preview.spy.yaml`
- Create: `dart_desk_server/lib/src/models/invite_result.spy.yaml`

- [ ] **Step 1: Write `invite.spy.yaml`**

```yaml
class: Invite
table: invites
fields:
  id: UuidValue, defaultModel=random
  clientId: UuidValue
  email: String
  role: ClientRole
  token: String
  invitedByUserId: UuidValue
  expiresAt: DateTime
  acceptedAt: DateTime?
  acceptedUserId: UuidValue?
  revokedAt: DateTime?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  invites_token_idx:
    fields: token
    unique: true
  invites_client_idx:
    fields: clientId
```

- [ ] **Step 2: Write `invite_preview.spy.yaml`**

```yaml
### server-only DTO returned by InviteEndpoint.previewInvite
class: InvitePreview
fields:
  clientId: UuidValue
  clientName: String
  email: String
  role: ClientRole
  inviterName: String
  inviterEmail: String
  expiresAt: DateTime
  hasExistingAccount: bool
```

- [ ] **Step 3: Write `invite_result.spy.yaml`**

```yaml
### server-only DTO returned by inviteMember and resendInvite
class: InviteResult
fields:
  invite: Invite
  emailSent: bool
```

- [ ] **Step 4: Run codegen**

Run from `dart_desk_server/`: `dart run serverpod generate`
Expected: regenerates `lib/src/generated/protocol.dart` and `dart_desk_client/lib/src/protocol/`. No errors.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/lib/src/models/invite*.spy.yaml \
        dart_desk_server/lib/src/generated/ \
        dart_desk_client/
git commit -m "feat(invite): add Invite/InvitePreview/InviteResult models"
```

---

## Task 2: Generate migration with hand-edited partial unique index

**Files:**
- Create: `dart_desk_server/migrations/<timestamp>-add-invites/migration.sql` (generated, then edited)
- Create: `dart_desk_server/migrations/<timestamp>-add-invites/definition.sql` (generated, then edited)

- [ ] **Step 1: Generate migration**

Run from `dart_desk_server/`: `dart run serverpod create-migration --tag add-invites`
Expected: a new directory `migrations/<timestamp>-add-invites/` with `migration.sql` and `definition.sql`.

- [ ] **Step 2: Verify migration creates the `invites` table**

Open `migration.sql`. Verify it contains `CREATE TABLE "invites"` with all the fields from Task 1 and the two declared indexes (`invites_token_idx`, `invites_client_idx`).

- [ ] **Step 3: Append the partial unique index to `migration.sql`**

Add at the end of `migration.sql`, just before the final `COMMIT;`:

```sql
--
-- Partial unique index for pending invites (one per client+email). Not
-- expressible via Serverpod indexes block — see dart_desk_be/CLAUDE.md.
--
CREATE UNIQUE INDEX "invites_client_email_pending_idx"
  ON "invites" ("clientId", "email")
  WHERE "acceptedAt" IS NULL AND "revokedAt" IS NULL;
```

(Match the column-name casing used in the rest of the file. Serverpod uses double-quoted camelCase identifiers in its migrations.)

- [ ] **Step 4: Append the partial unique to `definition.sql` (CRITICAL — CI uses this)**

Add the same `CREATE UNIQUE INDEX "invites_client_email_pending_idx" ...` statement to `definition.sql` so `withServerpod(applyMigrations: true)` bootstraps it for tests.

- [ ] **Step 5: Replay existing schema-drift fixes into the new `definition.sql`**

Per `dart_desk_be/CLAUDE.md`, every new migration's `definition.sql` MUST also contain:
1. `published_documents.data_jsonb` generated column: `data_jsonb jsonb GENERATED ALWAYS AS ((data)::jsonb) STORED`
2. The `published_docs_data_gin` GIN index on `data_jsonb`.
3. Five partial unique indexes: `clients_slug_active_idx`, `documents_project_type_slug_active_idx`, `published_docs_project_type_slug_active_idx`, `projects_slug_active_idx`, `users_client_email_active_idx`.

Copy these from the previous migration's `definition.sql` (find with `ls dart_desk_server/migrations/ | tail -2` — pick the prior migration). Use the latest committed migration as the source.

- [ ] **Step 6: Verify migration applies cleanly**

Run from `dart_desk_server/`: `dart test test/integration/ -p vm --concurrency=1 --name "smoke"` (or any single fast integration test) — this triggers `withServerpod(applyMigrations: true)` and will fail fast if the migration is malformed.

If no smoke test exists, run any one existing endpoint test, e.g. `dart test test/integration/member_endpoint_test.dart`. It must still pass.

- [ ] **Step 7: Commit**

```bash
git add dart_desk_server/migrations/
git commit -m "feat(invite): migration for invites table + partial unique index"
```

---

## Task 3: Introduce EmailSender abstraction

**Why:** the spec requires that backend tests inject a fake to capture sent emails. Today `EmailService` is concrete and accessed only via the private `_emailService` global in `server.dart`. We introduce a thin abstraction and a globally-accessible registry so endpoints can call it and tests can swap it.

**Files:**
- Create: `dart_desk_server/lib/src/services/email_sender.dart`
- Create: `dart_desk_server/test/_support/fake_email_sender.dart`
- Modify: `dart_desk_server/lib/server.dart`

- [ ] **Step 1: Write the failing fake-sender test (drives the API)**

Create `dart_desk_server/test/unit/email_sender_test.dart`:

```dart
import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:test/test.dart';

import '../_support/fake_email_sender.dart';

void main() {
  test('FakeEmailSender records sent messages', () async {
    final sender = FakeEmailSender();
    EmailSenderRegistry.set(sender);

    await EmailSenderRegistry.get()!.send(
      to: 'a@b.co',
      subject: 'hi',
      text: 'plain',
      html: '<p>hi</p>',
    );

    expect(sender.sent, hasLength(1));
    expect(sender.sent.single.to, 'a@b.co');
    expect(sender.sent.single.subject, 'hi');
  });

  test('FakeEmailSender.failNext throws once', () async {
    final sender = FakeEmailSender()..failNext('boom');
    expect(
      () => sender.send(to: 'a@b.co', subject: 's', text: 't', html: '<p>t</p>'),
      throwsA(isA<EmailSendException>()),
    );
    // Subsequent sends succeed.
    await sender.send(to: 'a@b.co', subject: 's', text: 't', html: '<p>t</p>');
    expect(sender.sent, hasLength(1));
  });
}
```

- [ ] **Step 2: Run test, verify it fails (compile error — no symbols yet)**

Run: `dart test test/unit/email_sender_test.dart`
Expected: FAIL — Target of URI doesn't exist.

- [ ] **Step 3: Write `email_sender.dart`**

Create `dart_desk_server/lib/src/services/email_sender.dart`:

```dart
import 'email_service.dart';

class EmailSendException implements Exception {
  final String message;
  EmailSendException(this.message);
  @override
  String toString() => 'EmailSendException: $message';
}

abstract class EmailSender {
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  });
}

class SmtpEmailSender implements EmailSender {
  final EmailService service;
  SmtpEmailSender(this.service);

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    try {
      await service.send(to: to, subject: subject, text: text, html: html);
    } catch (e) {
      throw EmailSendException(e.toString());
    }
  }
}

/// Process-wide registry. server.dart sets this on boot; tests substitute
/// via [set] / [reset]. Endpoints read via [get].
class EmailSenderRegistry {
  static EmailSender? _instance;
  static EmailSender? get() => _instance;
  static void set(EmailSender? sender) => _instance = sender;
  static void reset() => _instance = null;
}
```

- [ ] **Step 4: Write `fake_email_sender.dart`**

Create `dart_desk_server/test/_support/fake_email_sender.dart`:

```dart
import 'package:dart_desk_server/src/services/email_sender.dart';

class SentEmail {
  final String to, subject, text, html;
  SentEmail({required this.to, required this.subject, required this.text, required this.html});
}

class FakeEmailSender implements EmailSender {
  final List<SentEmail> sent = [];
  String? _failNextMessage;

  void failNext(String message) {
    _failNextMessage = message;
  }

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    if (_failNextMessage != null) {
      final msg = _failNextMessage!;
      _failNextMessage = null;
      throw EmailSendException(msg);
    }
    sent.add(SentEmail(to: to, subject: subject, text: text, html: html));
  }
}
```

- [ ] **Step 5: Run test, verify it passes**

Run: `dart test test/unit/email_sender_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Wire SmtpEmailSender into `server.dart`**

In `dart_desk_server/lib/server.dart`:

a) Add import at top:
```dart
import 'src/services/email_sender.dart';
```

b) Right after `_emailService = _initEmailService(pod);` (around line 46), add:
```dart
if (_emailService != null) {
  EmailSenderRegistry.set(SmtpEmailSender(_emailService!));
}
```

c) Replace the body of `_sendEmail` (lines 256–275) so it routes through the registry instead of the global. Old:

```dart
Future<void> _sendEmail({
  required Session session,
  required String to,
  required String subject,
  required String text,
  required String html,
}) async {
  final service = _emailService;
  if (service == null) {
    session.log('[EmailIdp] smtpHost not configured — skipping SMTP send', level: LogLevel.warning);
    return;
  }
  try {
    await service.send(to: to, subject: subject, text: text, html: html);
    session.log('[EmailIdp] Email sent to $to', level: LogLevel.info);
  } catch (e) {
    session.log('[EmailIdp] Failed to send email to $to: $e', level: LogLevel.error);
  }
}
```

New:

```dart
Future<void> _sendEmail({
  required Session session,
  required String to,
  required String subject,
  required String text,
  required String html,
}) async {
  final sender = EmailSenderRegistry.get();
  if (sender == null) {
    session.log('[EmailIdp] EmailSender not configured — skipping send', level: LogLevel.warning);
    return;
  }
  try {
    await sender.send(to: to, subject: subject, text: text, html: html);
    session.log('[EmailIdp] Email sent to $to', level: LogLevel.info);
  } catch (e) {
    session.log('[EmailIdp] Failed to send email to $to: $e', level: LogLevel.error);
  }
}
```

- [ ] **Step 7: Verify existing auth tests still pass**

Run: `dart test test/integration/ -p vm --concurrency=1`
Expected: PASS (no regressions).

- [ ] **Step 8: Commit**

```bash
git add dart_desk_server/lib/src/services/email_sender.dart \
        dart_desk_server/test/_support/fake_email_sender.dart \
        dart_desk_server/test/unit/email_sender_test.dart \
        dart_desk_server/lib/server.dart
git commit -m "refactor(email): introduce EmailSender abstraction with registry"
```

---

## Task 4: Add `manageBaseUrl` to configs

**Files:** Modify `dart_desk_server/config/development.yaml`, `staging.yaml`, `production.yaml`.

- [ ] **Step 1: Inspect existing config to learn the URL key pattern**

Run: `grep -n "studioDomain\|baseUrl\|Url\|domain" dart_desk_server/config/*.yaml`
Identify how other URLs/domains are declared (top-level key vs under a section). Match that pattern.

- [ ] **Step 2: Add `manageBaseUrl` to each config**

- `development.yaml`: confirm the manage app's local URL by checking `dart_desk_cloud/dart_desk_manage/web/index.html` or running the app once. Reasonable default: `http://localhost:8081`. If unknown, use `http://localhost:8081` and surface as an open question in the PR.
- `staging.yaml`: `https://manage.staging.dartdesk.dev`
- `production.yaml`: `https://manage.dartdesk.dev`

- [ ] **Step 3: Read the value at runtime**

The configs are accessed via `pod.getPassword(...)` for secrets and via the Serverpod config object for non-secret values. Inspect how `studioDomain` is read in `server.dart` line 75:

```dart
studioDomain: pod.getPassword('studioDomain') ?? 'app.dartdesk.dev',
```

Add a top-level helper in `server.dart` (near `_initEmailService`) to expose `manageBaseUrl`:

```dart
String _manageBaseUrl(Serverpod pod) =>
    pod.getPassword('manageBaseUrl') ?? 'https://manage.dartdesk.dev';
```

And store it in a top-level `String? _manageBaseUrl;`-style variable, OR expose via a tiny registry like the EmailSender. Simplest: store it on `EmailSenderRegistry`-style but for config — or add a second registry. Cleanest: a single `AppConfigRegistry`. Implementation:

In `email_sender.dart`, add at the bottom (rename file? no — keep colocated for now or split):

Actually create a new file `dart_desk_server/lib/src/services/app_config.dart`:

```dart
class AppConfig {
  final String manageBaseUrl;
  const AppConfig({required this.manageBaseUrl});
}

class AppConfigRegistry {
  static AppConfig? _instance;
  static AppConfig? get() => _instance;
  static void set(AppConfig? config) => _instance = config;
  static void reset() => _instance = null;
}
```

In `server.dart`, after `EmailSenderRegistry.set(...)`:

```dart
AppConfigRegistry.set(AppConfig(
  manageBaseUrl: pod.getPassword('manageBaseUrl') ?? 'https://manage.dartdesk.dev',
));
```

(Add `import 'src/services/app_config.dart';` to server.dart.)

NOTE: Serverpod stores non-secret config in `config/<runmode>.yaml` and secrets in `config/passwords.yaml`. `manageBaseUrl` is non-secret. Inspect `pod.getPassword` vs `pod.getConfig` usage in this project — if `getPassword` is being used for non-secrets too (see `studioDomain` line 75 — that pattern is non-secret-via-getPassword), follow suit. If the project uses a separate non-secret config accessor, use that instead.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/config/ \
        dart_desk_server/lib/src/services/app_config.dart \
        dart_desk_server/lib/server.dart
git commit -m "feat(invite): add manageBaseUrl config + AppConfigRegistry"
```

---

## Task 5: Build `auth_user_resolver` helper

**Why:** `acceptInvite` and `previewInvite.hasExistingAccount` need to look up an existing AuthUser by email across both Email and Google IDPs. This logic exists implicitly in `EmailIdpEndpoint` (which auto-links email registrations to existing Google accounts) but isn't reusable. Extract a helper.

**Files:**
- Create: `dart_desk_server/lib/src/auth/auth_user_resolver.dart`

- [ ] **Step 1: Inspect the existing IDP linkage code**

Read `dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart` lines 70–end. Find how it queries for a Google AuthUser by email. Likely uses `AuthServices.instance.something` or a direct `EmailAccount.db.findFirstRow` / `IdpProfile` lookup.

Run: `grep -rn "AuthUser\|authUserId" dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart | head -30`

Identify the actual query pattern (the spec author hasn't pinned it because it depends on `serverpod_auth_idp` internals). The likely path: `AuthServices.instance.authUsers.findByEmail(...)` or query `IdpProfile.db` joined to `AuthUser.db` filtered by email.

- [ ] **Step 2: Write the helper**

Create `dart_desk_server/lib/src/auth/auth_user_resolver.dart`. Pseudocode (adapt to actual API discovered in Step 1):

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Looks up an AuthUser by email across all configured IDPs.
/// Returns null if no AuthUser exists for that email.
Future<UuidValue?> findAuthUserIdByEmail(
  Session session,
  String email, {
  Transaction? transaction,
}) async {
  // TODO during implementation: replace with the actual AuthServices /
  // EmailAccount / IdpProfile lookup. Mirror what EmailIdpEndpoint uses
  // for its Google-account auto-link logic.
  //
  // Acceptance: a user who registered ONLY via Google with email e@x.co
  // must be found here (returning that AuthUser's id). A user who never
  // registered must return null.
}
```

**During implementation:** the engineer must replace the TODO with the real query. If the auth_idp API doesn't expose an email-lookup helper publicly, the helper should query the underlying `EmailAccount` table (for email-IDP users) AND `IdpProfile` rows (for Google users) and unify.

- [ ] **Step 3: Add a unit-style integration test**

Create `dart_desk_server/test/integration/auth_user_resolver_test.dart`:

```dart
import 'package:dart_desk_server/src/auth/auth_user_resolver.dart';
import 'package:test/test.dart';

import 'serverpod_test_tools.dart'; // existing harness

void main() {
  withServerpod((sessionBuilder, endpoints) {
    test('returns null when no AuthUser exists for email', () async {
      final session = sessionBuilder.build();
      final result = await findAuthUserIdByEmail(session, 'nobody@example.com');
      expect(result, isNull);
    });

    test('returns AuthUser id after email registration', () async {
      // 1. Register a user via the email IDP using the existing test
      //    harness (whatever pattern other tests use — see
      //    test/integration for examples).
      // 2. Assert findAuthUserIdByEmail returns that user's id.
    });

    test('returns AuthUser id for Google-only user', () async {
      // 1. Seed an AuthUser + IdpProfile (google) directly via the DB
      //    using the harness (no real OAuth roundtrip).
      // 2. Assert findAuthUserIdByEmail returns that user's id.
    });
  });
}
```

- [ ] **Step 4: Run test, verify it fails first then passes**

Run: `dart test test/integration/auth_user_resolver_test.dart`
First run: 1 passing (null case), 2 failing (the TODO ones). Implement the lookup. Re-run until all 3 pass.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/lib/src/auth/auth_user_resolver.dart \
        dart_desk_server/test/integration/auth_user_resolver_test.dart
git commit -m "feat(invite): findAuthUserIdByEmail helper"
```

---

## Task 6: Build `sendInviteEmail` helper

**Files:**
- Create: `dart_desk_server/lib/src/services/invite_email.dart`

- [ ] **Step 1: Write `invite_email.dart`**

```dart
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'app_config.dart';
import 'email_sender.dart';

/// Sends the invite email. On SMTP failure throws [EmailSendException]
/// (caller decides whether to swallow). Returns silently on success.
Future<void> sendInviteEmail(
  Session session, {
  required Invite invite,
  required String clientName,
  required String inviterName,
  required String inviterEmail,
}) async {
  final sender = EmailSenderRegistry.get();
  if (sender == null) {
    throw EmailSendException('EmailSender not configured');
  }
  final baseUrl = AppConfigRegistry.get()?.manageBaseUrl
      ?? 'https://manage.dartdesk.dev';
  final acceptUrl = '$baseUrl/accept-invite?token=${invite.token}';
  final roleName = invite.role.name;
  final expires = invite.expiresAt.toUtc().toIso8601String();

  final subject = '$inviterName invited you to $clientName on Dart Desk';
  final text = '''
You've been invited to $clientName.

$inviterName ($inviterEmail) invited you to join the $clientName workspace
on Dart Desk as a $roleName.

Accept the invite: $acceptUrl

This link expires on $expires (UTC). If you didn't expect this email, you
can ignore it.
''';
  final html = '''
<p>You've been invited to <strong>$clientName</strong>.</p>
<p>$inviterName (<a href="mailto:$inviterEmail">$inviterEmail</a>) invited you
to join the <strong>$clientName</strong> workspace on Dart Desk as a
<strong>$roleName</strong>.</p>
<p><a href="$acceptUrl">Accept the invite</a></p>
<p style="color:#666;font-size:12px">This link expires on $expires (UTC).
If you didn't expect this email, you can ignore it.</p>
''';

  await sender.send(to: invite.email, subject: subject, text: text, html: html);
}
```

- [ ] **Step 2: Write a unit test**

Create `dart_desk_server/test/unit/invite_email_test.dart`:

```dart
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/services/app_config.dart';
import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:dart_desk_server/src/services/invite_email.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../_support/fake_email_sender.dart';

void main() {
  setUp(() {
    AppConfigRegistry.set(const AppConfig(manageBaseUrl: 'https://example.test'));
  });
  tearDown(() {
    AppConfigRegistry.reset();
    EmailSenderRegistry.reset();
  });

  test('sendInviteEmail builds subject + accept URL + body', () async {
    final fake = FakeEmailSender();
    EmailSenderRegistry.set(fake);

    final invite = Invite(
      clientId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      email: 'invitee@example.com',
      role: ClientRole.member,
      token: 'tok123',
      invitedByUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
      expiresAt: DateTime.utc(2026, 6, 1),
    );

    // session can be null/stubbed if the helper doesn't use it heavily.
    // Use the project's existing test session helper if needed.
    await sendInviteEmail(
      _StubSession(),
      invite: invite,
      clientName: 'Acme',
      inviterName: 'Alice',
      inviterEmail: 'alice@acme.test',
    );

    expect(fake.sent, hasLength(1));
    expect(fake.sent.single.to, 'invitee@example.com');
    expect(fake.sent.single.subject, contains('Acme'));
    expect(fake.sent.single.subject, contains('Alice'));
    expect(fake.sent.single.text, contains('https://example.test/accept-invite?token=tok123'));
  });

  test('throws when EmailSender not configured', () async {
    EmailSenderRegistry.reset();
    final invite = Invite(
      clientId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      email: 'a@b.co', role: ClientRole.member, token: 't',
      invitedByUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
      expiresAt: DateTime.utc(2026, 6, 1),
    );
    expect(
      () => sendInviteEmail(_StubSession(), invite: invite,
          clientName: 'c', inviterName: 'i', inviterEmail: 'i@b.co'),
      throwsA(isA<EmailSendException>()),
    );
  });
}

class _StubSession implements Session {
  // If sendInviteEmail does not actually use Session methods, an empty stub
  // is fine. If `dart analyze` complains about missing implementations, just
  // extend a real Session via the project's existing test harness instead
  // (the integration tests use sessionBuilder.build()).
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
```

- [ ] **Step 3: Run test, verify pass**

Run: `dart test test/unit/invite_email_test.dart`
Expected: PASS (2 tests). If `_StubSession` fails to compile because Session has too many abstract members, replace it with the project's `sessionBuilder.build()` from the integration harness.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/lib/src/services/invite_email.dart \
        dart_desk_server/test/unit/invite_email_test.dart
git commit -m "feat(invite): sendInviteEmail helper"
```

---

## Task 7: Update `MemberEndpoint` — replace `inviteMember`, add list/resend/revoke

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/member_endpoint.dart`
- Create: `dart_desk_server/test/integration/member_endpoint_invite_test.dart`

- [ ] **Step 1: Write the failing tests first**

Create `dart_desk_server/test/integration/member_endpoint_invite_test.dart`. The harness pattern follows existing `member_endpoint_test.dart` (read it first to learn the seeding pattern: how to create a client, an admin caller user, and authenticate). Test cases:

```dart
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/services/email_sender.dart';
import 'package:test/test.dart';

import '../_support/fake_email_sender.dart';
import 'serverpod_test_tools.dart'; // existing test entry

void main() {
  withServerpod((sessionBuilder, endpoints) {
    late FakeEmailSender fakeMail;

    setUp(() {
      fakeMail = FakeEmailSender();
      EmailSenderRegistry.set(fakeMail);
    });
    tearDown(() => EmailSenderRegistry.reset());

    group('MemberEndpoint.inviteMember', () {
      test('admin can invite — creates pending row + sends email', () async {
        // Seed a Client + admin User. Reuse helper from existing tests if
        // available (e.g. seedClientWithAdmin). Authenticate as admin.
        final ctx = await seedAdminContext(sessionBuilder);

        final result = await endpoints.member.inviteMember(
          ctx.session,
          clientId: ctx.clientId,
          email: 'newmember@example.com',
          role: ClientRole.member,
        );

        expect(result.emailSent, isTrue);
        expect(result.invite.clientId, ctx.clientId);
        expect(result.invite.email, 'newmember@example.com');
        expect(result.invite.role, ClientRole.member);
        expect(result.invite.acceptedAt, isNull);
        expect(result.invite.revokedAt, isNull);
        expect(result.invite.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);

        expect(fakeMail.sent, hasLength(1));
        expect(fakeMail.sent.single.to, 'newmember@example.com');
        expect(fakeMail.sent.single.text, contains(result.invite.token));
      });

      test('non-admin → 403', () async {
        final ctx = await seedMemberContext(sessionBuilder);
        await expectLater(
          endpoints.member.inviteMember(ctx.session,
              clientId: ctx.clientId, email: 'x@y.co', role: ClientRole.member),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('inviting role=owner → 400', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        await expectLater(
          endpoints.member.inviteMember(ctx.session,
              clientId: ctx.clientId, email: 'x@y.co', role: ClientRole.owner),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('email already an active member → 409 EMAIL_ALREADY_MEMBER', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        // Insert an existing active User with email collision.
        await User.db.insertRow(ctx.session, User(
          clientId: ctx.clientId, email: 'dup@y.co',
          role: ClientRole.member, isActive: true,
        ));
        await expectLater(
          endpoints.member.inviteMember(ctx.session,
              clientId: ctx.clientId, email: 'dup@y.co', role: ClientRole.member),
          throwsA(isA<ApiException>()
              .having((e) => e.code, 'code', 409)
              .having((e) => e.errorCode, 'errorCode', 'EMAIL_ALREADY_MEMBER')),
        );
      });

      test('email has pending invite → 409 INVITE_ALREADY_PENDING', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'twice@y.co', role: ClientRole.member);
        await expectLater(
          endpoints.member.inviteMember(ctx.session,
              clientId: ctx.clientId, email: 'twice@y.co', role: ClientRole.member),
          throwsA(isA<ApiException>()
              .having((e) => e.errorCode, 'errorCode', 'INVITE_ALREADY_PENDING')),
        );
      });

      test('email send failure → emailSent=false but invite persisted', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        fakeMail.failNext('smtp down');
        final result = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'fail@y.co', role: ClientRole.member);
        expect(result.emailSent, isFalse);
        final found = await Invite.db.findById(ctx.session, result.invite.id);
        expect(found, isNotNull);
      });
    });

    group('MemberEndpoint.listPendingInvites', () {
      test('returns only non-accepted/non-revoked/non-expired', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final live = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'live@y.co', role: ClientRole.member);
        final revoked = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'rev@y.co', role: ClientRole.member);
        await endpoints.member.revokeInvite(ctx.session, inviteId: revoked.invite.id);

        // Manually expire one
        final expired = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'exp@y.co', role: ClientRole.member);
        final expiredRow = (await Invite.db.findById(ctx.session, expired.invite.id))!;
        expiredRow.expiresAt = DateTime.now().toUtc().subtract(const Duration(days: 1));
        await Invite.db.updateRow(ctx.session, expiredRow);

        final list = await endpoints.member.listPendingInvites(
            ctx.session, clientId: ctx.clientId);
        expect(list.map((i) => i.email), contains('live@y.co'));
        expect(list.map((i) => i.email), isNot(contains('rev@y.co')));
        expect(list.map((i) => i.email), isNot(contains('exp@y.co')));
      });
    });

    group('MemberEndpoint.resendInvite', () {
      test('bumps expiresAt and re-sends email', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final created = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'r@y.co', role: ClientRole.member);
        final originalExpires = created.invite.expiresAt;
        fakeMail.sent.clear();

        // Backdate to ensure bump is observable.
        final row = (await Invite.db.findById(ctx.session, created.invite.id))!;
        row.expiresAt = DateTime.now().toUtc().add(const Duration(days: 1));
        await Invite.db.updateRow(ctx.session, row);

        final resent = await endpoints.member.resendInvite(
            ctx.session, inviteId: created.invite.id);
        expect(resent.emailSent, isTrue);
        expect(resent.invite.expiresAt.isAfter(row.expiresAt), isTrue);
        expect(fakeMail.sent, hasLength(1));
      });

      test('refuses to resend revoked invite', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final created = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'r2@y.co', role: ClientRole.member);
        await endpoints.member.revokeInvite(ctx.session, inviteId: created.invite.id);
        await expectLater(
          endpoints.member.resendInvite(ctx.session, inviteId: created.invite.id),
          throwsA(isA<ApiException>()
              .having((e) => e.errorCode, 'errorCode', 'INVITE_REVOKED')),
        );
      });
    });

    group('MemberEndpoint.revokeInvite', () {
      test('sets revokedAt', () async {
        final ctx = await seedAdminContext(sessionBuilder);
        final created = await endpoints.member.inviteMember(ctx.session,
            clientId: ctx.clientId, email: 'rv@y.co', role: ClientRole.member);
        await endpoints.member.revokeInvite(ctx.session, inviteId: created.invite.id);
        final row = (await Invite.db.findById(ctx.session, created.invite.id))!;
        expect(row.revokedAt, isNotNull);
      });
    });
  });
}
```

(`seedAdminContext` and `seedMemberContext`: the engineer should look at existing `member_endpoint_test.dart` for how the project seeds clients + auth. If no shared helper exists, factor one out into `test/_support/seed.dart` as part of this task.)

- [ ] **Step 2: Run tests, expect failures**

Run: `dart test test/integration/member_endpoint_invite_test.dart`
Expected: FAIL — `Invite` tests can't run because `inviteMember` still has its old shape returning `User`. (Compile errors are OK at this point — they'll go away as we update the endpoint.)

- [ ] **Step 3: Update `member_endpoint.dart`**

Replace the existing `inviteMember` and add three new methods. Full new file body:

```dart
import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';
import '../services/invite_email.dart';
import '../services/email_sender.dart';

class MemberEndpoint extends Endpoint {
  Future<User> _requireClientAdmin(Session session, UuidValue clientId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }
    final caller = await resolveUser(session, clientId: clientId);
    if (caller.role != ClientRole.admin && caller.role != ClientRole.owner) {
      throw ApiException(message: 'Admin access required', code: 403);
    }
    return caller;
  }

  Future<User> _requireClientMember(Session session, UuidValue clientId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }
    return resolveUser(session, clientId: clientId);
  }

  Future<List<User>> listMembers(Session session, {required UuidValue clientId}) async {
    await _requireClientMember(session, clientId);
    return User.db.find(
      session,
      where: (t) => t.clientId.equals(clientId)
          & t.isActive.equals(true)
          & t.deletedAt.equals(null),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<InviteResult> inviteMember(
    Session session, {
    required UuidValue clientId,
    required String email,
    required ClientRole role,
  }) async {
    final caller = await _requireClientAdmin(session, clientId);

    if (role == ClientRole.owner) {
      throw ApiException(message: 'Cannot invite as owner', code: 400);
    }

    final activeMember = await User.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId)
          & t.email.equals(email)
          & t.isActive.equals(true)
          & t.deletedAt.equals(null),
    );
    if (activeMember != null) {
      throw ApiException(
        message: 'A member with this email already exists in this workspace',
        code: 409,
        errorCode: 'EMAIL_ALREADY_MEMBER',
      );
    }

    final pending = await Invite.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId)
          & t.email.equals(email)
          & t.acceptedAt.equals(null)
          & t.revokedAt.equals(null),
    );
    if (pending != null) {
      throw ApiException(
        message: 'An invite is already pending for this email',
        code: 409,
        errorCode: 'INVITE_ALREADY_PENDING',
      );
    }

    final token = _generateToken();
    final now = DateTime.now().toUtc();
    final invite = await Invite.db.insertRow(session, Invite(
      clientId: clientId,
      email: email,
      role: role,
      token: token,
      invitedByUserId: caller.id,
      expiresAt: now.add(const Duration(days: 14)),
      createdAt: now,
      updatedAt: now,
    ));
    session.log('Invite created id=${invite.id} clientId=$clientId email=$email role=$role',
        level: LogLevel.info);

    final emailSent = await _sendInvite(session, invite, caller);
    return InviteResult(invite: invite, emailSent: emailSent);
  }

  Future<List<Invite>> listPendingInvites(
    Session session, {
    required UuidValue clientId,
  }) async {
    await _requireClientAdmin(session, clientId);
    final now = DateTime.now().toUtc();
    return Invite.db.find(
      session,
      where: (t) => t.clientId.equals(clientId)
          & t.acceptedAt.equals(null)
          & t.revokedAt.equals(null)
          & (t.expiresAt > now),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<InviteResult> resendInvite(
    Session session, {
    required UuidValue inviteId,
  }) async {
    final invite = await Invite.db.findById(session, inviteId);
    if (invite == null) {
      throw ApiException(message: 'Invite not found', code: 404,
          errorCode: 'INVITE_NOT_FOUND');
    }
    final caller = await _requireClientAdmin(session, invite.clientId);
    if (invite.acceptedAt != null) {
      throw ApiException(message: 'Invite already accepted', code: 409,
          errorCode: 'INVITE_ALREADY_ACCEPTED');
    }
    if (invite.revokedAt != null) {
      throw ApiException(message: 'Invite revoked', code: 409,
          errorCode: 'INVITE_REVOKED');
    }
    final now = DateTime.now().toUtc();
    invite.expiresAt = now.add(const Duration(days: 14));
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);

    final emailSent = await _sendInvite(session, invite, caller);
    return InviteResult(invite: invite, emailSent: emailSent);
  }

  Future<void> revokeInvite(
    Session session, {
    required UuidValue inviteId,
  }) async {
    final invite = await Invite.db.findById(session, inviteId);
    if (invite == null) {
      throw ApiException(message: 'Invite not found', code: 404,
          errorCode: 'INVITE_NOT_FOUND');
    }
    await _requireClientAdmin(session, invite.clientId);
    if (invite.acceptedAt != null) {
      throw ApiException(message: 'Cannot revoke accepted invite', code: 409,
          errorCode: 'INVITE_ALREADY_ACCEPTED');
    }
    final now = DateTime.now().toUtc();
    invite.revokedAt = now;
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);
    session.log('Invite revoked id=$inviteId', level: LogLevel.info);
  }

  Future<User> updateMemberRole(
    Session session, {
    required UuidValue clientId,
    required UuidValue userId,
    required ClientRole role,
  }) async {
    // ... unchanged from current implementation; keep as-is
    throw UnimplementedError('keep existing body');
  }

  Future<void> removeMember(
    Session session, {
    required UuidValue clientId,
    required UuidValue userId,
  }) async {
    // ... unchanged; keep as-is
    throw UnimplementedError('keep existing body');
  }

  /// Returns true if the email was sent successfully; false if the SMTP
  /// path threw (logged at error level). Never rethrows — invite persistence
  /// is independent of email delivery.
  Future<bool> _sendInvite(Session session, Invite invite, User inviter) async {
    final clientRow = await CmsClient.db.findById(session, invite.clientId);
    final clientName = clientRow?.name ?? 'your workspace';
    final inviterName = inviter.name ?? inviter.email;
    try {
      await sendInviteEmail(
        session,
        invite: invite,
        clientName: clientName,
        inviterName: inviterName,
        inviterEmail: inviter.email,
      );
      return true;
    } catch (e) {
      session.log('Invite email failed id=${invite.id} email=${invite.email}: $e',
          level: LogLevel.error);
      return false;
    }
  }

  String _generateToken() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
```

**Important:** keep the existing `updateMemberRole` and `removeMember` bodies intact — the snippet above shows `throw UnimplementedError` only as a placeholder; copy the real bodies from the current file. Do NOT touch them.

**Note on `CmsClient`:** verify the actual class name for the workspace/client model (`CmsClient` per the model file `cms_client.spy.yaml`). If the generated class is named differently, adjust.

- [ ] **Step 4: Run tests, iterate until green**

Run: `dart test test/integration/member_endpoint_invite_test.dart`
Expected: PASS (all groups). Fix any seed-helper issues uncovered.

- [ ] **Step 5: Run the full integration suite for regressions**

Run: `dart test test/integration/ -p vm --concurrency=1`
Expected: PASS — including the existing `member_endpoint_test.dart` (note: that file may reference the old `inviteMember` returning `User`; if so, update those tests to expect `InviteResult`).

- [ ] **Step 6: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/member_endpoint.dart \
        dart_desk_server/test/integration/member_endpoint_invite_test.dart \
        dart_desk_server/test/_support/ \
        dart_desk_server/lib/src/generated/ \
        dart_desk_client/
git commit -m "feat(invite): MemberEndpoint emits Invite rows + email"
```

---

## Task 8: Add `InviteEndpoint` (public — preview + accept)

**Files:**
- Create: `dart_desk_server/lib/src/endpoints/invite_endpoint.dart`
- Create: `dart_desk_server/test/integration/invite_endpoint_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/integration/invite_endpoint_test.dart
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'serverpod_test_tools.dart';

void main() {
  withServerpod((sessionBuilder, endpoints) {
    group('previewInvite', () {
      test('valid invite → returns details', () async { /* … */ });
      test('expired → INVITE_EXPIRED', () async { /* … */ });
      test('revoked → INVITE_REVOKED', () async { /* … */ });
      test('accepted → INVITE_ALREADY_ACCEPTED', () async { /* … */ });
      test('bad token → INVITE_NOT_FOUND', () async { /* … */ });
      test('hasExistingAccount=true when AuthUser exists for email', () async { /* … */ });
    });

    group('acceptInvite', () {
      test('new user + password → AuthUser+EmailAccount+User created', () async { /* … */ });
      test('existing email AuthUser, signed in as same → User created, password ignored', () async { /* … */ });
      test('existing AuthUser, signed out → SIGN_IN_REQUIRED', () async { /* … */ });
      test('existing AuthUser, signed in as different → SIGN_IN_REQUIRED', () async { /* … */ });
      test('no existing AuthUser & no password → PASSWORD_REQUIRED', () async { /* … */ });
      test('expired → INVITE_EXPIRED', () async { /* … */ });
      test('revoked → INVITE_REVOKED', () async { /* … */ });
      test('already-accepted → INVITE_ALREADY_ACCEPTED', () async { /* … */ });
      test('on success: invite.acceptedAt set, User row created with right clientId/role', () async { /* … */ });
    });
  });
}
```

Fill in the bodies using the same seeding helpers from Task 7 plus a helper `seedInvite(...)` that calls `MemberEndpoint.inviteMember` after admin auth.

- [ ] **Step 2: Run tests, expect failures (compile error — no InviteEndpoint yet)**

Run: `dart test test/integration/invite_endpoint_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write `invite_endpoint.dart`**

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/auth_user_resolver.dart';
import '../generated/protocol.dart';

class InviteEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<InvitePreview> previewInvite(
    Session session, {
    required String token,
  }) async {
    final invite = await _loadValidatable(session, token);
    _checkLifecycle(invite);

    final clientRow = await CmsClient.db.findById(session, invite.clientId);
    final inviter = await User.db.findById(session, invite.invitedByUserId);
    final existingAuthUserId = await findAuthUserIdByEmail(session, invite.email);

    return InvitePreview(
      clientId: invite.clientId,
      clientName: clientRow?.name ?? 'this workspace',
      email: invite.email,
      role: invite.role,
      inviterName: inviter?.name ?? inviter?.email ?? 'Someone',
      inviterEmail: inviter?.email ?? '',
      expiresAt: invite.expiresAt,
      hasExistingAccount: existingAuthUserId != null,
    );
  }

  Future<AuthSuccess> acceptInvite(
    Session session, {
    required String token,
    String? password,
  }) async {
    final invite = await _loadValidatable(session, token);
    _checkLifecycle(invite);

    final existingAuthUserId = await findAuthUserIdByEmail(session, invite.email);
    final auth = session.authenticated;

    UuidValue authUserId;
    if (existingAuthUserId != null) {
      // Caller must be that AuthUser.
      if (auth == null || auth.authUserId != existingAuthUserId) {
        throw ApiException(
          message: 'An account already exists for this email — please sign in to accept.',
          code: 409,
          errorCode: 'SIGN_IN_REQUIRED',
        );
      }
      authUserId = existingAuthUserId;
    } else {
      // No AuthUser yet — must create. Password required.
      if (password == null || password.isEmpty) {
        throw ApiException(
          message: 'Password required to create account',
          code: 400,
          errorCode: 'PASSWORD_REQUIRED',
        );
      }
      // Create AuthUser + EmailAccount via auth_idp APIs. Exact call depends
      // on the package version. Adapt during implementation; the goal:
      //   1) Create an AuthUser with email = invite.email
      //   2) Set the password
      //   3) Mark email verified (this is an admin invite — implicitly
      //      verified)
      authUserId = await _createAuthUserWithPassword(session, invite.email, password);
    }

    // Create User row (workspace membership).
    final now = DateTime.now().toUtc();
    final user = await User.db.insertRow(session, User(
      clientId: invite.clientId,
      email: invite.email,
      role: invite.role,
      isActive: true,
      serverpodUserId: authUserId.toString(),
      createdAt: now,
      updatedAt: now,
    ));

    // Mark invite accepted.
    invite.acceptedAt = now;
    invite.acceptedUserId = user.id;
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);

    session.log('Invite accepted id=${invite.id} userId=${user.id}', level: LogLevel.info);

    // Issue token.
    return session.db.transaction((tx) async {
      final authUser = await AuthServices.instance.authUsers.get(
        session, authUserId: authUserId, transaction: tx,
      );
      return AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: authUserId,
        method: 'email',
        scopes: authUser.scopes,
        transaction: tx,
      );
    });
  }

  Future<Invite> _loadValidatable(Session session, String token) async {
    final invite = await Invite.db.findFirstRow(
      session, where: (t) => t.token.equals(token),
    );
    if (invite == null) {
      throw ApiException(message: 'Invite not found', code: 404,
          errorCode: 'INVITE_NOT_FOUND');
    }
    return invite;
  }

  void _checkLifecycle(Invite invite) {
    if (invite.acceptedAt != null) {
      throw ApiException(message: 'Invite already accepted', code: 409,
          errorCode: 'INVITE_ALREADY_ACCEPTED');
    }
    if (invite.revokedAt != null) {
      throw ApiException(message: 'Invite revoked', code: 409,
          errorCode: 'INVITE_REVOKED');
    }
    if (invite.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw ApiException(message: 'Invite expired', code: 410,
          errorCode: 'INVITE_EXPIRED');
    }
  }

  Future<UuidValue> _createAuthUserWithPassword(
    Session session, String email, String password,
  ) async {
    // TODO during impl: replace with the real auth_idp API calls. Look at
    // EmailIdpEndpoint.finishRegistration for the canonical pattern.
    // Return the new AuthUser's id.
    throw UnimplementedError('Wire to AuthServices in implementation');
  }
}
```

**Implementation sub-step:** replace the `_createAuthUserWithPassword` TODO with the real call sequence. Read `lib/src/endpoints/email_idp_endpoint.dart` and the `serverpod_auth_idp_server` package (`pub get`, then `cat .dart_tool/pub-cache/.../serverpod_auth_idp_server/lib/...`) to learn the API. The flow needs to:
1. Create an `AuthUser` (with default scopes).
2. Create an `EmailAccount` (with hashed password) linked to that AuthUser.
3. Mark the email as verified (since this is an invite — no separate verification needed).

If the package API doesn't expose a single helper, do the steps as separate `AuthServices.instance.authUsers.create(...)` + `EmailAccountSecrets.set(...)` calls, mirroring whatever `finishRegistration` does internally.

- [ ] **Step 4: Register the endpoint with Serverpod**

Run from `dart_desk_server/`: `dart run serverpod generate`
This regenerates `lib/src/generated/endpoints.dart` to include `InviteEndpoint` and updates the client. Commit the regen output along with the endpoint file.

- [ ] **Step 5: Run tests, iterate**

Run: `dart test test/integration/invite_endpoint_test.dart`
Expected: PASS (all groups).

- [ ] **Step 6: Run full suite**

Run: `dart test test/integration/ -p vm --concurrency=1`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/invite_endpoint.dart \
        dart_desk_server/test/integration/invite_endpoint_test.dart \
        dart_desk_server/lib/src/generated/ \
        dart_desk_client/
git commit -m "feat(invite): public InviteEndpoint with preview + accept"
```

---

## Task 9: PR

- [ ] **Step 1: Push branch**
- [ ] **Step 2: Open PR** with title `feat(invite): email-link invite flow` and a short summary linking to the spec path. Note in the PR description that the dart_desk_manage frontend lands in a follow-up PR (this backend PR is the prerequisite — the new client code is committed under `dart_desk_client/`).
- [ ] **Step 3: Confirm CI passes** before requesting review.

---

## Self-review (filled in)

- **Spec coverage:**
  - § 4 model → Task 1, 2 ✓
  - § 5 endpoints → Task 7 (Member changes), Task 8 (InviteEndpoint) ✓
  - § 6 email delivery → Task 3 (sender), Task 4 (config), Task 6 (helper) ✓
  - § 8 backend tests → Tasks 5, 6, 7, 8 ✓
  - § 9 migration → Task 2 ✓
  - § 10 rollout: this plan covers BE only; FE is a separate plan.
- **Placeholders:** two intentional TODOs, both flagged with explicit guidance:
  1. `findAuthUserIdByEmail` body (Task 5 Step 2) — engineer must consult auth_idp API.
  2. `_createAuthUserWithPassword` body (Task 8 Step 3) — engineer must mirror `EmailIdpEndpoint.finishRegistration`.
  These are unavoidable: the precise auth_idp API can't be pinned without reading the package source. The plan tells the engineer exactly which existing file to mirror.
- **Type consistency:** `InviteResult { Invite invite; bool emailSent }` used consistently in Tasks 1, 6, 7. Error codes match across endpoint, tests, and design spec.
