#!/usr/bin/env bash
#
# 앱 스토어용 스크린샷 일괄 촬영 (iPhone + iPad)
#
# iOS 시뮬레이터를 부팅하고 integration_test 시나리오를 실행해
# 두 기기의 스크린샷을 한 번에 캡처한다.
#
#   사용법:  ./scripts/take_screenshots.sh
#
# 결과물:
#   screenshots/iphone/*.png   (iPhone 17 Pro Max, 1320×2868 — App Store 6.9")
#   screenshots/ipad/*.png     (iPad Pro 13-inch,  2064×2752 — App Store 13")

set -euo pipefail

# 프로젝트 루트로 이동(스크립트 위치 기준)
cd "$(dirname "$0")/.."

IPHONE="iPhone 17 Pro Max"
IPAD="iPad Pro 13-inch (M5)"
DRIVER="test_driver/screenshot_driver.dart"
TARGET="integration_test/screenshot_test.dart"

echo "▶ 시뮬레이터 부팅..."
xcrun simctl boot "$IPHONE" 2>/dev/null || true
xcrun simctl boot "$IPAD" 2>/dev/null || true
open -a Simulator

# 사용법: capture <기기명> <저장 경로>
capture() {
  local device="$1"
  local dir="$2"
  echo ""
  echo "▶ 촬영: ${device}  →  ${dir}"
  SCREENSHOT_DIR="$dir" flutter drive \
    --driver="$DRIVER" \
    --target="$TARGET" \
    -d "$device"
}

capture "$IPHONE" "screenshots/iphone"
capture "$IPAD" "screenshots/ipad"

# App Store Connect는 알파 채널(투명도)이 포함된 스크린샷을 거부하므로 제거한다.
echo ""
echo "▶ 알파 채널 제거..."
python3 "$(dirname "$0")/strip_alpha.py" screenshots

echo ""
echo "✅ 완료"
echo "   screenshots/iphone/  (3장)"
echo "   screenshots/ipad/    (3장)"
