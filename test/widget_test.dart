// MAYONE 앱의 기본 위젯/로직 테스트.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mayone_app/main.dart';

void main() {
  testWidgets('앱이 MAYONE 타이틀과 함께 뜬다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('MAYONE'), findsWidgets);
    expect(find.text('염색약 레벨 계산기'), findsWidgets);
  });

  testWidgets('레벨 입력 시 혼합 비율(3:1)이 계산된다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final fields = find.byType(TextField);
    // 순서: [약1 레벨, 약2 레벨, 원하는 레벨, 약1 용량, 약2 용량]
    await tester.enterText(fields.at(0), '6'); // 약1 레벨
    await tester.enterText(fields.at(1), '10'); // 약2 레벨
    await tester.enterText(fields.at(2), '7'); // 원하는 레벨
    await tester.pump();

    // a1:a2 = (10-7):(7-6) = 3:1
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // 약1 용량 기본값 100 → 약2 = 100 * 1/3 = 33.3 → 총 133.3g
    expect(find.textContaining('133.3'), findsOneWidget);
  });

  testWidgets('약1 용량을 바꾸면 총 용량 표시가 갱신된다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), '10');
    await tester.enterText(fields.at(2), '7'); // 비율 3:1
    await tester.pump();

    // 약1 용량을 60으로 변경 → 약2 = 20 → 총 80.0g
    await tester.enterText(fields.at(3), '60');
    await tester.pump();

    expect(find.textContaining('80.0'), findsOneWidget);
  });

  testWidgets('범위를 벗어난 목표 레벨은 안내 문구를 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), '10');
    await tester.enterText(fields.at(2), '12'); // 6~10 범위 밖
    await tester.pump();

    expect(find.textContaining('사이'), findsOneWidget);
  });
}
