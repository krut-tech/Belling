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
    test('no apk or no tag -> null', () {
      expect(parseRelease({'tag_name': 'v1', 'assets': []}), isNull);
      expect(parseRelease({'assets': []}), isNull);
    });
  });
}
