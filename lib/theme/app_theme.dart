import 'package:flutter/material.dart';

/// MAYONE 브랜드 컬러 팔레트.
///
/// 앱 아이콘(가위 + 머릿결 라인아트)의 톤을 그대로 가져왔다.
/// 따뜻한 크림 배경 위에 짙은 커피 브라운 라인/텍스트가 올라가는
/// 미니멀 미용실 무드를 기준으로 한다.
class AppColors {
  const AppColors._();

  /// 기본 배경(아이콘 바탕의 크림색)
  static const Color cream = Color(0xFFF5ECD9);

  /// 살짝 더 밝은 크림(드로어 등)
  static const Color creamLight = Color(0xFFFCF7EC);

  /// 메인 컬러(아이콘 라인/타이틀의 짙은 커피 브라운)
  static const Color brown = Color(0xFF3E2B23);

  /// 보조 브라운(커피)
  static const Color coffee = Color(0xFF6F4E37);

  /// 포인트 캐러멜(강조/결과 하이라이트)
  static const Color accent = Color(0xFFB07D4F);

  /// 카드/입력 영역 배경
  static const Color card = Color(0xFFFFFDF8);

  /// 테두리·구분선용 탠 컬러
  static const Color tan = Color(0xFFD8C3A5);

  /// 흐린 보조 텍스트
  static const Color muted = Color(0xFF8C7A6B);

  /// 경고(범위 밖 입력 등)
  static const Color warning = Color(0xFFB23A2E);
}

/// 앱 전역 테마.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.brown,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.brown,
    secondary: AppColors.coffee,
    surface: AppColors.card,
    onPrimary: AppColors.creamLight,
    onSurface: AppColors.brown,
    error: AppColors.warning,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.cream,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.brown,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.brown,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
      iconTheme: IconThemeData(color: AppColors.brown),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.tan, width: 1.4),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.brown,
      displayColor: AppColors.brown,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.tan,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.creamLight,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.tan, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brown, width: 1.8),
      ),
    ),
  );
}
