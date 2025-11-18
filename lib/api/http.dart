import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? '',
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        "Content-Type": "application/json",
      },
    ));

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
}

class Api {
  static final ApiService instance = ApiService();
}
