import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/config/api/index.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart' hide FormData, Response;

class ApiService {
  late Dio _dio;
  static String? _customBaseUrl; // 自定义的 API 地址
  static bool _proxyEnabled = false; // 是否启用代理
  static String? _proxyHost; // 代理地址
  static int? _proxyPort; // 代理端口
  static bool _isShowingAuthDialog = false;

  // -------------------- 登录弹窗 --------------------
  static Future<void> _showAuthDialog() async {
    if (_isShowingAuthDialog) {
      return;
    }
    _isShowingAuthDialog = true;

    // 自动判断当前状态：未登录 / 过期
    final token = await Storage.getString(StorageKeys.token);
    final bool isExpired = token != null && token.isNotEmpty;

    await showCupertinoDialog(
      context: Get.context!,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(isExpired ? '登录已过期' : '未登录'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isExpired ? '您的登录身份已过期，请重新登录。' : '您还未登录，请先登录。',
            ),
          ),
          actions: [
            if (!isExpired)
              CupertinoDialogAction(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(Get.context!);
                  _isShowingAuthDialog = false;
                },
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('去登录'),
              onPressed: () {
                Navigator.pop(Get.context!);
                _isShowingAuthDialog = false;
                // Get.toNamed(AppRoutes.login);
                NavigationUtils.toNamed(AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }

  // -------------------- 初始化配置 --------------------
  static Future<void> init() async {
    _customBaseUrl = await Storage.getString(StorageKeys.customApiUrl);
    if (_customBaseUrl != null) {
      debugPrint('🔧 检测到自定义 API 地址: $_customBaseUrl');
    }

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

  // -------------------- 构造函数 --------------------
  ApiService() {
    // 优先使用自定义的 API 地址，否则使用 .env 中的默认地址
    final baseUrl = _customBaseUrl ?? dotenv.env['API_URL'] ?? '';

    debugPrint('🌐 API Base URL: $baseUrl');

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // 配置代理（仅非生产环境）
    if (_proxyEnabled && _proxyHost != null && _proxyPort != null) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (_) => 'PROXY $_proxyHost:$_proxyPort';
        client.badCertificateCallback = (cert, host, port) => true;
        debugPrint('✅ 代理已启用: $_proxyHost:$_proxyPort');
        return client;
      };
    }

    // -------------------- 拦截器 --------------------
    _dio.interceptors.add(
      InterceptorsWrapper(
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
          debugPrint('✅ 响应接口: ${response.requestOptions.uri}');
          debugPrint('✅ 响应状态: ${response.statusCode}');
          debugPrint('✅ 响应数据: ${response.data}');

          if (response.statusCode == 200) {
            final data = response.data;

            // -------------------- 401 处理 --------------------
            if (ApiConfig.getCode(data) == ApiConfig.unauthorizedCode) {
              _showAuthDialog();
              final msg = ApiConfig.getMessage(data) ?? '接口返回异常';
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: '接口返回错误: $msg',
                  type: DioExceptionType.badResponse,
                ),
              );
            }

            // -------------------- 业务失败 --------------------
            if (data is Map<String, dynamic> && !ApiConfig.isSuccess(data)) {
              final msg = ApiConfig.getMessage(data) ?? '接口返回异常';
              EasyLoading.showToast(msg);
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: '接口返回错误: $msg',
                  type: DioExceptionType.badResponse,
                ),
              );
            }

            return handler.next(response);
          }

          // -------------------- HTTP 非200 --------------------
          if (response.statusCode == ApiConfig.unauthorizedCode) {
            _showAuthDialog();
          } else {
            EasyLoading.showToast('请求异常：${response.statusCode}');
          }

          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: '状态码异常: ${response.statusCode}',
              type: DioExceptionType.badResponse,
            ),
          );
        },

        // -------------------- 修复重点：401 不提示“网络异常” --------------------
        onError: (DioException e, handler) {
          // ❗ 401 不再提示网络异常（避免未登录误报）
          if (e.response?.statusCode == ApiConfig.unauthorizedCode) {
            return handler.next(e);
          }

          EasyLoading.showToast('网络异常，请检查网络连接');
          handler.next(e);
        },
      ),
    );
  }

  // -------------------- GET --------------------
  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return ApiConfig.getData(response.data);
    } on DioException {
      rethrow;
    }
  }

  // -------------------- POST --------------------
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    FormData? formData,
    void Function(int sent, int total)? onProgress,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    try {
      final Options options = Options(
        sendTimeout: sendTimeout ?? const Duration(seconds: 5),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 3),
      );

      Response response;

      if (formData != null) {
        response = await _dio.post(
          path,
          data: formData,
          queryParameters: query,
          onSendProgress: onProgress,
          options: Options(
            sendTimeout: sendTimeout ?? const Duration(seconds: 60),
            receiveTimeout: receiveTimeout ?? const Duration(seconds: 60),
          ),
        );
      } else {
        response = await _dio.post(
          path,
          data: data,
          queryParameters: query,
          options: options,
        );
      }

      return ApiConfig.getData(response.data);
    } on DioException {
      rethrow;
    }
  }

  // -------------------- 文件上传 --------------------
  Future<dynamic> uploadFile(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onProgress,
  }) async {
    return post(
      path,
      formData: formData,
      onProgress: onProgress,
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
  }
}

class Api {
  static final ApiService instance = ApiService();
}
