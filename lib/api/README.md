# API 配置说明

## 概述

`ApiConfig` 类用于配置项目的 API 响应规范，使得切换不同项目或对接不同后端接口时更加灵活。

## 配置项说明

### 响应字段名配置

```dart
/// 状态码字段名
static const String codeField = 'code';

/// 数据字段名
static const String dataField = 'data';

/// 消息字段名
static const String messageField = 'returnMsg';
```

**不同项目的常见配置：**

| 项目类型 | codeField | dataField | messageField |
|---------|-----------|-----------|--------------|
| 当前项目 | `'code'` | `'data'` | `'returnMsg'` |
| 标准 RESTful | `'status'` | `'data'` | `'message'` |
| 其他后端 | `'errcode'` | `'result'` | `'msg'` |

### 状态码配置

```dart
/// 成功状态码
static const String successCode = '1';

/// 登录失效状态码
static const int unauthorizedCode = 401;
```

**不同项目的常见配置：**

| 项目类型 | successCode | unauthorizedCode |
|---------|-------------|------------------|
| 当前项目 | `'1'` | `401` |
| 标准 HTTP | `'200'` | `401` |
| 微信接口 | `'0'` | `40001` |
| 自定义 | `'success'` | `403` |

## 使用示例

### 1. 切换到新项目

假设新项目的接口规范为：
```json
{
  "status": "200",
  "result": {...},
  "message": "操作成功"
}
```

只需修改 `lib/api/config.dart`：

```dart
class ApiConfig {
  static const String codeField = 'status';      // 从 'code' 改为 'status'
  static const String dataField = 'result';      // 从 'data' 改为 'result'
  static const String messageField = 'message';  // 从 'returnMsg' 改为 'message'

  static const String successCode = '200';       // 从 '1' 改为 '200'
  static const int unauthorizedCode = 401;       // 保持不变
}
```

### 2. 在代码中使用

```dart
// ✅ 推荐：使用 ApiConfig 辅助方法
final code = ApiConfig.getCode(responseData);
final data = ApiConfig.getData(responseData);
final message = ApiConfig.getMessage(responseData);
final isSuccess = ApiConfig.isSuccess(responseData);

// ❌ 不推荐：硬编码字段名
final code = responseData['code'];  // 切换项目时容易遗漏
```

## 辅助方法

```dart
/// 从响应数据中获取状态码
static dynamic getCode(Map<String, dynamic> data);

/// 从响应数据中获取数据
static dynamic getData(Map<String, dynamic> data);

/// 从响应数据中获取消息
static String? getMessage(Map<String, dynamic> data);

/// 判断响应是否成功
static bool isSuccess(Map<String, dynamic> data);
```

## 最佳实践

### ✅ 应该做的

1. **新项目开始前，先配置 ApiConfig**
   ```dart
   // 1. 查看后端接口文档
   // 2. 修改 lib/api/config.dart
   // 3. 所有接口调用都会自动适配
   ```

2. **使用辅助方法而非直接访问字段**
   ```dart
   // ✅ 好
   if (ApiConfig.isSuccess(data)) {
     final result = ApiConfig.getData(data);
   }

   // ❌ 不好
   if (data['code'] == '1') {
     final result = data['data'];
   }
   ```

3. **添加注释说明特殊配置**
   ```dart
   /// 成功状态码
   /// 注意：该项目使用字符串 '1' 而非数字 1
   static const String successCode = '1';
   ```

### ❌ 不应该做的

1. **不要在业务代码中硬编码字段名**
2. **不要在不同文件中重复定义配置**
3. **不要将配置放在 .env 文件中**（这些是代码逻辑，不是环境变量）

## 常见问题

### Q: 为什么不放在 .env 文件中？

**A:** 因为：
1. 这些是 API 协议规范，属于代码逻辑层面
2. 配置类提供更好的类型安全和 IDE 支持
3. 可以添加辅助方法，更方便使用
4. .env 主要用于环境相关配置（如 API_URL、密钥等）

### Q: 如何支持多套接口规范？

**A:** 可以创建多个配置类或使用工厂模式：

```dart
abstract class ApiConfig {
  String get codeField;
  String get dataField;
  String get messageField;
  String get successCode;
  int get unauthorizedCode;
}

class ProjectAConfig extends ApiConfig {
  @override
  String get codeField => 'code';
  // ...
}

class ProjectBConfig extends ApiConfig {
  @override
  String get codeField => 'status';
  // ...
}
```

### Q: 切换项目后需要改哪些文件？

**A:** 只需要修改一个文件：
```
lib/api/config.dart
```

所有使用 `ApiConfig` 的地方会自动适配新的配置。

## 相关文件

- `lib/api/config.dart` - API 配置类定义
- `lib/api/http.dart` - HTTP 服务，使用 ApiConfig 处理响应
- `lib/utils/upload/index.dart` - 上传工具，使用 ApiConfig 处理上传响应
