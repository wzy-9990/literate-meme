import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPageView extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPageView({
    super.key,
    required this.url,
    this.title = '网页',
  });

  @override
  State<WebViewPageView> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPageView> {
  late final WebViewController _controller;

  double _progress = 0;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = widget.title;

    // 初始化 WebView 控制器
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {});
          },
          onPageFinished: (String url) async {
            setState(() {});

            // 获取页面标题
            final String? title = await _controller.getTitle();
            if (title != null && mounted) {
              setState(() {
                _title = title;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              Get.snackbar('网页加载错误', error.description);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // 可以在这里控制哪些链接可以在 WebView 中打开
            // 例如，只允许特定域名的链接在 WebView 中打开
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          Get.snackbar('提示', message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMenu,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _refresh() async {
    await _controller.reload();
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      if (mounted) Get.back();
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('刷新'),
                onTap: () {
                  Navigator.pop(context);
                  _refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('在浏览器中打开'),
                onTap: () async {
                  Navigator.pop(context);
                  // 可以使用 url_launcher 插件在浏览器中打开链接
                  // await launchUrl(Uri.parse(widget.url));
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('复制链接'),
                onTap: () {
                  Navigator.pop(context);
                  // 可以使用 Clipboard 插件复制链接
                  // Clipboard.setData(ClipboardData(text: widget.url));
                  Get.snackbar('提示', '链接已复制');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
