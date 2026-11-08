import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_update.dart';

/// Checks GitHub for a newer release. Returns it only when newer than the
/// installed app; null otherwise (up to date, offline, no release).
Future<AppRelease?> checkForUpdate() async {
  if (!Platform.isAndroid) return null;
  try {
    final info = await PackageInfo.fromPlatform();
    final latest = await fetchLatestRelease();
    if (latest == null) return null;
    return isNewerVersion(latest.version, info.version) ? latest : null;
  } catch (_) {
    return null;
  }
}

Future<String> currentVersionLabel() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } catch (_) {
    return '-';
  }
}

Future<void> showUpdateDialog(BuildContext context, AppRelease release) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(release: release),
  );
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.release});
  final AppRelease release;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double? _progress;
  String? _error;
  bool _busy = false;

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/belling-${widget.release.version}.apk';
      await downloadApk(
        widget.release.apkUrl,
        path,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      final res = await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
      if (!mounted) return;
      if (res.type != ResultType.done) {
        setState(() {
          _busy = false;
          _error = 'Install screen nahi khula (${res.message}). '
              '"Browser se download" try karo ya Settings mein "Install unknown apps" allow karo.';
        });
        return;
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Download nahi hua. Internet check karke dobara try karo.';
      });
    }
  }

  Future<void> _browser() async {
    final ok = await launchUrl(Uri.parse(widget.release.apkUrl), mode: LaunchMode.externalApplication);
    if (!ok && mounted) setState(() => _error = 'Browser nahi khul paaya.');
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.release;
    return AlertDialog(
      title: Text('Naya update ${r.version}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Naye features aur fixes available hain. Aapka data safe rahega.'),
            if (r.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Kya naya hai:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(r.notes, maxLines: 12, overflow: TextOverflow.ellipsis),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: (_progress ?? 0) > 0 ? _progress : null),
              const SizedBox(height: 6),
              Text('Download ho raha hai... ${((_progress ?? 0) * 100).toStringAsFixed(0)}%'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Baad mein'),
        ),
        if (_error != null) TextButton(onPressed: _browser, child: const Text('Browser se download')),
        FilledButton(
          onPressed: _busy ? null : _start,
          child: const Text('Update karo'),
        ),
      ],
    );
  }
}

/// Wrap the app shell: checks once per launch (a few seconds after start),
/// silently ignoring every failure.
class UpdateChecker extends StatefulWidget {
  const UpdateChecker({required this.child, super.key});
  final Widget child;

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

bool _checkedThisLaunch = false;

class _UpdateCheckerState extends State<UpdateChecker> {
  @override
  void initState() {
    super.initState();
    if (_checkedThisLaunch || !Platform.isAndroid) return;
    _checkedThisLaunch = true;
    Future<void>.delayed(const Duration(seconds: 4), () async {
      final release = await checkForUpdate();
      if (release != null && mounted) {
        await showUpdateDialog(context, release);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
