import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mayone_app/pages/calculator.dart';
import 'package:mayone_app/pages/temp.dart';
import 'package:mayone_app/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAYONE',
      theme: buildAppTheme(),
      builder: (context, child) {
        // 화면 아무 곳이나 탭하면 키보드 닫기
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child!,
        );
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const String _naverStoreUrl = 'https://smartstore.naver.com/dadaminc';

  final List<Widget> _pages = const [ColorCal(), TempWidget()];

  Future<void> _openNaverStore() async {
    final uri = Uri.parse(_naverStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MAYONE')),
      drawer: _buildDrawer(context),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.creamLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandHeader(),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.calculate_outlined,
              label: '염색약 레벨 계산기',
              selected: _selectedIndex == 0,
              onTap: () => _selectPage(0),
            ),
            _DrawerItem(
              icon: Icons.menu_book_outlined,
              label: '책 구매 (네이버 스토어)',
              onTap: () async {
                Navigator.of(context).pop();
                await _openNaverStore();
              },
            ),
            _DrawerItem(
              icon: Icons.auto_awesome_outlined,
              label: '개발중...',
              selected: _selectedIndex == 1,
              onTap: () => _selectPage(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'MAYONE',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: AppColors.brown,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPage(int index) {
    Navigator.of(context).pop();
    setState(() => _selectedIndex = index);
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? AppColors.cream : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.brown : AppColors.coffee,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.brown : AppColors.coffee,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
