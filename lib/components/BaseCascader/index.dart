import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/api/modules/common.dart';
import 'package:flutter_tem/components/BaseEmpty/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';

/// 级联节点
class BaseCascaderNode {
  final String id;
  final String label;
  final List<BaseCascaderNode> children;

  /// 是否可选（优先级高于全局 selectableLevels）
  final bool? selectable;

  const BaseCascaderNode({
    required this.id,
    required this.label,
    this.children = const [],
    this.selectable,
  });
}

/// 级联选择弹窗（省市县三级联动）
class BaseCascaderPicker extends StatefulWidget {
  const BaseCascaderPicker({
    this.options,
    super.key,
    this.title = '选择地区',
    this.multiSelect = false,
    this.maxSelectCount = 3,
    this.selectableLevels = const {3},
    this.initialSelectedIds = const [],
    this.showAllEntry = false,
    this.showPathBreadcrumb = false,
    this.onConfirm,
  });

  /// 选项数据（省 -> 市 -> 县）
  final List<BaseCascaderNode>? options;

  /// 标题
  final String title;

  /// 是否多选
  final bool multiSelect;

  /// 多选最多选择数量
  final int maxSelectCount;

  /// 哪些层级可选（1=省，2=市，3=县），节点 selectable=true 也可选
  final Set<int> selectableLevels;

  /// 初始选中 ID 列表
  final List<String> initialSelectedIds;

  /// 是否展示“全国/全省/全市”快捷入口
  final bool showAllEntry;

  /// 是否显示顶部路径面包屑（省/市/区标签）
  final bool showPathBreadcrumb;

  /// 确认回调
  /// 返回的每一项包含：provinceName/provinceCode/cityName/cityCode/districtName/districtCode
  final void Function(List<Map<String, String?>> selected)? onConfirm;

  @override
  State<BaseCascaderPicker> createState() => _BaseCascaderPickerState();
}

class _BaseCascaderPickerState extends State<BaseCascaderPicker> {
  int? _provinceIndex;
  int? _cityIndex;
  int? _districtIndex;

  bool _loading = false;
  String _error = '';

  List<BaseCascaderNode> _options = [];

  late final Set<String> _selectedIds = widget.initialSelectedIds.toSet();

  String _searchText = '';
  List<_SearchHit> _searchHits = [];

  List<BaseCascaderNode> get _provinces => _options;

  List<BaseCascaderNode> get _cities {
    if (_provinceIndex == null) return [];
    return _provinces[_provinceIndex!].children;
  }

  List<BaseCascaderNode> get _districts {
    if (_cityIndex == null) return [];
    return _cities[_cityIndex!].children;
  }

  String get _provinceLabel =>
      (_provinceIndex != null) ? _provinces[_provinceIndex!].label : '省';
  String get _cityLabel =>
      (_cityIndex != null) ? _cities[_cityIndex!].label : '市';
  String get _districtLabel =>
      (_districtIndex != null) ? _districts[_districtIndex!].label : '区/县';

  List<BaseCascaderNode> get _selectedNodes => _collectSelected();

  bool _canSelect(BaseCascaderNode node, int level) {
    // 仅叶子可选，除非节点 selectable=true 强制允许
    if (node.children.isNotEmpty) return false;
    if (node.selectable != null) return node.selectable!;
    return widget.selectableLevels.contains(level);
  }

  void _toggleSelect(BaseCascaderNode node, int level) {
    if (!_canSelect(node, level)) return;
    setState(() {
      if (_selectedIds.contains(node.id)) {
        _selectedIds.remove(node.id);
      } else {
        if (!widget.multiSelect) {
          _selectedIds
            ..clear()
            ..add(node.id);
        } else {
          if (_selectedIds.length >= widget.maxSelectCount) {
            EasyLoading.showToast(
              '最多选择${widget.maxSelectCount}项',
            );
            return;
          }
          _selectedIds.add(node.id);
        }
      }
    });
  }

  List<BaseCascaderNode> _collectSelected() {
    final List<BaseCascaderNode> result = [];
    void walk(List<BaseCascaderNode> list) {
      for (final node in list) {
        if (_selectedIds.contains(node.id)) {
          result.add(node);
        }
        if (node.children.isNotEmpty) {
          walk(node.children);
        }
      }
    }

    walk(_options);
    return result;
  }

  List<List<BaseCascaderNode>> _collectSelectedPaths() {
    final List<List<BaseCascaderNode>> result = [];

    void walk(List<BaseCascaderNode> list, List<BaseCascaderNode> path) {
      for (final node in list) {
        final currentPath = [...path, node];
        final level = currentPath.length;
        if (_selectedIds.contains(node.id) && _canSelect(node, level)) {
          result.add(currentPath);
        }
        if (node.children.isNotEmpty) {
          walk(node.children, currentPath);
        }
      }
    }

    walk(_options, []);
    return result;
  }

  List<Map<String, String?>> _collectSelectedObjects() {
    final paths = _collectSelectedPaths();
    final List<Map<String, String?>> result = [];

    for (final path in paths) {
      final province = path.isNotEmpty ? path[0] : null;
      final city = path.length > 1 ? path[1] : null;
      final district = path.length > 2 ? path[2] : null;
      result.add({
        'provinceName': province?.label,
        'provinceCode': province?.id,
        'cityName': city?.label,
        'cityCode': city?.id,
        'districtName': district?.label,
        'districtCode': district?.id,
      });
    }

    return result;
  }

  void _applyInitialSelection() {
    if (widget.initialSelectedIds.isEmpty || _options.isEmpty) return;
    _selectedIds.addAll(widget.initialSelectedIds);
    final lastId = widget.initialSelectedIds.last;
    final path = _findPathById(_options, lastId);
    if (path != null) {
      _setPath(path, triggerSetState: false);
    }
  }

  List<BaseCascaderNode>? _findPathById(
      List<BaseCascaderNode> nodes, String targetId,
      [List<BaseCascaderNode> path = const []]) {
    for (final node in nodes) {
      final currentPath = [...path, node];
      if (node.id == targetId) {
        return currentPath;
      }
      if (node.children.isNotEmpty) {
        final found = _findPathById(node.children, targetId, currentPath);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _updateSearch(String value) {
    setState(() {
      _searchText = value.trim();
      _searchHits =
          _searchText.isEmpty ? [] : _searchNodes(_options, _searchText);
    });
  }

  @override
  void initState() {
    super.initState();
    _initOptions();
  }

  Future<void> _initOptions() async {
    if (widget.options != null && widget.options!.isNotEmpty) {
      _options = widget.options!;
      _applyInitialSelection();
      setState(() {});
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await getAreaConfigApi(type: 1);
      if (data is List) {
        _options = _injectAllOptions(data.map((e) => _mapNode(e)).toList());
      } else if (data is Map && data['data'] is List) {
        _options = _injectAllOptions(
            (data['data'] as List).map((e) => _mapNode(e)).toList());
      } else {
        _error = '未获取到地区数据';
      }
      _applyInitialSelection();
    } catch (e) {
      _error = '获取地区失败';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  BaseCascaderNode _mapNode(dynamic json) {
    final children = <BaseCascaderNode>[];
    if (json is Map && json['children'] is List) {
      for (final child in json['children'] as List) {
        children.add(_mapNode(child));
      }
    }
    return BaseCascaderNode(
      id: json['code']?.toString() ?? '',
      label: json['name']?.toString() ?? '',
      children: children,
    );
  }

  List<BaseCascaderNode> _injectAllOptions(List<BaseCascaderNode> provinces) {
    if (!widget.showAllEntry) return provinces;

    // 顶部添加“全国”
    final List<BaseCascaderNode> result = [
      const BaseCascaderNode(
        id: 'all_country',
        label: '全国',
      ),
      ...provinces
    ];

    // 为省级添加“全<省名>”，为市级添加“全<市名>”
    for (int i = 0; i < result.length; i++) {
      final province = result[i];
      if (province.children.isEmpty) continue;
      final newCities = <BaseCascaderNode>[
        BaseCascaderNode(
          id: '${province.id}_all_province',
          label: '全${province.label}',
        ),
        ...province.children,
      ];
      final patchedCities = <BaseCascaderNode>[];
      for (final city in newCities) {
        if (city.children.isEmpty) {
          patchedCities.add(city);
        } else {
          patchedCities.add(
            BaseCascaderNode(
              id: city.id,
              label: city.label,
              children: [
                BaseCascaderNode(
                  id: '${city.id}_all_city',
                  label: '全${city.label}',
                ),
                ...city.children,
              ],
            ),
          );
        }
      }
      result[i] = BaseCascaderNode(
        id: province.id,
        label: province.label,
        children: patchedCities,
      );
    }

    return result;
  }

  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 420,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: BaseLoading(message: '加载中...'),
        ),
      );
    }

    if (_options.isEmpty && _error.isEmpty) {
      // 初始未加载
      return const SizedBox(
        height: 420,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: BaseLoading(message: '加载中...'),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SizedBox(
        height: 420,
        child: Center(
          child: BaseEmpty(
            title: _error,
            buttonText: '重试',
            onButtonPressed: _initOptions,
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildPathBar(),
            _buildSearchBar(),
            const Divider(height: 1),
            SizedBox(
              height: 360,
              child: _searchText.isEmpty
                  ? Row(
                      children: [
                        _buildList(_provinces, _provinceIndex, 1, onTap: (i) {
                          setState(() {
                            _provinceIndex = i;
                            _cityIndex = null;
                            _districtIndex = null;
                          });
                        }),
                        _buildList(_cities, _cityIndex, 2, onTap: (i) {
                          setState(() {
                            _cityIndex = i;
                            _districtIndex = null;
                          });
                        }),
                        _buildList(_districts, _districtIndex, 3,
                            onTap: (i) => setState(() => _districtIndex = i)),
                      ],
                    )
                  : _buildSearchResult(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '取消',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _provinceIndex = null;
                        _cityIndex = null;
                        _districtIndex = null;
                        _selectedIds.clear();
                        _searchText = '';
                        _searchHits.clear();
                      });
                    },
                    child: const Text(
                      '清空',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final selected = _collectSelected();
                      if (selected.isEmpty) {
                        EasyLoading.showToast('请至少选择一个地区');
                        return;
                      }
                      final payload = _collectSelectedObjects();
                      widget.onConfirm?.call(payload);
                      Navigator.of(context).pop(payload);
                    },
                    child: Text(
                      '完成',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showPathBreadcrumb) ...[
            Row(
              children: [
                _buildPathChip(_provinceLabel,
                    isActive: _provinceIndex != null),
                const SizedBox(width: 8),
                _buildPathChip(_cityLabel, isActive: _cityIndex != null),
                const SizedBox(width: 8),
                _buildPathChip(_districtLabel,
                    isActive: _districtIndex != null),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_selectedNodes.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedNodes
                    .map(
                      (node) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: CupertinoColors.systemGrey4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              node.label,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIds.remove(node.id);
                                });
                              },
                              child: const Icon(
                                CupertinoIcons.xmark_circle_fill,
                                size: 16,
                                color: CupertinoColors.systemGrey,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPathChip(String text, {bool isActive = false}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? primaryColor : Colors.transparent,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: CupertinoSearchTextField(
        placeholder: '搜索省/市/县',
        onChanged: _updateSearch,
        onSubmitted: _updateSearch,
        controller: TextEditingController(text: _searchText),
      ),
    );
  }

  Widget _buildList(
    List<BaseCascaderNode> list,
    int? currentIndex,
    int level, {
    required ValueChanged<int> onTap,
  }) {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, index) {
          final primaryColor = Theme.of(context).colorScheme.primary;
          final node = list[index];
          final selected = _selectedIds.contains(node.id);
          final isActive = currentIndex == index;
          final canSelect = _canSelect(node, level);

          return InkWell(
            onTap: () {
              onTap(index);
              // 单选直接选择；多选也允许整行点击切换
              if (canSelect) {
                _toggleSelect(node, level);
              }
            },
            child: Container(
              color: isActive ? CupertinoColors.systemGrey6 : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.multiSelect)
                    GestureDetector(
                      onTap:
                          canSelect ? () => _toggleSelect(node, level) : null,
                      child: Icon(
                        selected
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        color: canSelect
                            ? primaryColor
                            : CupertinoColors.systemGrey,
                        size: 20,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      node.label,
                      style: TextStyle(
                        color: canSelect ? Colors.black87 : Colors.grey,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  if (node.children.isNotEmpty)
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_searchHits.isEmpty) {
      return const BaseEmpty(
        title: '未找到结果',
        subtitle: '换个关键词试试',
      );
    }
    return ListView.builder(
      itemCount: _searchHits.length,
      itemBuilder: (_, index) {
        final hit = _searchHits[index];
        final node = hit.node;
        final canSelect = _canSelect(node, hit.level);

        return ListTile(
          onTap: () {
            _setPath(hit.pathNodes);
            if (canSelect) {
              _toggleSelect(node, hit.level);
            }
            // 同步高亮省市
            _provinceIndex = _options
                .indexWhere((element) => element.id == hit.pathNodes.first.id);
            if (_provinceIndex != null &&
                _provinceIndex! >= 0 &&
                hit.pathNodes.length > 1) {
              _cityIndex = _provinces[_provinceIndex!]
                  .children
                  .indexWhere((element) => element.id == hit.pathNodes[1].id);
            }
            _searchText = '';
            _searchHits.clear();
          },
          title: _buildHighlightText(
            hit.pathLabel,
            _searchText,
            color: Colors.black87,
            highlightColor: Colors.orange,
            isBold: false,
          ),
        );
      },
    );
  }

  void _setPath(List<BaseCascaderNode> path, {bool triggerSetState = true}) {
    if (path.isEmpty) return;
    _provinceIndex = _options.indexWhere((element) => element.id == path[0].id);
    if (_provinceIndex != null && _provinceIndex! >= 0 && path.length > 1) {
      _cityIndex = _provinces[_provinceIndex!]
          .children
          .indexWhere((element) => element.id == path[1].id);
    } else {
      _cityIndex = null;
    }
    if (_cityIndex != null &&
        _cityIndex! >= 0 &&
        path.length > 2 &&
        _cities.isNotEmpty) {
      _districtIndex = _cities[_cityIndex!]
          .children
          .indexWhere((element) => element.id == path[2].id);
    } else {
      _districtIndex = null;
    }
    if (triggerSetState) {
      setState(() {});
    }
  }

  Widget _buildHighlightText(
    String text,
    String keyword, {
    Color color = Colors.black87,
    Color highlightColor = Colors.orange,
    bool isBold = false,
  }) {
    if (keyword.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: isBold ? FontWeight.w600 : null,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerKey = keyword.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index = lowerText.indexOf(lowerKey);
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.w600 : null,
          ),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + lowerKey.length),
        style: TextStyle(
          color: highlightColor,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = index + lowerKey.length;
      index = lowerText.indexOf(lowerKey, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(
          color: color,
          fontWeight: isBold ? FontWeight.w600 : null,
        ),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  List<_SearchHit> _searchNodes(List<BaseCascaderNode> nodes, String keyword) {
    final lowerKey = keyword.toLowerCase();
    final hits = <_SearchHit>[];

    void walk(List<BaseCascaderNode> list, int level, List<String> pathLabels,
        List<BaseCascaderNode> pathNodes) {
      for (final node in list) {
        final currentPathLabels = [...pathLabels, node.label];
        final currentPathNodes = [...pathNodes, node];
        if (node.label.toLowerCase().contains(lowerKey)) {
          hits.add(_SearchHit(
            node: node,
            level: level,
            pathLabel: currentPathLabels.join(' / '),
            pathNodes: currentPathNodes,
          ));
        }
        if (node.children.isNotEmpty) {
          walk(node.children, level + 1, currentPathLabels, currentPathNodes);
        }
      }
    }

    walk(nodes, 1, [], []);
    return hits;
  }
}

class _SearchHit {
  final BaseCascaderNode node;
  final int level;
  final String pathLabel;
  final List<BaseCascaderNode> pathNodes;

  _SearchHit({
    required this.node,
    required this.level,
    required this.pathLabel,
    required this.pathNodes,
  });
}

/// 便捷方法：展示三级联动弹窗，返回选中的节点
Future<List<Map<String, String?>>?> showCascaderPicker(
  BuildContext context, {
  List<BaseCascaderNode>? options,
  bool multiSelect = false,
  bool showAllEntry = false,
  Set<int> selectableLevels = const {3},
  List<String> initialSelectedIds = const [],
  String title = '选择地区',
}) {
  return showModalBottomSheet<List<Map<String, String?>>>(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return BaseCascaderPicker(
        options: options,
        multiSelect: multiSelect,
        showAllEntry: showAllEntry,
        selectableLevels: selectableLevels,
        initialSelectedIds: initialSelectedIds,
        title: title,
      );
    },
  );
}
