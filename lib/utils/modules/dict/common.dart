/// 通用枚举工具类：支持 label/value + 任意扩展字段（如 desc、icon 等）
/// 传入格式：[{label: 'xxx', value: xxx, 自定义字段1: xxx, 自定义字段2: xxx, ...}]
class CommonDictEnum<T> {
  // 存储原始数据列表（包含所有字段，不限制仅 label/value）
  final List<Map<String, dynamic>> _items;

  // 缓存 value -> 整个 item 的映射（优化反向查找性能）
  late final Map<T, Map<String, dynamic>> _valueToItemMap;

  // 私有构造函数：仅通过 of 方法初始化
  CommonDictEnum._(this._items) {
    // 初始化 value 映射表（value 作为唯一key，确保 value 不重复）
    _valueToItemMap = {};
    for (final item in _items) {
      if (item.containsKey('value')) {
        final value = item['value'] as T;
        if (_valueToItemMap.containsKey(value)) {
          throw ArgumentError('value 不能重复：$value（每个 item 的 value 必须唯一）');
        }
        _valueToItemMap[value] = item;
      } else {
        throw ArgumentError('每个 item 必须包含 value 字段（作为唯一标识）');
      }
    }
  }

  /// 初始化通用枚举（入口方法）
  /// [items]：必须包含 value 字段，label 可选，可添加任意自定义字段
  static CommonDictEnum<T> of<T>(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      throw ArgumentError('items 不能为空列表');
    }
    return CommonDictEnum._(items);
  }

  /// 1. 基础方法：通过 value 获取 item 中的任意字段值（核心兼容扩展字段）
  /// [fieldName]：字段名（如 'label'、'desc'、'icon' 等）
  /// 返回值：字段对应的值（未找到返回 null）
  R? getFieldByValue<R>({required T value, required String fieldName}) {
    final item = _valueToItemMap[value];
    if (item == null || !item.containsKey(fieldName)) {
      return null;
    }
    try {
      return item[fieldName] as R?;
    } catch (e) {
      throw ArgumentError('字段 $fieldName 的值类型错误');
    }
  }

  /// 2. 便捷方法：通过 value 获取 label（兼容原有用法）
  String getLabelByValue(T value) {
    return getFieldByValue<String>(value: value, fieldName: 'label') ?? '未知';
  }

  /// 3. 便捷方法：通过 value 获取完整 item（包含所有字段）
  Map<String, dynamic>? getItemByValue(T value) {
    return _valueToItemMap[value];
  }

  /// 4. 便捷方法：通过 label 获取 value（兼容原有用法）
  T? getValueByLabel(String label) {
    return getValueByField(fieldName: 'label', fieldValue: label);
  }

  /// 5. 通用方法：通过任意字段名 + 字段值 获取 value（支持扩展字段反向查找）
  /// 示例：通过 desc 字段值获取对应的 value
  T? getValueByField({required String fieldName, required dynamic fieldValue}) {
    try {
      final item = _items.firstWhere(
        (item) => item[fieldName] == fieldValue,
        orElse: () => {},
      );
      return item.isEmpty ? null : item['value'] as T?;
    } catch (e) {
      return null;
    }
  }

  /// 6. 获取所有 item 列表（包含所有字段，不可修改）
  List<Map<String, dynamic>> get allItems => List.unmodifiable(_items);

  /// 7. 获取所有 value 列表（作为唯一标识集合）
  List<T> get allValues => _valueToItemMap.keys.toList();

  /// 8. 便捷方法：获取所有 label 列表（兼容原有用法）
  List<String> get allLabels =>
      _items.map((e) => e['label'] as String? ?? '未知').toList();

  /// 9. 通用方法：获取所有指定字段的列表（支持扩展字段）
  /// 示例：获取所有 item 的 desc 字段列表
  List<R?> getAllFieldValues<R>(String fieldName) {
    return _items.map((item) => item[fieldName] as R?).toList();
  }

  /// 10. 操作符重载：支持通过键名访问字典项（如 directionTypeEnum['add_points']）
  /// [key]：键名（可以是 'key' 或 'label' 对应的值）
  /// 返回值：对应的字典项
  Map<String, dynamic>? operator [](String key) {
    // 首先尝试匹配 'key' 字段
    var item = _items.firstWhere(
      (item) => item['key'] == key,
      orElse: () => {},
    );

    // 如果没找到，再尝试匹配 'label' 字段
    if (item.isEmpty) {
      item = _items.firstWhere(
        (item) => item['label'] == key,
        orElse: () => {},
      );
    }

    return item.isEmpty ? null : item;
  }

  /// 11. 便捷方法：判断值是否存在（用于验证接口返回的值是否有效）
  /// [value]：要检查的值
  /// 返回值：是否存在
  bool containsValue(T value) {
    return _valueToItemMap.containsKey(value);
  }

  /// 12. 便捷方法：通过键名获取值（如 directionTypeEnum.getValueByKey('add_points')）
  /// [key]：键名（如 'add_points'）
  /// 返回值：对应的值
  T? getValueByKey(String key) {
    final item = this[key];
    return item != null ? item['value'] as T : null;
  }

  /// 13. 便捷方法：判断 value 是否等于指定值（用于条件判断）
  /// [value]：要检查的值
  /// [targetValue]：目标值
  /// 返回值：是否相等
  bool isValueEqual(T value, T targetValue) {
    return value == targetValue;
  }

  /// 14. 便捷方法：根据 label 判断 value 是否匹配（用于通过标签判断）
  /// [value]：接口返回的值
  /// [label]：期望的标签
  /// 返回值：是否匹配
  bool isValueByLabel(T value, String label) {
    final item = _valueToItemMap[value];
    return item != null && item['label'] == label;
  }

  /// 15. 便捷方法：判断 value 是否在指定的值列表中（用于多重条件判断）
  /// [value]：要检查的值
  /// [targetValues]：目标值列表
  /// 返回值：是否匹配任一值
  bool isValueIn(T value, List<T> targetValues) {
    return targetValues.contains(value);
  }
}
