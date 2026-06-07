# 앱 스토어 스크린샷 촬영 가이드

iOS 시뮬레이터에서 **iPhone**과 **iPad** 스크린샷을 자동으로 촬영하는 절차입니다.
`integration_test` + `flutter drive`로 주요 화면을 같은 상태로 재현해 캡처하므로,
수동 조작 없이 매번 동일한 결과를 얻을 수 있습니다.

## 구성 파일

| 파일 | 역할 |
|------|------|
| `scripts/take_screenshots.sh` | **iPhone + iPad 일괄 촬영 스크립트** (실행 진입점) |
| `integration_test/screenshot_test.dart` | 촬영 시나리오(값 입력 → 캡처, 드로어 열기 → 캡처) |
| `test_driver/screenshot_driver.dart` | 캡처 바이트를 PNG 파일로 저장 |

촬영되는 화면(기기별 3장):
- `01-calculator.png` — 예시 값(약1=6, 약2=10, 목표=7 → 비율 3:1)이 입력된 계산기
- `02-calculator-volume.png` — 다른 예시(4/9/6 → 3:2) + 용량 직접 입력(약1 60 → 약2 40, 총 100.0g)
- `03-drawer.png` — 브랜드 드로어(네비게이션)

> 결과물은 `screenshots/iphone/`, `screenshots/ipad/` 에 저장됩니다. (`.gitignore`에 포함)

App Store Connect 권장 규격:
- **iPhone 6.9"** — iPhone 17 Pro Max (1320 × 2868)
- **iPad 13"** — iPad Pro 13-inch (2064 × 2752)

---

## 실행 방법

iPhone과 iPad를 한 번에 촬영합니다. 시뮬레이터 부팅까지 스크립트가 처리합니다.

```bash
flutter pub get            # 최초 1회
./scripts/take_screenshots.sh
```

완료되면 `screenshots/iphone/`, `screenshots/ipad/` 에 각각 3장씩 생성됩니다.

> 사용 기기를 바꾸려면 `scripts/take_screenshots.sh` 상단의 `IPHONE`, `IPAD` 변수를 수정하세요.
> 설치된 시뮬레이터 목록: `xcrun simctl list devices available | grep -Ei "iphone|ipad"`

---

## 촬영 화면 추가/변경

`integration_test/screenshot_test.dart` 에서 위젯을 조작한 뒤
`binding.takeScreenshot('파일명')` 을 호출하면 새 화면을 캡처합니다.

```dart
// 예: 특정 값 입력 후 캡처
await tester.enterText(find.byType(TextField).at(0), '8');
await tester.pumpAndSettle();
await binding.takeScreenshot('03-example');
```

## 참고

- iOS 캡처에는 `binding.convertFlutterSurfaceToImage()` 호출이 필요합니다(시나리오에 포함됨).
- 시뮬레이터 단순 화면 캡처만 필요하면: `xcrun simctl io booted screenshot out.png`
