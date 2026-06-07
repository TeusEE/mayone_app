// flutter drive 드라이버: integration_test에서 보낸 스크린샷 바이트를
// screenshots/<device>/<name>.png 로 저장한다.
//
// 저장 디렉터리는 SCREENSHOT_DIR 환경변수로 지정한다.
// 예) SCREENSHOT_DIR=screenshots/iphone flutter drive ...

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final String dir =
          Platform.environment['SCREENSHOT_DIR'] ?? 'screenshots';
      final File file = File('$dir/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      stdout.writeln('📸 saved: ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
