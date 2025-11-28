# 登录后自动刷新功能说明

## 功能概述

当用户在需要登录的页面（如消息页面）处于未登录状态，登录成功后会自动刷新该页面的数据，无需手动刷新。

## 工作原理

### 1. 登录流程

```
用户在消息页面（未登录）
    ↓
点击"去登录"按钮
    ↓
跳转到登录页面
    ↓
输入账号密码，点击登录
    ↓
登录成功，返回消息页面
    ↓
🔄 自动刷新消息数据
    ↓
显示最新消息列表
```

### 2. 技术实现

#### 核心组件

1. **LoginLogic** (`lib/page/user/login/logic.dart`)
   - 登录成功后调用 `IndexLogic.updateToken()`
   - 更新用户登录状态

2. **IndexLogic** (`lib/page/index/logic.dart`)
   - 维护响应式 token 变量
   - token 变化时触发监听器

3. **BasePullToRefreshList** (`lib/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart`)
   - 监听 token 变化
   - 检测到从未登录变为已登录时，自动调用 `onRefresh()`

#### 关键代码

**1. 登录成功更新 token**
```dart
// lib/page/user/login/logic.dart
Future<void> loginButtonClick() async {
  final data = await loginApi(params);
  await Storage.setMap(StorageKeys.userInfo, data);

  // 同步更新首页 token（触发监听器）
  if (Get.isRegistered<IndexLogic>()) {
    Get.find<IndexLogic>().updateToken(data['accessToken']?.toString());
  }

  EasyLoading.showToast('登录成功');
  Get.back(result: {'login': true, 'msg': '用户已完成登录'});
}
```

**2. Token 监听和状态更新**
```dart
// lib/page/index/logic.dart
void updateToken(String? value) async {
  final newToken = value ?? '';
  final wasEmpty = token.value.isEmpty;
  token.value = newToken; // 触发 token 监听器
  await Storage.setString(StorageKeys.token, newToken);

  // 登录后，自动刷新消息列表（若已初始化）
  if (newToken.isNotEmpty && wasEmpty) {
    _getMessageLogic()?.initData();
  }
}
```

**3. 自动刷新机制**
```dart
// lib/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart
void _setupAuthListener() {
  if (Get.isRegistered<IndexLogic>()) {
    final indexLogic = Get.find<IndexLogic>();
    _autoUnAuth = !indexLogic.isLoggedIn;
    _wasUnAuthed = _autoUnAuth ?? false;

    _tokenSub = indexLogic.token.listen((value) {
      if (!mounted) return;

      final bool isCurrentlyUnAuthed = value.isEmpty;

      // 检测到从未登录变为已登录（登录成功）
      if (_wasUnAuthed && !isCurrentlyUnAuthed) {
        debugPrint('🔄 检测到登录状态变化：未登录 -> 已登录，自动刷新数据');

        // 延迟执行，确保 UI 更新完成
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.onRefresh != null) {
            widget.onRefresh!();
          }
        });
      }

      // 更新状态
      setState(() {
        _autoUnAuth = isCurrentlyUnAuthed;
        _wasUnAuthed = isCurrentlyUnAuthed;
      });
    });
  }
}
```

## 使用方法

根据页面类型，选择合适的方案：

### 方案1：列表页面 - 使用 BasePullToRefreshList

适用于使用下拉刷新的列表页面（如消息列表、订单列表等）：

```dart
BasePullToRefreshList(
  refreshController: logic.refreshController,
  onRefresh: logic.onRefresh,
  onLoadMore: logic.onLoadMore,
  requireAuth: true, // ✅ 启用登录检测和自动刷新
  emptyTitle: '暂无消息',
  children: logic.items.map((item) => ItemWidget(item)).toList(),
)
```

### 方案2：普通页面 - 使用 SimpleAuthRefreshMixin

适用于修改密码、个人信息等普通页面：

```dart
import 'package:flutter_tem/utils/base/auth_refresh_mixin.dart';

class ChangePasswordLogic extends GetxController
    with SimpleAuthRefreshMixin {

  @override
  void initData() {
    // 登录后会自动调用此方法刷新数据
    loadUserInfo();
    loadSettings();
  }
}
```

### 方案3：自定义刷新逻辑 - 使用 AuthRefreshMixin

适用于需要自定义刷新逻辑的页面：

```dart
import 'package:flutter_tem/utils/base/auth_refresh_mixin.dart';

class MyPageLogic extends GetxController with AuthRefreshMixin {

  @override
  Future<void> onAuthRefresh() async {
    // 登录后的自定义刷新逻辑
    EasyLoading.show();
    await refreshData();
    await updateStatus();
    EasyLoading.dismiss();
    EasyLoading.showSuccess('数据已刷新');
  }
}
```

### 禁用自动刷新

如果某些页面不需要登录后自动刷新：

```dart
class MyPageLogic extends GetxController with SimpleAuthRefreshMixin {

  @override
  bool get enableAuthRefresh => false; // 禁用自动刷新

  void initData() {
    // 正常加载数据
  }
}
```

## 三重保障机制

为了确保登录后页面数据能够及时刷新，系统提供了三种机制：

1. **列表页面自动刷新**（BasePullToRefreshList）
   - 适用于所有设置 `requireAuth: true` 的列表页面
   - 监听 token 变化，自动调用 `onRefresh()`

2. **普通页面自动刷新**（AuthRefreshMixin / SimpleAuthRefreshMixin）
   - 适用于非列表页面（如修改密码、个人信息等）
   - 监听 token 变化，自动调用自定义刷新方法

3. **消息页专属刷新**（IndexLogic）
   - 额外调用 `messageLogic.initData()` 确保消息页面刷新
   - 作为后备机制，提高可靠性

## 适用场景

### 列表页面
✅ 消息列表
✅ 订单列表
✅ 通知列表
✅ 任何使用 BasePullToRefreshList 的页面

### 普通页面
✅ 修改密码页面
✅ 个人信息页面
✅ 账号设置页面
✅ 任何需要登录后刷新数据的页面

## 注意事项

### 对于 BasePullToRefreshList

1. **requireAuth 参数**
   - 设置为 `true` 时启用登录检测和自动刷新
   - 设置为 `false`（默认）时不检测登录状态

2. **onRefresh 回调**
   - 必须提供 `onRefresh` 回调函数
   - 登录后会自动调用此函数刷新数据

### 对于 Mixin

1. **方法实现**
   - `SimpleAuthRefreshMixin` 需要实现 `initData()` 方法
   - `AuthRefreshMixin` 需要实现 `onAuthRefresh()` 方法

2. **状态管理**
   - 确保 IndexLogic 已注册（通常在主页初始化）
   - 使用 GetX 的状态管理机制

3. **延迟执行**
   - 使用 100ms 延迟确保 UI 更新完成后再刷新数据
   - 避免状态冲突

## 调试信息

登录成功后，控制台会输出：

```
🔄 [MessageLogic] 检测到登录状态变化：未登录 -> 已登录，自动刷新数据
🔄 [ChangePasswordLogic] 检测到登录成功，自动调用 initData()
```

## 相关文件

### 核心文件
- `lib/page/user/login/logic.dart` - 登录逻辑
- `lib/page/index/logic.dart` - 主页逻辑（token 管理）
- `lib/utils/base/auth_refresh_mixin.dart` - 登录刷新 Mixin

### 组件文件
- `lib/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart` - 刷新组件

### 示例页面
- `lib/page/index/modules/message/logic.dart` - 消息页面逻辑（列表页面示例）
- `lib/page/index/modules/my/setting/changePassword/logic.dart` - 修改密码页面逻辑（普通页面示例）

## 完整示例

### 示例1：消息列表页面

```dart
// logic.dart
class MessageLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(...) async {
    final response = await listMessagesApi(params);
    return PaginationResponse.fromMap(response);
  }
}

// view.dart
BasePullToRefreshList(
  refreshController: logic.refreshController,
  onRefresh: logic.onRefresh,
  onLoadMore: logic.onLoadMore,
  requireAuth: true, // ✅ 启用自动刷新
  children: logic.items.map((item) => MessageItem(item)).toList(),
)
```

### 示例2：修改密码页面

```dart
// logic.dart
class ChangePasswordLogic extends GetxController
    with SimpleAuthRefreshMixin {

  @override
  void initData() {
    // 登录后自动刷新
    loadUserInfo();
    loadSecuritySettings();
  }

  Future<void> loadUserInfo() async {
    final info = await getUserInfoApi();
    // 更新状态...
  }
}
```

### 示例3：自定义刷新逻辑

```dart
// logic.dart
class ProfileLogic extends GetxController with AuthRefreshMixin {

  @override
  Future<void> onAuthRefresh() async {
    // 登录后执行多个刷新操作
    EasyLoading.show();
    await loadUserInfo();
    await loadStatistics();
    await refreshBadges();
    EasyLoading.dismiss();
  }
}
