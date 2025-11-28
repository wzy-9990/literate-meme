import 'package:flutter_tem/utils/mixin/auth_refresh_mixin.dart';
import 'package:get/get.dart';

/// BaseMixin - 所有页面 Logic 的基础 Mixin
///
/// 统一管理所有页面的通用功能，包括：
/// - 登录后自动刷新（通过 SimpleAuthRefreshMixin）
/// - 将来可能添加的其他通用功能（如埋点、性能监控等）
///
/// 使用方式：
/// ```dart
/// class YourLogic extends GetxController with BaseMixin {
///   void initData() {
///     // 你的初始化逻辑
///   }
/// }
/// ```
///
/// 优势：
/// - 统一管理：所有通用功能集中在一个地方
/// - 易于维护：修改或添加功能只需改这一个文件
/// - 自动继承：所有使用 BaseMixin 的页面自动获得新功能
mixin BaseMixin on GetxController implements SimpleAuthRefreshMixin {
  @override
  bool get enableAuthRefresh => throw UnimplementedError();
}
