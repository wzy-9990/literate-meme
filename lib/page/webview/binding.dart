import 'package:flutter_tem/page/webview/logic.dart';
import 'package:get/get.dart';

class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebViewLogic>(() => WebViewLogic());
  }
}
