import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mayone_app/pages/calculator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mayone_app/pages/temp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child!,
            
          );
        },
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isRailVisible = false;

  Future<void> _openNaverStore() async {
    const storeUrl = 'https://smartstore.naver.com/dadaminc';

    final uri = Uri.parse(storeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  final List<Widget> _pages = const [
    ColorCal(),
    TempWidget(),
    TempWidget()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MayOne"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isRailVisible = !_isRailVisible;
            });
          },
        ),
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: _isRailVisible ? null : 0,            
            child: _isRailVisible
            ? SafeArea(
              child: NavigationRail(
                extended: true,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.calculate),
                    label: Text('염색약계산기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.book),
                    label: Text('책구매(네이버스토어)'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('개발중...'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (value) async {
                  // 📘 책구매(네이버스토어)
                  if (value == 1) {
                    await _openNaverStore();

                    // 사이드바 닫기만 하고
                    setState(() {
                      _isRailVisible = false;
                    });

                    return; // 🔥 페이지 전환 안 함
                  }

                  setState(() {
                    _selectedIndex = value;
                    _isRailVisible = false;
                  });
                },
              ),
            )
            : null,
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                // 메인 화면을 탭했을 때만 왼쪽 탭 접기
                if (_isRailVisible) {
                  setState(() {
                    _isRailVisible = false;
                  });
                }
              },
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}