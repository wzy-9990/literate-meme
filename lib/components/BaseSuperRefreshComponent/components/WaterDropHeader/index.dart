import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 中文版的水滴下拉刷新头部
class ChineseWaterDropHeader extends StatelessWidget {
  const ChineseWaterDropHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WaterDropHeader(
      complete: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.done,
            color: Colors.grey,
          ),
          SizedBox(width: 15.0),
          Text(
            "刷新成功",
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
      failed: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.close,
            color: Colors.grey,
          ),
          SizedBox(width: 15.0),
          Text(
            "刷新失败",
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}