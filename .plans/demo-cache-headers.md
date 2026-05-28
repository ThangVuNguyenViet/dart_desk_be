# Plan: Cache-Control + ETag headers in StudioRoute

## Goal

Make responses from `StudioRoute` cacheable so the upcoming CloudFront
distribution in front of `*.app.dartdesk.dev` (see
`dart_desk_cloud/.plans/demo-cloudfront.md`) actually caches them. Today
`StudioRoute` emits no `Cache-Control` and no `ETag`, so CloudFront's default
cache policy gives every asset `min_ttl=0/default_ttl=0`. The result is that
even with a CDN in front, every viewer request would still proxy through the
Dart server.

This plan does **not** implement origin-side gzip or an in-process bundle
LRU. CloudFront does compression and caching at the edge; we revisit
origin-side optimization only if CloudFront alone proves insufficient.

Symptom motivating this work: `curl -o /dev/null` of
`https://dart-desk-demo.app.dartdesk.dev/main.dart.js` (4.59 MB) currently
sustains ~35 KB/s and times out at 120 s with the body still incomplete.
After this plan + the cloud plan, browsers should hit CloudFront edge cache
on every reload and the Dart server should serve each asset at most once
per edge POP per cache lifetime.

## Files to change

1. `dart_desk_server/lib/src/web/routes/studio_route.dart` — emit cache
   headers and an `ETag`, handle conditional `If-None-Match`, drop a
   redundant byte copy.
2. `dart_desk_server/test/integration/studio_route_test.dart` — extend
   existing tests; add new ones for headers and 304s.

No changes to `configure_web_routes.dart`, no new files.

## Background — what to read before editing

- Current handler: `dart_desk_server/lib/src/web/routes/studio_route.dart`.
  Note `_bodyResponse` at the bottom returns `Response(200, body:
  Body.fromData(Uint8List.fromList(body), mimeType: contentType))` — the
  `Uint8List.fromList` copy is unnecessary when `body` is already a
  `Uint8List` (it always is, see `_readBundleAsset`).
- Existing test scaffolding:
  `dart_desk_server/test/integration/studio_route_test.dart` already builds
  Relic `Request` objects via `RequestInternal.create`, seeds a bundle into
  `public` storage with `session.storage.storeFile`, and reads response
  bytes via `response.body.read().expand((b) => b).toList()`. Reuse this
  pattern; do not invent new helpers.
- Active deployments are immutable: `Deployment` rows transition from
  `uploading → active`, and a previously-active row is demoted to
  `inactive` rather than mutated. Therefore the tuple
  `(deployment.id, relPath)` uniquely identifies a byte payload — safe to
  use as the basis for an `ETag`. See
  `dart_desk_server/lib/src/web/routes/deployment_upload_route.dart` lines
  140–240 for the lifecycle, particularly the comment at line 147.
- Relic API to use (verified from `relic_core-1.2.0` source — do NOT
  re-research this):
  - `Response(statusCode, body: Body, headers: Headers)` — positional
    status, named `body` and `headers`. `headers` defaults to
    `Headers.empty()` when omitted.
  - `Response.notModified({Headers? headers})` — built-in 304
    constructor. Use this for the conditional response.
  - `Headers.build((MutableHeaders h) { ... })` — builder. Set raw
    string headers via `h['cache-control'] = ['public, max-age=...'];`
    `h['etag'] = ['"abc123"'];` Values are `Iterable<String>`; an empty
    list omits the header.
  - Read the inbound `If-None-Match` via `request.headers['if-none-match']`
    (returns `Iterable<String>?`). Don't use the typed
    `request.headers.ifNoneMatch` accessor — it parses an `ETagHeader`
    list which is more API surface than we need; raw is simpler.
  - `Body.fromData(Uint8List, mimeType: MimeType)` for byte responses;
    `Body.empty()` for the 304.

## Behavior changes

Headers to emit on every successful 200 response:

| Path pattern | Cache-Control |
|---|---|
| `index.html` (and any extensionless path that falls back to it) | `public, max-age=0, must-revalidate` |
| Any path matching `r'\.[^./]*[0-9a-f]{8,}[^./]*\.(js\|css\|woff2\|wasm\|json)$'` (Flutter content-hashed assets) | `public, max-age=31536000, immutable` |
| Everything else (`.js`, `.css`, `.png`, `.svg`, `.woff2`, `.wasm`, `.json`, octet-stream) | `public, max-age=300` |

Notes on the hash regex: Flutter's `flutter build web` emits files like
`main.dart.js_1.part.js`, `flutter_service_worker.js?v=<hash>`,
`assets/AssetManifest.bin.json`, and font files
`fonts/MaterialIcons-Regular.otf`. We're not trying to be exhaustive — the
regex above keys on "name contains an 8+ hex run". Anything else falls into
the 5-minute default. Do **not** mark `flutter_service_worker.js` as
immutable; it is rewritten on every build and ships under a stable name.
Special-case it explicitly: if the basename is exactly
`flutter_service_worker.js`, use `public, max-age=0, must-revalidate`.

### ETag

For every 200, emit `ETag: "<deploymentId>-<relPath-hash>"` where
`<relPath-hash>` is the lowercase hex of `sha1(relPath)` truncated to
16 chars. Use `package:crypto`'s `sha1.convert(utf8.encode(relPath))`. The
deployment id pins the etag to a specific bundle version; the path hash
keeps it stable across requests for the same file in the same bundle.

Wrap the value in double quotes per RFC 9110. Don't use a weak validator
prefix.

### If-None-Match handling

If the inbound request carries `If-None-Match` and any of the comma-separated
values (after trimming) equals the etag we would emit, return `304 Not
Modified` with the same `Cache-Control` and `ETag` headers and an empty body.
Do **not** still call `_readBundleAsset` for 304s — short-circuit before the
storage round-trip. (Cheapest path: build the etag from `(deployment.id,
relPath)` first, compare, then only fetch bytes on a miss.)

The static-fallback branch (`_serveStatic`) does not have a deployment id;
skip the etag for it (or use the file mtime — easier to skip in v1, this
branch is only hit for the apex domain landing page in dev).

## Implementation outline (for the implementer)

1. In `_bodyResponse`, accept an optional `Map<String, String> extraHeaders`
   and merge it into the response. Replace the line
   `Body.fromData(Uint8List.fromList(body), …)` with
   `Body.fromData(body is Uint8List ? body : Uint8List.fromList(body), …)`
   to avoid copying when the source is already a `Uint8List` (it always is
   from `_readBundleAsset`, but keep the branch for safety).
2. Add a small private helper `_cacheControlFor(String relPath)` returning
   the strings from the table above.
3. Add `_etagFor(String deploymentId, String relPath)` returning the
   quoted etag string.
4. In `handleCall`, after resolving `active` and `safePath`:
   - Compute the etag.
   - Read `If-None-Match` from `request.headers`. If it matches, return a
     304 `Response` with `Cache-Control` and `ETag` set, no body.
   - Otherwise call `_readBundleAsset`, then `_bodyResponse(body, mime,
     extraHeaders: {...cacheControl, ...etag})`.
   - On the SPA fallback branch (extensionless, served as `index.html`),
     compute the etag against `'index.html'`, not the original `safePath` —
     otherwise hitting `/foo` and `/bar` would each get a unique etag for
     the same payload and CloudFront couldn't share cache entries.
5. Leave `_serveStatic` mostly alone — add the `Cache-Control` header
   matching the table but skip the etag.

Don't introduce gzip, don't introduce LRU, don't pre-compress. Those are
intentionally out of scope.

## Tests to add (`studio_route_test.dart`)

Extend the existing `withServerpod('StudioRoute', …)` group. New cases:

1. **Hashed asset gets immutable cache**: seed a bundle with file
   `assets/abc1234567def890.png`, hit it, assert response header
   `cache-control` equals `public, max-age=31536000, immutable` and `etag`
   is present and quoted.
2. **`index.html` gets short cache**: seed `index.html`, request `/`,
   assert `cache-control` is `public, max-age=0, must-revalidate`.
3. **SPA fallback shares etag with index.html**: request `/foo` (no
   extension, falls back to `index.html`), capture the etag, then request
   `/` and assert the etag is identical.
4. **Service worker is not immutable**: seed
   `flutter_service_worker.js`, request it, assert
   `cache-control` is `public, max-age=0, must-revalidate`.
5. **If-None-Match returns 304**: do request 1 above, capture etag,
   re-request with `if-none-match: <etag>` header, assert status 304 and
   empty body. Use `Headers.build` to add the request header.
6. **If-None-Match mismatch returns 200 + body**: re-request with
   `if-none-match: "wrong"`, assert status 200 and full body.
7. **Default cache for non-hashed `.js`**: seed `main.dart.js` (no hash in
   name), request it, assert `cache-control` is `public, max-age=300`.

Reuse `_buildRequest`, `_readBody`, `_seedBundle` from the existing test
file. For tests that need a custom request header, extend `_buildRequest` to
accept an optional `Map<String, String> extraHeaders`.

## Verify commands

Run from `dart_desk_workspace/dart_desk_be/dart_desk_server`:

```sh
# Lint / type check
dart analyze --fatal-infos

# Targeted tests
dart test test/integration/studio_route_test.dart

# Full integration suite (sanity — should still pass unchanged)
dart test test/integration
```

All three must pass. `dart analyze` must report zero infos/warnings/errors.

If running tests requires the `serverpod_test` Postgres instance, follow the
existing project conventions in `dart_desk_be/CLAUDE.md` — do not invent new
DB setup. If those tests already require a running Postgres on this branch
and the implementer can't run them, they should report that explicitly
rather than skipping.

## Out of scope (do NOT do these)

- Origin-side gzip / brotli — CloudFront handles compression.
- In-process LRU cache for bundle bytes — revisit only if CloudFront miss
  rate proves problematic.
- Streaming response bodies — same reason.
- Touching `configure_web_routes.dart`, `subdomain_router.dart`, or any
  other route. The change is local to `StudioRoute`.
- Renaming or restructuring `_bodyResponse` / `_safeRelative` /
  `_readBundleAsset`.

## Reporting

After implementation, report:
- The verify command output (analyze + the two test runs).
- Any deviation from the table above and why.
- Any Relic API choice that wasn't obvious from existing code.
