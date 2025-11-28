import 'package:flutter_tem/utils/base/base_pagination_logic.dart';

class PullToRefreshExampleLogic extends BasePaginationLogic<String> {
  @override
  Future<List<String>> fetchData(int page, int size) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1000));

    // 模拟数据，最多5页（100条）
    if (page > 5) {
      return [];
    }

    // 模拟数据
    return List.generate(
      size,
      (index) => 'Item ${(page - 1) * size + index + 1}',
    );
  }
}
