import 'package:flutter_tem/api/http.dart';

/// 获取地区配置
Future<dynamic> getAreaConfigApi({int type = 1}) {
  return Api.instance
      .get('/pklApi/public/agent/getAreaConfig', params: {'type': type});
}
