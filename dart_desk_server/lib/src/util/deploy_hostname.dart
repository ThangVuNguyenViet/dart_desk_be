final _hostnameRegex = RegExp(r'^[a-z][a-z0-9-]{1,61}[a-z0-9]$');

const _reservedHostnames = <String>{
  'api', 'www', 'admin', 'manage', 'app', 'cdn', 'assets', 'static',
  'auth', 'dashboard', 'mail', 'email', 'status', 'docs', 'blog',
};

bool isValidDeployHostname(String value) {
  if (!_hostnameRegex.hasMatch(value)) return false;
  if (value.startsWith('xn-')) return false;
  return true;
}

bool isReservedDeployHostname(String value) =>
    _reservedHostnames.contains(value.toLowerCase());

String slugifyForHostname(String input) => input
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

Iterable<String> deriveDeployHostnameCandidates(String base) sync* {
  yield base;
  for (var i = 2; i <= 100; i++) {
    yield '$base-$i';
  }
}
