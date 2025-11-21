import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/utils/permission/index.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

/// 图片保存工具类
class ImageSaver {
  /// 保存网络图片到本地相册
  static Future<bool> saveNetworkImage(String imageUrl,
      {String? fileName}) async {
    try {
      // 请求相册权限
      if (await PermissionUtil.requestPhotos()) {
        EasyLoading.show(status: '保存中...');

        // 使用 Dio 下载图片
        final response = await Dio().get(
          imageUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );

        if (response.statusCode == 200) {
          final bytes = Uint8List.fromList(response.data);
          await _saveImageToGallery(bytes, fileName);
          EasyLoading.dismiss();
          EasyLoading.showSuccess('保存成功');
          return true;
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError('下载失败');
          return false;
        }
      } else {
        EasyLoading.dismiss();
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();

      return false;
    }
  }

  /// 保存本地图片到相册
  static Future<bool> saveLocalImage(String imagePath,
      {String? fileName}) async {
    try {
      if (await PermissionUtil.requestPhotos()) {
        EasyLoading.show(status: '保存中...');

        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          await _saveImageToGallery(bytes, fileName);
          EasyLoading.dismiss();
          EasyLoading.showSuccess('保存成功');
          return true;
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError('文件不存在');
          return false;
        }
      } else {
        EasyLoading.showError('未获得相册权限');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('保存失败');
      return false;
    }
  }

  /// 保存图片到相册
  static Future<void> _saveImageToGallery(
      Uint8List imageBytes, String? fileName) async {
    if (Platform.isAndroid) {
      // Android 保存到 Pictures 目录
      final directory = await getExternalStorageDirectory();
      final picturesDir = Directory('${directory!.path}/Pictures');
      // ignore: avoid_slow_async_io
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.png';
      final imagePath = '${picturesDir.path}/$name';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
    } else if (Platform.isIOS) {
      // iOS 使用 image_gallery_saver 包来保存到相册
      try {
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          name: fileName ?? 'IMG_${DateTime.now().millisecondsSinceEpoch}',
          quality: 100,
        );

        if (!result['isSuccess']) {
          throw Exception('保存到相册失败');
        }
      } catch (e) {
        throw Exception('保存到相册失败: $e');
      }
    }
  }
}
