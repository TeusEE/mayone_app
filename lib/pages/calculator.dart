import 'package:flutter/material.dart';

class ColorCal extends StatefulWidget {
  const ColorCal({super.key});

  @override
  State<ColorCal> createState() => _MainPageState();
}

class _MainPageState extends State<ColorCal> {
  final TextEditingController _level1 = TextEditingController();
  final TextEditingController _level2 = TextEditingController();
  final TextEditingController _vol1 = TextEditingController(text: "100");
  final TextEditingController _vol2 = TextEditingController();
  final TextEditingController _target = TextEditingController();
  bool _isUpdatingVolumes = false; // <-- 추가

  int? ratio1;
  int? ratio2;


  void _calculateRatio() {
    final int? l1 = int.tryParse(_level1.text);
    final int? l2 = int.tryParse(_level2.text);
    final int? target = int.tryParse(_target.text);
    
    if (l1 == null || l2 == null || target == null) {
      setState(() {
        ratio1 = null;
        ratio2 = null;
      });
      return;
    }

    var tempRat1 = (-1*(target - l2)).toInt();
    var tempRat2 = (-1*(l1 - target)).toInt();
    if (tempRat2<0 && tempRat1<0){
      tempRat2 = tempRat2*-1;
      tempRat1 = tempRat1*-1;
    }
    var mingcd = tempRat1.gcd(tempRat2);

    setState(() {
      ratio1 = ((tempRat1)/mingcd).toInt();
      ratio2 = ((tempRat2)/mingcd).toInt();
    });
    _recalcFromVol1();    
  }

  void _recalcFromVol1() {
    if (_isUpdatingVolumes) return;              // 다른 쪽에서 업데이트 중이면 무시
    if (ratio1 == null || ratio2 == null) return;

    final double? v1 = double.tryParse(_vol1.text);

    _isUpdatingVolumes = true;
    try {
      if (v1 == null) {
        _vol2.text = '';
      } else {
        final double v2 = v1 * ratio2! / ratio1!;
        _vol2.text = v2.toStringAsFixed(1);
      }
    } finally {
      _isUpdatingVolumes = false;
    }
  }

  void _recalcFromVol2() {
    if (_isUpdatingVolumes) return;              // 다른 쪽에서 업데이트 중이면 무시
    if (ratio1 == null || ratio2 == null) return;

    final double? v2 = double.tryParse(_vol2.text);

    _isUpdatingVolumes = true;
    try {
      if (v2 == null) {
        _vol1.text = '';
      } else {
        final double v1 = v2 * ratio1! / ratio2!;
        _vol1.text = v1.toStringAsFixed(1);
      }
    } finally {
      _isUpdatingVolumes = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _level1.addListener(_calculateRatio);
    _level2.addListener(_calculateRatio);
    _target.addListener(_calculateRatio);
    _vol1.addListener(_recalcFromVol1);
    _vol2.addListener(_recalcFromVol2);
  }

  @override
  void dispose() {
    _level1.dispose();
    _level2.dispose();
    _target.dispose();
    _vol1.dispose();
    _vol2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('염색약 레벨 계산기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRow(
              ['', '약1', '약2'],
              [1, 1, 1],
              [Colors.yellow, Colors.yellow, Colors.yellow],
              isHeader: true,
            ),
            _buildRowWidgets(
              ['레벨'],
              [
                _buildInputCell(_level1, Colors.orange.shade200),
                _buildInputCell(_level2, Colors.orange.shade200),
              ],
              [Colors.yellow, Colors.orange.shade200, Colors.orange.shade300],
            ),
            _buildRowWidgets(
              ['비율'],
              [
                _buildCell(ratio1 != null ? ratio1!.toString() : '-',
                    color: Colors.white),
                _buildCell(ratio2 != null ? ratio2!.toString() : '-',
                    color: Colors.white),
              ],
              [Colors.yellow, Colors.white, Colors.white],
            ),
            _buildRowWidgets(
              ['용량(g)'],
              [
                _buildInputCell(_vol1, Colors.orange.shade200),
                _buildInputCell(_vol2, Colors.orange.shade200),
              ],
              [Colors.yellow, Colors.white, Colors.white],
            ),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("같은 컬러일때만 가능합니다"),
                  Text("주황색만 입력하면 됩니다"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    String text, {
    Color? color,
    Color? textColor,
    bool isTitle = false,
    double height = 50,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(8),
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

  Widget _buildInputCell(TextEditingController controller, Color color,
      {double height = 50}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(8),
      height: height,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRow(List<String> texts, List<int> flexes, List<Color> colors,
      {bool isHeader = false}) {
    return Row(
      children: List.generate(texts.length, (index) {
        return Expanded(
          flex: flexes[index],
          child: _buildCell(
            texts[index],
            color: colors[index],
            isTitle: isHeader,
          ),
        );
      }),
    );
  }

  Widget _buildRowWidgets(
      List<String> texts, List<Widget> widgets, List<Color> colors) {
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
