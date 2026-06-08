#!/usr/bin/env python3
"""PNG에서 알파 채널을 제거한다.

App Store Connect는 스크린샷/아이콘에 알파 채널(투명도)이 포함되면 업로드를
거부한다. integration_test로 캡처한 PNG는 RGBA(알파 포함)이므로, 흰색 배경
위에 평탄화(flatten)하여 RGB(불투명)로 다시 저장한다.

사용법:
    python3 scripts/strip_alpha.py screenshots            # 디렉터리(재귀)
    python3 scripts/strip_alpha.py a.png b.png            # 개별 파일
"""

import sys
from pathlib import Path

from PIL import Image


def collect_pngs(targets):
    for t in targets:
        p = Path(t)
        if p.is_dir():
            yield from sorted(p.rglob("*.png"))
        elif p.suffix.lower() == ".png":
            yield p


def strip(path: Path) -> bool:
    with Image.open(path) as img:
        if img.mode in ("RGB", "L"):
            return False  # 이미 알파 없음
        # 투명 픽셀이 있더라도 흰 배경 위에 합성해 불투명 RGB로 변환
        rgba = img.convert("RGBA")
        background = Image.new("RGB", rgba.size, (255, 255, 255))
        background.paste(rgba, mask=rgba.split()[-1])
        background.save(path, "PNG")
        return True


def main():
    targets = sys.argv[1:] or ["screenshots"]
    changed = 0
    for png in collect_pngs(targets):
        if strip(png):
            changed += 1
            print(f"  ✓ 알파 제거: {png}")
    print(f"완료: {changed}개 변환")


if __name__ == "__main__":
    main()
