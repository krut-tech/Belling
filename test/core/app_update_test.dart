import 'package:belling/core/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('version compare', () {
    test('newer / older / equal', () {
      expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('v1.2.0', '1.1.9'), isTrue);
      expect(isNewerVersion('2.0.0', '1.99.99'), isTrue);
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0.0', '1.0.1'), isFalse);
      expect(isNewerVersion('1.10.0', '1.9.0'), isTrue);
    });
    test('build suffix and short forms are ignored/padded', () {
      expect(isNewerVersion('1.0.1+5', '1.0.0+9'), isTrue);
      expect(isNewerVersion('1.1', '1.0.9'), isTrue);
      expect(isNewerVersion('1.0.0+2', '1.0.0+1'), isFalse);
      expect(parseVersion('v1.2.3-beta'), [1, 2, 3]);
    });
  });

  group('parseRelease', () {
    test('picks the apk asset and strips v', () {
      final r = parseRelease({
        'tag_name': 'v1.0.2',
        'body': 'Udhar reminder added',
        'html_url': 'https://github.com/x/y/releases/tag/v1.0.2',
        'assets': [
          {'name': 'notes.txt', 'browser_download_url': 'https://x/notes.txt'},
          {'name': 'belling.apk', 'browser_download_url': 'https://x/belling.apk'},
        ],
      });
      expect(r, isNotNull);
      expect(r!.version, '1.0.2');
      expect(r.apkUrl, 'https://x/belling.apk');
      expect(r.notes, 'Udhar reminder added');
    });
    test('picks the 32-bit apk for old phones, arm64 default otherwise', () {
      final json = {
        'tag_name': 'v1.0.6',
        'assets': [
          {'name': 'belling-armeabi-v7a.apk', 'browser_download_url': 'https://x/v7.apk'},
          {'name': 'belling.apk', 'browser_download_url': 'https://x/belling.apk'},
        ],
      };
      expect(parseRelease(json, abi: 'armeabi-v7a')!.apkUrl, 'https://x/v7.apk');
      expect(parseRelease(json)!.apkUrl, 'https://x/belling.apk');
      expect(parseRelease(json, abi: 'x86_64')!.apkUrl, 'https://x/belling.apk');
    });
    test('detectAbi reads the Dart runtime string', () {
      expect(detectAbi('3.9.0 (stable) on "android_arm64"'), 'arm64-v8a');
      expect(detectAbi('3.9.0 (stable) on "android_arm"'), 'armeabi-v7a');
      expect(detectAbi('3.9.0 (stable) on "android_x64"'), 'x86_64');
      expect(detectAbi('3.9.0 (stable) on "windows_x64"'), 'arm64-v8a');
    });
    test('no apk or no tag -> null', () {
      expect(parseRelease({'tag_name': 'v1', 'assets': []}), isNull);
      expect(parseRelease({'assets': []}), isNull);
    });
  });
}
