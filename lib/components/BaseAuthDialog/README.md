# BaseAuthDialog

用户认证对话框组件，用于在用户未登录或登录过期时弹出提示并引导用户登录。

## 功能特性

- ✅ 自动检测登录状态
- ✅ 区分未登录和登录过期两种状态
- ✅ 防止重复弹窗
- ✅ 自动跳转登录页面
- ✅ 支持登录结果回调
- ✅ 提供认证状态枚举

## 基础用法

```dart
import 'package:flutter_tem/components/BaseAuthDialog/index.dart';

// 显示认证对话框
final result = await BaseAuthDialog.showAuthDialog();

if (result != null) {
  print('登录成功，返回数据: $result');
  // 处理登录成功后的逻辑
} else {
  print('用户取消登录');
}
```

## API

### BaseAuthDialog 静态方法

#### showAuthDialog

显示认证对话框

```dart
static Future<Map<String, dynamic>?> showAuthDialog({
  bool? isExpired,  // 是否为登录过期状态，null 时自动检测
})
```

**参数说明：**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| isExpired | bool? | null | 是否为登录过期状态，null 时自动检测 |

**返回值：**
- `Map<String, dynamic>?` - 登录成功返回登录页返回的数据，取消返回 null

#### baseCheckAuthStatus

检查用户认证状态

```dart
static Future<bool> baseCheckAuthStatus()
```

**返回值：**
- `true` - 有 token（可能已过期）
- `false` - 无 token（未登录）

#### baseGetAuthStatus

获取用户认证状态枚举

```dart
static Future<BaseAuthStatus> baseGetAuthStatus()
```

**返回值：**
- `BaseAuthStatus.expired` - 有 token 但需要重新验证
- `BaseAuthStatus.notLoggedIn` - 无 token，未登录
- `BaseAuthStatus.loggedIn` - 正常登录（需自行判断）

### BaseAuthStatus 枚举

```dart
enum BaseAuthStatus {
  notLoggedIn,  // 用户未登录
  expired,      // 用户登录已过期
  loggedIn,     // 用户正常登录
}
```

## 使用示例

### 示例1：基础认证检查

```dart
class MyPage extends StatelessWidget {
  Future<void> _doAuthAction() async {
    final result = await BaseAuthDialog.showAuthDialog();

    if (result != null) {
      // 用户已登录，执行需要登录的操作
      await performAuthenticatedAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _doAuthAction,
      child: Text('需要登录的操作'),
    );
  }
}
```

### 示例2：指定过期状态

```dart
// 明确指定为登录过期
final result = await BaseAuthDialog.showAuthDialog(
  isExpired: true,  // 显示"登录已过期"提示
);

// 明确指定为未登录
final result2 = await BaseAuthDialog.showAuthDialog(
  isExpired: false,  // 显示"未登录"提示
);
```

### 示例3：在 API 拦截器中使用

```dart
class ApiInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 登录过期，弹出对话框
      final result = await BaseAuthDialog.showAuthDialog(
        isExpired: true,
      );

      if (result != null) {
        // 重新发起请求
        return handler.resolve(await _retry(err.requestOptions));
      }
    }

    handler.next(err);
  }
}
```

### 示例4：检查认证状态

```dart
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final status = await BaseAuthDialog.baseGetAuthStatus();

    setState(() {
      isLoggedIn = status != BaseAuthStatus.notLoggedIn;
    });

    if (status == BaseAuthStatus.expired) {
      // 登录已过期，显示对话框
      await BaseAuthDialog.showAuthDialog(isExpired: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggedIn
        ? ProfileContent()
        : LoginPrompt(),
    );
  }
}
```

### 示例5：配合 GetX 状态管理

```dart
class UserController extends GetxController {
  final isAuthenticated = false.obs;

  Future<bool> ensureAuthenticated() async {
    final status = await BaseAuthDialog.baseCheckAuthStatus();

    if (!status) {
      final result = await BaseAuthDialog.showAuthDialog();
      if (result != null) {
        isAuthenticated.value = true;
        return true;
      }
      return false;
    }

    return true;
  }

  Future<void> performAction() async {
    if (await ensureAuthenticated()) {
      // 执行需要登录的操作
    }
  }
}
```

## 工作原理

### 状态检测流程

```
1. 调用 showAuthDialog()
   ↓
2. 检查是否已有弹窗 (_isShowingAuthDialog)
   ↓
3. 检测登录状态 (baseCheckAuthStatus)
   ↓
4. 显示对应的提示文案
   - 有 token → "登录已过期"
   - 无 token → "未登录"
   ↓
5. 用户操作
   - 点击"去登录" → 跳转登录页
   - 点击"取消" → 返回 null
   ↓
6. 返回登录结果
```

### 防重复弹窗机制

```dart
static bool _isShowingAuthDialog = false;

if (_isShowingAuthDialog) {
  return null;  // 已有弹窗，直接返回
}
_isShowingAuthDialog = true;
```

## 注意事项

1. **依赖组件**
   - 依赖 `BaseCupertinoAlertDialog` 组件
   - 依赖 `Storage` 工具类读取 token
   - 依赖 `NavigationUtils` 和 `AppRoutes` 路由配置

2. **防重复弹窗**
   - 组件内置防重复弹窗机制
   - 同时只能显示一个认证对话框

3. **状态判断**
   - `baseCheckAuthStatus` 只检查 token 是否存在
   - 不验证 token 有效性
   - 需要配合后端 API 判断真实登录状态

4. **登录页返回值**
   - 登录页需要返回包含用户信息的 Map
   - 取消登录应返回 null

## 自定义配置

### 修改存储键名

修改 `lib/utils/storage/index.dart` 中的 `StorageKeys.token`

### 修改登录路由

修改 `lib/routers/app_routes.dart` 中的 `AppRoutes.login`

### 自定义对话框样式

组件内部使用 `showBaseCupertinoAlertDialog`，可通过修改该组件来自定义样式。

## 相关组件

- [BaseCupertinoAlertDialog](../BaseCupertinoAlertDialog/README.md) - iOS 风格对话框
- Storage - 本地存储工具
- NavigationUtils - 路由导航工具
