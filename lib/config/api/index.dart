/// API 配置类
/// 用于配置不同项目的 API 响应规范
class ApiConfig {
  /// ==================== 响应字段名配置 ====================

  /// 状态码字段名
  /// 例如：某些项目用 'code'，某些用 'status'
  static const String codeField = 'code';

  /// 数据字段名
  /// 例如：某些项目用 'data'，某些用 'result'
  static const String dataField = 'data';

  /// 消息字段名
  /// 例如：某些项目用 'returnMsg'，某些用 'message' 或 'msg'
  static const String messageField = 'returnMsg';

  /// 时间戳字段名（可选）
  static const String timeField = 'currTime';

  /// 格式化时间字段名（可选）
  static const String timeFormatField = 'currTimeFormat';

  /// ==================== 状态码配置 ====================

  /// 成功状态码
  /// 例如：某些项目用 '1'，某些用 '200' 或 'success'
  static const String successCode = '1';

  /// 登录失效状态码
  /// 例如：401 或 403
  static const int unauthorizedCode = 401;

  /// ==================== 辅助方法 ====================

  /// 从响应数据中获取状态码
  static dynamic getCode(Map<String, dynamic> data) {
    return int.parse(data[codeField]);
  }

  /// 从响应数据中获取数据
  static dynamic getData(Map<String, dynamic> data) {
    return data[dataField];
  }

  /// 从响应数据中获取消息
  static String? getMessage(Map<String, dynamic> data) {
    return data[messageField];
  }

  /// 判断响应是否成功
  static bool isSuccess(Map<String, dynamic> data) {
    return getCode(data)?.toString() == successCode;
  }
}
