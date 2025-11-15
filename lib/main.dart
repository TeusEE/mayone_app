import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        builder: (context, child) {
          return SafeArea(
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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (value) {
                print('selected: $value');
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: MainPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _level1 = TextEditingController();
  final TextEditingController _level2 = TextEditingController();
  final TextEditingController _target = TextEditingController();

  double? ratio1;
  double? ratio2;

  void _calculateRatio() {
    final double? l1 = double.tryParse(_level1.text);
    final double? l2 = double.tryParse(_level2.text);
    final double? target = double.tryParse(_target.text);

    if (l1 == null || l2 == null || target == null) {
      setState(() {
        ratio1 = null;
        ratio2 = null;
      });
      return;
    }
    var temp_rat1 = (target-l2)/(l1-target);
    var temp_rat2 = 1.0;
    

    setState(() {
      ratio1 = temp_rat1;
      ratio2 = temp_rat2;
    });
  }

  @override
  void initState() {
    super.initState();
    _level1.addListener(_calculateRatio);
    _level2.addListener(_calculateRatio);
    _target.addListener(_calculateRatio);
  }

  @override
  void dispose() {
    _level1.dispose();
    _level2.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('염색약 레벨 계산기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 헤더
            _buildRow(
              ['', '약1', '약2'],
              [1, 1, 1],
              [Colors.yellow, Colors.yellow, Colors.yellow],
              isHeader: true
            ),

            // 레벨 입력
            _buildRowWidgets(
              ['레벨'],
              [
                _buildInputCell(_level1, Colors.orange.shade200),
                _buildInputCell(_level2, Colors.orange.shade200),
              ],
              [Colors.yellow, Colors.orange.shade200, Colors.orange.shade300],
            ),

            // 비율 계산 결과
            _buildRowWidgets(
              ['비율'],
              [
                _buildCell(ratio1 != null ? ratio1!.toStringAsFixed(2) : '-', color: Colors.white),
                _buildCell(ratio2 != null ? ratio2!.toStringAsFixed(2) : '-', color: Colors.white),
              ],
              [Colors.yellow, Colors.white, Colors.white],
            ),

            // 원하는 레벨 입력 (첫번째 유지, 나머지 합침)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildCell('원하는 레벨', color: Colors.yellow),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInputCell(_target, Colors.orange.shade200),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("같은 컬러일때만 가능합니다"),
                  Text("주황색만 입력하면 됩니다")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 일반 텍스트 셀
  Widget _buildCell(String text, {Color? color, Color? textColor, bool isTitle = false, double height = 50}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black), // 여기에 border 추가
      ),
      padding: EdgeInsets.all(8),
      height: height,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          color: textColor ?? Colors.black,
        ),
      ),
    );
  }

  // 입력 셀
  Widget _buildInputCell(TextEditingController controller, Color color, {double height = 50}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black), // 여기에 border 추가
      ),
      padding: EdgeInsets.all(8),
      height: height,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // 문자열 배열로 Row 생성 (헤더용)
  Widget _buildRow(List<String> texts, List<int> flexes, List<Color> colors, {bool isHeader = false}) {
    return Row(
      children: List.generate(texts.length, (index) {
        return Expanded(
          flex: flexes[index],
          child: _buildCell(texts[index], color: colors[index], isTitle: isHeader),
        );
      }),
    );
  }

  // 첫번째는 텍스트, 나머지는 위젯으로 Row 생성
  Widget _buildRowWidgets(List<String> texts, List<Widget> widgets, List<Color> colors) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildCell(texts[0], color: colors[0], isTitle: true),
        ),
        Expanded(
          flex: 1,
          child: widgets[0],
        ),
        Expanded(
          flex: 1,
          child: widgets[1],
        ),
      ],
    );
  }
}