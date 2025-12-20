import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NaverStorePage extends StatefulWidget {
  const NaverStorePage({super.key});

  @override
  State<NaverStorePage> createState() => _NaverStorePageState();
}

class _NaverStorePageState extends State<NaverStorePage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://brand.naver.com/jakomo_brandstore"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("네이버 스토어")),
      body: WebViewWidget(controller: controller),
    );
  }
}
