/// Extracts a single-label subdomain from [host] given a [domain] suffix.
///
/// Returns null if [host] does not end with `.<domain>`, or if the leading
/// label is empty or contains dots (i.e., multi-level subdomains are rejected).
///
/// Example: `extractSubdomain('mysite.app.dartdesk.dev', 'app.dartdesk.dev')`
/// returns `'mysite'`.
String? extractSubdomain(String host, String domain) {
  final hostWithoutPort = host.split(':').first;
  if (!hostWithoutPort.endsWith('.$domain')) return null;
  final label = hostWithoutPort.substring(
    0,
    hostWithoutPort.length - domain.length - 1,
  );
  if (label.isEmpty || label.contains('.')) return null;
  return label;
}
