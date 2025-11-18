# BasePaginationLogic 使用文档

## 📚 简介

`BasePaginationLogic` 是一个通用的分页逻辑基类，封装了所有常见的分页操作，让你只需关注业务逻辑和接口调用。

## ✨ 特性

- ✅ 自动处理加载状态（loading）
- ✅ 内置下拉刷新、上拉加载更多
- ✅ 智能判断是否还有更多数据
- ✅ 支持搜索参数
- ✅ 自动处理空数据状态
- ✅ 详细的调试日志
- ✅ 自动资源释放（dispose）

## 📦 代码量对比

| 使用前 | 使用后 | 减少 |
|--------|--------|------|
| 140+ 行 | 60 行 | 57% |

## 🚀 快速开始

### 1. 创建 Logic 类

继承 `BasePaginationLogic`，只需实现一个方法：

```dart
import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/base/base_pagination_logic.dart';

class UserListLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  ) async {
    // 1. 构建请求参数
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      'organizationId': '0',
      ...?searchParams, // 合并搜索参数
    };

    // 2. 调用接口
    final response = await yourApi(params);

    // 3. 解析并返回结果
    if (response == null) {
      return PaginationResponse(records: [], total: 0, pages: 0);
    }

    if (response is Map) {
      return PaginationResponse.fromMap(
        response,
        (item) => Map<String, dynamic>.from(item),
      );
    }

    return PaginationResponse(records: [], total: 0, pages: 0);
  }
}
```

### 2. 在 View 中使用

```dart
class UserListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(UserListLogic());

    return Scaffold(
      body: Obx(
        () => BasePullToRefreshList(
          refreshController: logic.refreshController,
          onRefresh: logic.onRefresh,
          onLoadMore: logic.onLoadMore,
          children: logic.items.map((item) {
            return ListTile(
              title: Text(item['userName']),
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

## 🎯 自动功能

继承基类后，你自动获得以下功能：

### 1. 首次加载

```dart
// 页面进入时自动加载第1页数据
// 自动显示 loading 状态
```

### 2. 下拉刷新

```dart
// 用户下拉时调用
logic.onRefresh();  // 自动重置到第1页
```

### 3. 上拉加载更多

```dart
// 滚动到底部时调用
logic.onLoadMore();  // 自动加载下一页
// 到达最后一页时自动显示 "没有更多了"
```

### 4. 搜索功能

```dart
// 不带参数的搜索
logic.search();

// 带搜索参数
logic.search({'userName': '张三', 'status': 'active'});

// 自定义搜索方法（推荐）
void searchUser(String keyword) {
  final params = keyword.isEmpty ? null : {'userName': keyword};
  search(params);
}
```

## 📊 响应格式支持

基类支持多种API响应格式：

### 格式1：标准分页格式（推荐）

```json
{
  "code": "1",
  "data": {
    "records": [...],
    "total": 530,
    "pages": 36,
    "size": 15,
    "current": 1
  }
}
```

### 格式2：简单分页格式

```json
{
  "code": "1",
  "data": {
    "list": [...],
    "total": 100
  }
}
```

### 格式3：直接返回数组

```json
{
  "code": "1",
  "data": [...]
}
```

## 🔧 可配置选项

### 1. 自定义每页数量

```dart
class UserListLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  int get pageSize => 20;  // 默认15，可以覆盖
}
```

### 2. 获取分页信息

```dart
final logic = Get.find<UserListLogic>();

print('总记录数: ${logic.total}');       // 530
print('总页数: ${logic.totalPages}');    // 36
print('当前数据量: ${logic.items.length}'); // 15
```

## 📝 完整示例

### 1. 用户列表（带搜索）

```dart
// logic.dart
class UserListLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page, int pageSize, Map<String, dynamic>? searchParams
  ) async {
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      ...?searchParams,
    };

    final response = await listPageUserByOrganizationIdApi(params);

    if (response == null) {
      return PaginationResponse(records: [], total: 0, pages: 0);
    }

    return PaginationResponse.fromMap(
      response,
      (item) => Map<String, dynamic>.from(item),
    );
  }

  void searchUser(String keyword) {
    final params = keyword.isEmpty ? null : {'userName': keyword};
    search(params);
  }
}

// view.dart
class UserListView extends StatefulWidget {
  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(UserListLogic());

    return Scaffold(
      appBar: AppBar(title: Text('用户列表')),
      body: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: '搜索用户'),
            onSubmitted: (value) => logic.searchUser(value),
          ),
          // 列表
          Expanded(
            child: Stack(
              children: [
                Obx(() => BasePullToRefreshList(
                  refreshController: logic.refreshController,
                  onRefresh: logic.onRefresh,
                  onLoadMore: logic.onLoadMore,
                  children: logic.items.map((item) {
                    return ListTile(
                      title: Text(item['userName'] ?? ''),
                      subtitle: Text(item['mobile'] ?? ''),
                    );
                  }).toList(),
                )),
                Obx(() => logic.isLoading.value
                  ? BaseLoading()
                  : SizedBox.shrink()
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 订单列表

```dart
class OrderListLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page, int pageSize, Map<String, dynamic>? searchParams
  ) async {
    final params = {
      'page': page,
      'limit': pageSize,
      ...?searchParams,
    };

    final response = await getOrderListApi(params);

    return PaginationResponse.fromMap(
      response,
      (item) => Map<String, dynamic>.from(item),
    );
  }

  void filterByStatus(String status) {
    search({'status': status});
  }
}
```

### 3. 商品列表

```dart
class ProductListLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  int get pageSize => 10;  // 每页10条

  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page, int pageSize, Map<String, dynamic>? searchParams
  ) async {
    final response = await getProductListApi(
      page: page,
      pageSize: pageSize,
      keyword: searchParams?['keyword'],
      categoryId: searchParams?['categoryId'],
    );

    return PaginationResponse(
      records: response['items'],
      total: response['totalCount'],
      pages: response['totalPages'],
    );
  }

  void searchProduct(String keyword) {
    search({'keyword': keyword});
  }

  void filterByCategory(String categoryId) {
    search({'categoryId': categoryId});
  }
}
```

## 🐛 调试日志

基类会自动输出详细的日志：

```
⏩ 开始加载数据，页码: 1，每页: 15，搜索参数: {userName: 张三}
✅ 加载了 15 条数据，当前共 15 条，总共 530 条，第 1/36 页
✅ 加载完成，还有更多数据

⏩ 开始加载数据，页码: 2，每页: 15，搜索参数: {userName: 张三}
✅ 加载了 15 条数据，当前共 30 条，总共 530 条，第 2/36 页
✅ 加载完成，还有更多数据

⏩ 开始加载数据，页码: 36，每页: 15，搜索参数: null
✅ 加载了 5 条数据，当前共 530 条，总共 530 条，第 36/36 页
✅ 加载完成，没有更多数据了
```

## ⚠️ 注意事项

1. **数据类型**：泛型 `T` 可以是任何类型（Map、Model类等）
2. **错误处理**：网络错误已在拦截器中处理，无需重复处理
3. **资源释放**：基类自动 dispose，无需手动处理
4. **空数据**：搜索无结果时自动显示空页面

## 🎓 进阶用法

### 1. 使用 Model 类

```dart
class User {
  final String id;
  final String name;

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'];
}

class UserListLogic extends BasePaginationLogic<User> {
  @override
  Future<PaginationResponse<User>> fetchData(...) async {
    final response = await yourApi(params);

    return PaginationResponse.fromMap(
      response,
      (item) => User.fromJson(item),  // 转换为 Model
    );
  }
}
```

### 2. 自定义加载逻辑

```dart
class CustomLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<void> loadData() async {
    // 加载前的自定义逻辑
    print('开始加载...');

    await super.loadData();

    // 加载后的自定义逻辑
    print('加载完成！');
  }
}
```

## 📖 相关文档

- [GetX 文档](https://pub.dev/packages/get)
- [pull_to_refresh 文档](https://pub.dev/packages/pull_to_refresh)

## 🤝 贡献

如果你有更好的建议或发现问题，欢迎提交 Issue 或 PR！
