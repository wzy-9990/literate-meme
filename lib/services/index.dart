import 'package:flutter_tem/api/http.dart';
import 'baiDuMap/index.dart';
import 'jPush/index.dart';

class Global {
  static Future<void> init() async {
    // 初始化 API 服务（检查自定义 API 地址）
    await ApiService.init();

    // 极光推送初始化
    await JPushServices().initJPush();

    // 百度地图初始化
    await initBaiduMap();

    // 其他服务初始化，比如权限、缓存、数据库等...
  }
}
