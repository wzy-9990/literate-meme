import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tem/components/BaseAuthDialog/index.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_tem/config/api/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';

class ApiService {
  late Dio _dio;
  static String? _customBaseUrl;
  static bool _proxyEnabled = false;
  static String? _proxyHost;
  static int? _proxyPort;
  static bool _showAuthDialog = true;

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

  /// 配置 401 时是否弹出登录框
  static void setAuthDialogEnabled(bool enabled) {
    _showAuthDialog = enabled;
  }

  // -------------------- 构造函数 --------------------
  ApiService() {
    final baseUrl = _customBaseUrl ?? dotenv.env['API_URL'] ?? '';
    debugPrint('🌐 API Base URL: $baseUrl');

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {'Content-Type': 'application/json'},
    );

    _dio = Dio(baseOptions);

    if (_proxyEnabled && _proxyHost != null && _proxyPort != null) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (_) => 'PROXY $_proxyHost:$_proxyPort';
        client.badCertificateCallback = (cert, host, port) => true;
        debugPrint('✅ 代理已启用: $_proxyHost:$_proxyPort');
        return client;
      };
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Storage.getString(StorageKeys.token);
          if (token != null && token.isNotEmpty) {
            options.headers['accesstoken'] = token;
          }

          // 自动 loading 管理（通过 extra 参数控制）
          final autoLoading = options.extra['autoLoading'] ?? false;
          if (autoLoading == true) {
            final loadingText = options.extra['loadingText'] as String?;
            BaseToastLoading.show(status: loadingText);
          }

          debugPrint('⏩ 请求接口: ${options.uri}');
          debugPrint('⏩ 请求方式: ${options.method}');
          debugPrint('⏩ 请求头: ${options.headers}');
          debugPrint('⏩ 请求参数: ${options.data ?? options.queryParameters}');

          handler.next(options);
        },
        onResponse: (response, handler) async {
          // 自动关闭 loading（如果开启了自动 loading）
          final autoLoading =
              response.requestOptions.extra['autoLoading'] ?? false;
          if (autoLoading == true) {
            BaseToastLoading.dismiss();
          }

          debugPrint('✅ 响应接口: ${response.requestOptions.uri}');
          debugPrint('✅ 响应状态: ${response.statusCode}');
          debugPrint('✅ 响应数据: ${response.data}');

          if (response.statusCode == 200) {
            final data = response.data;

            final allowAuthDialog =
                response.requestOptions.extra['showAuthDialog'] ??
                    _showAuthDialog;
            final code = ApiConfig.getCode(data);

            if (code == ApiConfig.unauthorizedCode) {
              // 只关闭 loading 类型的提示，不关闭 toast/success
              BaseToastLoading.dismissIfLoading();

              if (allowAuthDialog == true) {
                debugPrint('🔐 API拦截器: 检测到401，弹出登录对话框');
                final loginResult = await BaseAuthDialog.showAuthDialog();
                debugPrint('🔐 API拦截器: 登录对话框关闭，返回结果: $loginResult');

                final msg = ApiConfig.getMessage(data) ?? '接口返回异常';

                if (loginResult != null && loginResult['login'] == true) {
                  debugPrint('✅ API拦截器: 登录成功，准备重发请求');
                  // 登录成功，重发请求
                  final opts = response.requestOptions;
                  final newToken = await Storage.getString(StorageKeys.token);
                  debugPrint('🔑 API拦截器: 获取新token: ${newToken?.substring(0, 10)}...');

                  // 对于包含FormData的请求，我们不自动重试，因为FormData不能重复使用
                  if (opts.data is FormData) {
                    // 如果是FormData请求（如文件上传），我们返回一个特殊的错误
                    // 让调用方知道需要重新准备FormData并重新发起请求
                    return handler.reject(
                      DioException(
                        requestOptions: opts,
                        error:
                            'Login required for FormData request, please re-initiate the upload',
                        type: DioExceptionType.badResponse,
                      ),
                    );
                  }

                  // 非FormData请求可以安全重试
                  final cloneOpts = opts.copyWith(
                    headers: {
                      ...opts.headers,
                      if (newToken != null && newToken.isNotEmpty)
                        'accesstoken': newToken,
                    },
                  );

                  debugPrint('🔄 API拦截器: 开始重发请求: ${opts.uri}');
                  try {
                    final newResponse = await _dio.fetch(cloneOpts);
                    debugPrint('✅ API拦截器: 重发请求成功');
                    return handler.resolve(newResponse);
                  } on DioException catch (e) {
                    debugPrint('❌ API拦截器: 重发请求失败: ${e.message}');
                    return handler.reject(e);
                  }
                } else {
                  debugPrint('⚠️ API拦截器: 登录失败或用户取消，不重发请求');
                }

                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    error: '接口返回错误: $msg',
                    type: DioExceptionType.badResponse,
                  ),
                );
              } else {
                // 调用方不需要弹窗，直接抛出未授权错误，不提示
                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    error: 'unauthorized',
                    type: DioExceptionType.badResponse,
                  ),
                );
              }
            }

            if (data is Map<String, dynamic> && !ApiConfig.isSuccess(data)) {
              final msg = ApiConfig.getMessage(data) ?? '接口返回异常';
              BaseToastLoading.showToast(msg);
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

          if (response.statusCode == ApiConfig.unauthorizedCode) {
            // 只关闭 loading 类型的提示，不关闭 toast/success
            BaseToastLoading.dismissIfLoading();
            await BaseAuthDialog.showAuthDialog();
          } else {
            BaseToastLoading.showToast('请求异常：${response.statusCode}');
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
        onError: (DioException e, handler) {
          // 自动关闭 loading（如果开启了自动 loading）
          final autoLoading = e.requestOptions.extra['autoLoading'] ?? false;
          if (autoLoading == true) {
            BaseToastLoading.dismiss();
          }

          if (e.response?.statusCode == ApiConfig.unauthorizedCode) {
            return handler.next(e);
          }
          BaseToastLoading.showToast('网络异常，请检查网络连接');
          handler.next(e);
        },
      ),
    );
  }

  // -------------------- GET --------------------
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? params,
    bool? showAuthDialog,
    bool autoLoading = false,
    String? loadingText,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: params,
        options: Options(
          extra: {
            'showAuthDialog': showAuthDialog,
            'autoLoading': autoLoading,
            'loadingText': loadingText,
          },
        ),
      );
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
    bool? showAuthDialog,
    bool autoLoading = false,
    String? loadingText,
  }) async {
    try {
      final Options options = Options(
        sendTimeout: sendTimeout ?? const Duration(seconds: 5),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 3),
        extra: {
          'showAuthDialog': showAuthDialog,
          'autoLoading': autoLoading,
          'loadingText': loadingText,
        },
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
            extra: {
              'showAuthDialog': showAuthDialog,
              'autoLoading': autoLoading,
              'loadingText': loadingText,
            },
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
    } on DioException catch (e) {
      // 对于包含FormData的请求，如果遇到认证错误，需要重新发起请求而不是重用FormData
      if (e.response?.statusCode == ApiConfig.unauthorizedCode &&
          formData != null) {
        // 重新发起请求时，需要重新创建FormData
        // 但由于我们无法从formData参数获取原始文件信息，我们需要在上传处处理
        rethrow; // 仍然抛出异常，让调用方处理
      }
      rethrow;
    }
  }

  // -------------------- 文件上传 --------------------
  Future<dynamic> uploadFile(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      return await post(
        path,
        formData: formData,
        onProgress: onProgress,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );
    } on DioException catch (e) {
      // 如果是认证错误且是FormData请求，我们需要重新创建FormData并重试
      if (e.response?.statusCode == ApiConfig.unauthorizedCode ||
          e.error ==
              'Login required for FormData request, please re-initiate the upload') {
        // 重新登录后，调用方需要重新创建FormData并上传
        // 由于我们无法从FormData中获取原始文件信息，所以这里直接抛出错误
        // 让调用方知道需要重新准备上传
        rethrow;
      }
      rethrow;
    }
  }
}

class Api {
  static final ApiService instance = ApiService();
}
