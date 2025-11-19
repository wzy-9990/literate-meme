import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart' hide FormData;

class ApiService {
  late Dio _dio;
  static String? _customBaseUrl; // 自定义的 API 地址
  static bool _proxyEnabled = false; // 是否启用代理
  static String? _proxyHost; // 代理地址
  static int? _proxyPort; // 代理端口

  /// 在应用启动时调用，用于设置自定义 API 地址和代理配置
  static Future<void> init() async {
    _customBaseUrl = await Storage.getString(StorageKeys.customApiUrl);
    if (_customBaseUrl != null) {
      debugPrint('🔧 检测到自定义 API 地址: $_customBaseUrl');
    }

    // 生产环境不允许使用代理
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    if (env != 'production') {
      _proxyEnabled = await Storage.getBool(StorageKeys.proxyEnabled) ?? false;
      if (_proxyEnabled) {
        _proxyHost = await Storage.getString(StorageKeys.proxyHost);
        _proxyPort = await Storage.getInt(StorageKeys.proxyPort);
        debugPrint('🔧 检测到代理配置: $_proxyHost:$_proxyPort');
      }
    } else {
      debugPrint('🔒 生产环境：代理功能已禁用');
    }
  }

  ApiService() {
    // 优先使用自定义的 API 地址，否则使用 .env 中的默认地址
    final baseUrl = _customBaseUrl ?? dotenv.env['API_URL'] ?? '';

    debugPrint('🌐 API Base URL: $baseUrl');

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        "Content-Type": "application/json",
      },
    );

    _dio = Dio(baseOptions);

    // 配置代理（仅非生产环境）
    if (_proxyEnabled && _proxyHost != null && _proxyPort != null) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY $_proxyHost:$_proxyPort';
        };
        // 抓包时忽略证书验证
        client.badCertificateCallback = (cert, host, port) => true;
        debugPrint('✅ 代理已启用: $_proxyHost:$_proxyPort');
        return client;
      };
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 动态获取 token
        final token = await Storage.getString(StorageKeys.token);
        if (token != null && token.isNotEmpty) {
          options.headers['accesstoken'] = token;
        }
        debugPrint('⏩ 请求接口: ${options.uri}');
        debugPrint('⏩ 请求方式: ${options.method}');
        debugPrint('⏩ 请求头: ${options.headers}');
        debugPrint('⏩ 请求参数: ${options.data ?? options.queryParameters}');

        handler.next(options);
      },
      onResponse: (response, handler) {
        // ✅ 打印响应数据
        debugPrint('✅ 接口响应: ${response.requestOptions.uri}');
        debugPrint('✅ 响应状态: ${response.statusCode}');
        debugPrint('✅ 响应数据: ${response.data}');
        if (response.statusCode == 200) {
          final data = response.data;
          // 如果不是 code == 1，说明业务失败
          if (data is Map && data['code'] != '1') {
            final msg = data['returnMsg'] ?? '接口返回异常';
            EasyLoading.showToast(msg.toString());
            return handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: "接口返回错误: $msg",
              type: DioExceptionType.badResponse,
            ));
          }

          // 成功则继续
          return handler.next(response);
        }

        // 非200的 HTTP 错误
        if (response.statusCode == 401) {
          EasyLoading.showToast("登录信息过期，请重新登录");
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAllNamed(AppRoutes.login);
          });
        } else {
          EasyLoading.showToast("请求异常：${response.statusCode}");
        }

        return handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "状态码异常: ${response.statusCode}",
          type: DioExceptionType.badResponse,
        ));
      },
      onError: (DioException e, handler) {
        EasyLoading.showToast("网络异常，请检查网络连接");
        handler.next(e);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data['data'];
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response =
          await _dio.post(path, data: data, queryParameters: query);
      return response.data['data']; // 只返回 data 字段
    } on DioException {
      rethrow;
    }
  }

  /// 上传文件
  Future<Map<String, dynamic>?> uploadFile(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );

      // 返回 data 字段
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['code'] == '1' && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          // code 不为 '1' 时，显示 returnMsg 并抛出异常
          final returnMsg = data['returnMsg'];
          if (returnMsg != null && returnMsg is String) {
            EasyLoading.showToast(returnMsg);
          } else {
            EasyLoading.showToast('上传失败');
          }
          throw Exception(returnMsg ?? '上传失败');
        }
      }

      return null;
    } on DioException catch (e) {
      // 优先显示响应数据中的 returnMsg
      String? returnMsg;
      if (e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        returnMsg = data['returnMsg'];
      }

      if (returnMsg != null && returnMsg is String) {
        EasyLoading.showToast(returnMsg);
      }

      rethrow;
    } catch (e) {
      // 如果不是 DioException，则不显示 toast（因为可能已经在上面显示过了）
      rethrow;
    }
  }
}

class Api {
  static final ApiService instance = ApiService();
}
