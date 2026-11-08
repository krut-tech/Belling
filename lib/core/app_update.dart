import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Free, Play-Store-less updates: the app looks at the latest GitHub Release of
/// the repo, compares versions and (on Android) downloads + installs the APK.
const String kUpdateRepo = 'krut-tech/Belling';

class AppRelease {
  const AppRelease({
    required this.version,
    required this.notes,
    required this.apkUrl,
    this.pageUrl,
  });
  final String version; // e.g. 1.0.1 (no leading v)
  final String notes;
  final String apkUrl;
  final String? pageUrl;
}

/// Parses "v1.2.3", "1.2.3+4" -> [1,2,3]. Non-numeric parts count as 0.
List<int> parseVersion(String v) {
  var s = v.trim();
  if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
  final plus = s.indexOf('+');
  if (plus >= 0) s = s.substring(0, plus);
  final dash = s.indexOf('-');
  if (dash >= 0) s = s.substring(0, dash);
  final parts = s.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts;
}

/// True when [latest] is strictly newer than [current].
bool isNewerVersion(String latest, String current) {
  final a = parseVersion(latest);
  final b = parseVersion(current);
  final n = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < n; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Reads the release JSON GitHub returns. Returns null when it has no APK.
AppRelease? parseRelease(Map<String, dynamic> json) {
  final tag = (json['tag_name'] ?? '').toString();
  if (tag.isEmpty) return null;
  final assets = (json['assets'] as List?) ?? const [];
  String? apk;
  for (final a in assets) {
    if (a is Map) {
      final name = (a['name'] ?? '').toString().toLowerCase();
      if (name.endsWith('.apk')) {
        apk = a['browser_download_url']?.toString();
        break;
      }
    }
  }
  if (apk == null || apk.isEmpty) return null;
  var version = tag;
  if (version.startsWith('v') || version.startsWith('V')) {
    version = version.substring(1);
  }
  return AppRelease(
    version: version,
    notes: (json['body'] ?? '').toString().trim(),
    apkUrl: apk,
    pageUrl: json['html_url']?.toString(),
  );
}

/// Latest published release, or null on any problem (offline, rate limit,
/// no release yet). Never throws: update checks must not disturb billing.
Future<AppRelease?> fetchLatestRelease({
  String repo = kUpdateRepo,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client
        .getUrl(Uri.parse('https://api.github.com/repos/$repo/releases/latest'))
        .timeout(timeout);
    req.headers.set('Accept', 'application/vnd.github+json');
    req.headers.set('User-Agent', 'belling-app');
    final res = await req.close().timeout(timeout);
    if (res.statusCode != 200) {
      await res.drain<void>();
      return null;
    }
    final body = await res.transform(utf8.decoder).join().timeout(timeout);
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    return parseRelease(json);
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Downloads the APK to [destPath], reporting 0..1 progress. Throws on failure.
Future<File> downloadApk(
  String url,
  String destPath, {
  void Function(double progress)? onProgress,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  final tmp = File('$destPath.part');
  try {
    var uri = Uri.parse(url);
    HttpClientResponse res;
    var hops = 0;
    while (true) {
      final req = await client.getUrl(uri);
      req.followRedirects = false;
      req.headers.set('User-Agent', 'belling-app');
      res = await req.close();
      if (res.isRedirect && hops < 5) {
        final loc = res.headers.value(HttpHeaders.locationHeader);
        await res.drain<void>();
        if (loc == null) throw const HttpException('Bad redirect');
        uri = uri.resolve(loc);
        hops++;
        continue;
      }
      break;
    }
    if (res.statusCode != 200) {
      await res.drain<void>();
      throw HttpException('Download failed (${res.statusCode})');
    }
    final total = res.contentLength;
    var got = 0;
    final sink = tmp.openWrite();
    try {
      await for (final chunk in res) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress?.call(got / total);
      }
    } finally {
      await sink.close();
    }
    if (total > 0 && got != total) {
      throw const HttpException('Download incomplete');
    }
    final dest = File(destPath);
    if (await dest.exists()) await dest.delete();
    await tmp.rename(destPath);
    onProgress?.call(1);
    return dest;
  } catch (_) {
    if (await tmp.exists()) {
      try {
        await tmp.delete();
      } catch (_) {}
    }
    rethrow;
  } finally {
    client.close(force: true);
  }
}
