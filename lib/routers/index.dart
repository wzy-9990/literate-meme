// utils/navigation_utils.dart
import 'package:get/get.dart';

class NavigationUtils {
  static Future<T?> toNamed<T>(
    String routeName, {
    dynamic arguments,
    Function(T result)? callback, // 注意：这里移除了 ?，因为 result 肯定不为 null
  }) async {
    final result = await Get.toNamed<T>(routeName, arguments: arguments);

    if (result != null && callback != null) {
      callback(result); // 只有 result 不为 null 才执行
    }

    return result;
  }
}
