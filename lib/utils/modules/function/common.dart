/// 通用值格式化工具类
/// 功能：处理空值、转换数字类型、兼容空对象/空数组，统一返回友好结果
class CommonFunction {
  /// 格式化值（对应 JS 的 formaData 方法）
  /// [val]：需要格式化的原始值（任意类型）
  /// [type]：可选类型指定，目前支持 'number'（强制转数字）
  static dynamic formaData(dynamic val, {String? type}) {
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

  /// 将 formaData 的结果统一转为字符串
  ///
  /// 规则：
  /// - null / '' / 纯空格 / [] / {} -> '--'
  /// - 数字 0 -> '0'（保持 0 不被当成空）
  /// - 其他值调用 toString()
  static String formaDataString(dynamic val) {
    final formatted = formaData(val);

    // 0 需要保留
    if (formatted is num && formatted == 0) {
      return '0';
    }

    // 空 Map / 空 List / null / 空字符串
    if (formatted == null) {
      return '--';
    }
    if (formatted is String && formatted.trim().isEmpty) {
      return '--';
    }
    if (formatted is Map && formatted.isEmpty) {
      return '--';
    }
    if (formatted is List && formatted.isEmpty) {
      return '--';
    }

    return formatted.toString();
  }

  /// 辅助方法：强制转换为数字（兼容 JS 的 Number(val) 逻辑）
  static num _toNumber(dynamic val) {
    if (val is num) {
      return val; // 本身是数字，直接返回
    } else if (val is String) {
      // 字符串转数字（兼容空字符串、纯空格字符串）
      final trimmed = val.trim();
      if (trimmed.isEmpty) {
        return 0;
      }
      return num.tryParse(trimmed) ?? 0; // 解析失败返回 0
    } else if (val is bool) {
      return val ? 1 : 0; // 布尔值转数字（true→1，false→0）
    } else {
      return 0; // 其他类型返回 0
    }
  }

  /// 金额格式化：
  /// - null/空/NaN -> '0.00'
  /// - 0 -> '0.00'
  /// - <10000 保留两位小数
  /// - >=10000 转为「xx万」，去掉末尾 .00
  static String formatAmount(dynamic amount) {
    if (amount == null || (amount is String && amount.trim().isEmpty)) {
      return '0.00';
    }

    final numValue = _toNumber(amount);
    if (numValue.isNaN) {
      return '0.00';
    }

    if (numValue == 0) {
      return '0.00';
    }

    if (numValue >= 10000) {
      var result = (numValue / 10000).toStringAsFixed(2);
      if (result.endsWith('.00')) {
        result = result.substring(0, result.length - 3);
      }
      return '$result万';
    }

    return numValue.toStringAsFixed(2);
  }

  /// 根据金额长度收缩字体：
  /// - 先用 formatAmount 格式化，再按数字位数收缩
  /// - 默认返回 basePx（建议传 sp 值）
  /// - 位数 7-10: 缩小 2；11-14: 缩小 4；>14: 缩小 6；最小 12
  /// - 若用了 ScreenUtil，可将返回值再 `.sp` 转为实际 px
  static num getMoneyFontSize(double basePx, dynamic amount) {
    if (amount == null || (amount is String && amount.trim().isEmpty)) {
      return basePx * 2; // 对齐原始实现的放大
    }

    final formatted = formatAmount(amount);
    final digits = RegExp(r'\\d').allMatches(formatted).length;
    final len = digits > 0 ? digits : formatted.length;

    var shrink = 0.0;
    if (len > 6 && len <= 10) {
      shrink = 2;
    } else if (len > 10 && len <= 14) {
      shrink = 4;
    } else if (len > 14) {
      shrink = 6;
    }

    final finalPx = (basePx - shrink).clamp(12, double.infinity);
    return finalPx;
  }
}
