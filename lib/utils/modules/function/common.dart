/// 通用值格式化工具类
/// 功能：处理空值、转换数字类型、兼容空对象/空数组，统一返回友好结果
class CommonFunction {
  /// 格式化值（对应 JS 的 formatText 方法）
  /// [val]：需要格式化的原始值（任意类型）
  /// [type]：可选类型指定，目前支持 'number'（强制转数字）
  static dynamic formatText(dynamic val, {String? type}) {
    // 1. 强制转数字类型（对应 JS 的 type === 'number'）
    if (type == 'number') {
      // 空值、无效值返回 0
      if (val == null || val == '' || _isNaN(val)) {
        return 0;
      }
      // 强制转换为数字（兼容字符串数字、布尔值等）
      return _toNumber(val);
    }

    // 2. 处理 null/undefined（Dart 中只有 null，无 undefined）
    if (val == null) {
      return '--';
    }

    // 3. 处理空字符串（含纯空格字符串）
    if (val is String && val.trim().isEmpty) {
      return '--';
    }

    // 4. 处理数字类型的 NaN
    if (val is num && val.isNaN) {
      return '--';
    }

    // 5. 处理空对象（仅普通 Map，不包含自定义对象）
    if (val is Map && val.isEmpty) {
      return <dynamic, dynamic>{}; // 返回空不可变 Map（或根据需求返回可变 Map）
    }

    // 6. 处理空数组
    if (val is List && val.isEmpty) {
      return <dynamic>[]; // 返回空不可变 List（或根据需求返回可变 List）
    }

    // 7. 其他正常值直接返回
    return val;
  }

  /// 辅助方法：判断是否为 NaN（兼容不同类型的 NaN 场景）
  static bool _isNaN(dynamic val) {
    return val is num ? val.isNaN : false;
  }

  /// 辅助方法：强制转换为数字（兼容 JS 的 Number(val) 逻辑）
  static num _toNumber(dynamic val) {
    if (val is num) {
      return val; // 本身是数字，直接返回
    } else if (val is String) {
      // 字符串转数字（兼容空字符串、纯空格字符串）
      final trimmed = val.trim();
      if (trimmed.isEmpty) return 0;
      return num.tryParse(trimmed) ?? 0; // 解析失败返回 0
    } else if (val is bool) {
      return val ? 1 : 0; // 布尔值转数字（true→1，false→0）
    } else {
      return 0; // 其他类型返回 0
    }
  }
}
