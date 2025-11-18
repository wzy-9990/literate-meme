import 'package:flutter_easyloading/flutter_easyloading.dart';

class EasyLoadingConfig {
  static void init() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle;
  }
}
