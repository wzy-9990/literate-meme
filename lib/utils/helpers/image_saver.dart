import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_tem/utils/permission/index.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

/// 图片保存工具类
class ImageSaver {
  static final Dio _dio = Dio(BaseOptions(responseType: ResponseType.bytes));

  /// 保存网络图片到本地相册
  static Future<bool> saveNetworkImage(String imageUrl,
      {String? fileName}) async {
    return _saveImage(
      fileName: fileName,
      bytesProvider: () async {
        final response = await _dio.get<List<int>>(imageUrl);
        if (response.statusCode != 200 || response.data == null) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: '下载失败',
          );
        }
        return Uint8List.fromList(response.data!);
      },
      downloadFailMessage: '下载失败',
    );
  }

  /// 保存本地图片到相册
  static Future<bool> saveLocalImage(String imagePath,
      {String? fileName}) async {
    return _saveImage(
      fileName: fileName,
      bytesProvider: () async {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          throw const FileSystemException('文件不存在');
        }
        return await Isolate.run(imageFile.readAsBytesSync);
      },
      fileReadFailMessage: '文件不存在',
    );
  }

  static Future<bool> _saveImage({
    required Future<Uint8List> Function() bytesProvider,
    String? fileName,
    String downloadFailMessage = '保存失败',
    String fileReadFailMessage = '保存失败',
  }) async {
    try {
      // 请求相册权限
      if (await PermissionUtil.requestPhotos()) {
        BaseToastLoading.show(status: '保存中...');

        final bytes = await bytesProvider();
        final success = await _saveImageToGallery(bytes, fileName);
        BaseToastLoading.dismiss();
        if (success) {
          BaseToastLoading.showSuccess('保存成功');
          return true;
        }
        BaseToastLoading.showError('保存失败');
        return false;
      } else {
        BaseToastLoading.dismiss();
        return false;
      }
    } on DioException {
      BaseToastLoading.dismiss();
      BaseToastLoading.showError(downloadFailMessage);
      return false;
    } on FileSystemException {
      BaseToastLoading.dismiss();
      BaseToastLoading.showError(fileReadFailMessage);
      return false;
    } catch (e) {
      BaseToastLoading.dismiss();

      return false;
    }
  }

  /// 保存图片到相册
  static Future<bool> _saveImageToGallery(
      Uint8List imageBytes, String? fileName) async {
    try {
      // 使用 image_gallery_saver 统一处理 Android 和 iOS
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        name: fileName ?? 'IMG_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );

      return (result['isSuccess'] == true || result['success'] == true);
    } catch (e) {
      return false;
    }
  }
}
