import 'baiDuMap/index.dart';
import 'jPush/index.dart';

class Global {
  static Future<void> init() async {
    // 极光推送初始化
    await JPushServices().initJPush();

    // 百度地图初始化
    await initBaiduMap();

    // 其他服务初始化，比如权限、缓存、数据库等...
  }
}
