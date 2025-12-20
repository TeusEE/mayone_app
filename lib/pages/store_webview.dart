import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NaverStorePage extends StatefulWidget {
  const NaverStorePage({super.key});

  @override
  State<NaverStorePage> createState() => _NaverStorePageState();
}

class _NaverStorePageState extends State<NaverStorePage> {
  late final WebViewController _controller;
  final ChromeSafariBrowser _safariBrowser = ChromeSafariBrowser();

  static const String _categoryUrl =
      "https://smartstore.naver.com/dadaminc/category/"
      "a95082f7ee81407fa2752f453b06ef62?cp=1";

  /// 🔥 SPA 상품 클릭 가로채기 JS
  static const String _injectJs = """
(function() {
  if (window.__FLUTTER_PRODUCT_CLICK_INSTALLED__) return;
  window.__FLUTTER_PRODUCT_CLICK_INSTALLED__ = true;

  document.addEventListener('click', function(e) {
    let el = e.target;

    while (el && el.tagName !== 'A') {
      el = el.parentElement;
    }
    if (!el) return;

    const href = el.getAttribute('href');
    if (!href) return;

    if (href.includes('/products/')) {
      e.preventDefault();
      e.stopPropagation();

      const fullUrl = href.startsWith('http')
        ? href
        : 'https://smartstore.naver.com' + href;

      ProductClick.postMessage(fullUrl);
    }
  }, true);
})();
""";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      /// iOS Safari UA
      ..setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
        "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 "
        "Mobile/15E148 Safari/604.1",
      )

      /// JS → Flutter 통신
      ..addJavaScriptChannel(
        'ProductClick',
        onMessageReceived: (message) {
          _openWithSafariViewController(message.message);
        },
      )

      /// SPA 특성상 로드 완료 후마다 JS 주입
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _controller.runJavaScript(_injectJs);
          },
        ),
      )

      ..loadRequest(Uri.parse(_categoryUrl));
  }

  /// ✅ 네이버 차단 안 당하는 핵심 함수
  Future<void> _openWithSafariViewController(String url) async {
    await _safariBrowser.open(
      url: WebUri(url),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("네이버 스토어"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
