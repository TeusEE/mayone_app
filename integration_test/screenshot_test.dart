// 앱 스토어용 스크린샷 자동 촬영 시나리오.
//
// flutter drive 와 함께 실행하면 주요 화면을 PNG로 캡처한다.
// (드라이버: test_driver/screenshot_driver.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mayone_app/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('주요 화면 스크린샷 촬영', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // iOS에서 스크린샷을 찍으려면 Flutter 표면을 이미지로 변환해야 한다.
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);

    // ── 1) 계산기: 예시 값(약1=6, 약2=10, 목표=7 → 비율 3:1) 입력 ──
    await tester.enterText(fields.at(0), '6'); // 약1 레벨
    await tester.enterText(fields.at(1), '10'); // 약2 레벨
    await tester.enterText(fields.at(2), '7'); // 원하는 레벨
    await tester.pumpAndSettle();

    // 입력 커서가 보이지 않도록 포커스 해제 후 캡처
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01-calculator');

    // ── 2) 다른 예시 + 용량 직접 입력 ──
    //     약1=4, 약2=9, 목표=6 → 비율 3:2
    //     약1 용량 60 입력 → 약2 자동 40, 총 100.0g
    await tester.enterText(fields.at(0), '4');
    await tester.enterText(fields.at(1), '9');
    await tester.enterText(fields.at(2), '6');
    // 포커스를 풀어 키보드를 내려야 하단 용량 필드가 다시 빌드된다.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.ensureVisible(fields.at(3)); // 약1 용량 필드 노출
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(3), '60'); // 약1 용량 → 약2 자동 40
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02-calculator-volume');

    // ── 3) 드로어(브랜드 네비게이션) 열기 ──
    final ScaffoldState scaffold = tester.firstState(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03-drawer');
  });
}
