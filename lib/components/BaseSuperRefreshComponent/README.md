# BaseSuperRefreshComponent

超级刷新组件，集成下拉刷新、上拉加载、空页面和加载状态处理。

## 功能特性

- ✅ 下拉刷新
- ✅ 上拉加载更多
- ✅ 空页面展示
- ✅ 加载中状态
- ✅ 中文水滴头部
- ✅ SuperRefreshListComponent 列表专用版本

## 基础用法

```dart
import 'package:flutter_tem/components/BaseSuperRefreshComponent/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final refreshController = RefreshController();
  bool isLoading = false;
  bool isEmpty = false;

  Future<void> _onRefresh() async {
    await loadData();
    refreshController.refreshCompleted();
  }

  Future<void> _onLoadMore() async {
    await loadMoreData();
    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SuperRefreshComponent(
      refreshController: refreshController,
      onRefresh: _onRefresh,
      onLoadMore: _onLoadMore,
      showLoading: isLoading,
      showEmpty: isEmpty,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ItemWidget(items[index]),
      ),
    );
  }
}
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget | - | 必需，子组件 |
| refreshController | RefreshController | - | 必需，刷新控制器 |
| onRefresh | VoidCallback? | null | 下拉刷新回调 |
| onLoadMore | VoidCallback? | null | 上拉加载回调 |
| enablePullDown | bool | true | 是否启用下拉刷新 |
| enablePullUp | bool | true | 是否启用上拉加载 |
| showEmpty | bool | false | 是否显示空页面 |
| showLoading | bool | false | 是否显示加载中 |
| noMoreText | String | '没有更多了～' | 无更多数据提示 |
| noDataText | String | '暂无数据' | 空数据提示 |

## 使用示例

### 示例1：列表刷新

```dart
class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final refreshController = RefreshController();
  List<Item> items = [];
  bool isLoading = true;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchItems(page: 1);
      setState(() {
        items = data;
        isLoading = false;
        page = 1;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    try {
      final data = await fetchItems(page: 1);
      setState(() {
        items = data;
        page = 1;
      });
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  Future<void> _onLoadMore() async {
    try {
      final data = await fetchItems(page: page + 1);
      if (data.isEmpty) {
        refreshController.loadNoData();
      } else {
        setState(() {
          items.addAll(data);
          page++;
        });
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('列表')),
      body: SuperRefreshComponent(
        refreshController: refreshController,
        onRefresh: _onRefresh,
        onLoadMore: _onLoadMore,
        showLoading: isLoading,
        showEmpty: !isLoading && items.isEmpty,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ItemTile(items[index]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}
```

### 示例2：使用 SuperRefreshListComponent

```dart
SuperRefreshListComponent(
  refreshController: refreshController,
  onRefresh: _onRefresh,
  onLoadMore: _onLoadMore,
  showLoading: isLoading,
  showEmpty: isEmpty,
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

## RefreshController 状态控制

```dart
// 刷新完成
refreshController.refreshCompleted();

// 刷新失败
refreshController.refreshFailed();

// 加载完成
refreshController.loadComplete();

// 加载失败
refreshController.loadFailed();

// 没有更多数据
refreshController.loadNoData();
```

## 注意事项

1. **controller 管理**
   - 必须在 dispose 时释放：`refreshController.dispose()`

2. **状态控制**
   - 刷新/加载完成后必须调用对应的完成方法
   - 否则会一直处于加载状态

3. **空页面判断**
   - showEmpty 通常在非加载状态且数据为空时设为 true

## 相关组件

- SmartRefresher - 底层刷新组件
- [BaseLoading](../BaseLoading/README.md) - 加载组件
- [BaseEmpty](../BaseEmpty/README.md) - 空状态组件
