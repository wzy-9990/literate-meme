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
  static Completer<bool>? _authDialogCompleter;

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

          debugPrint('⏩ 接口-请求路径: ${options.uri}');
          debugPrint('⏩ 接口-请求方式: ${options.method}');
          debugPrint('⏩ 接口-请求头: ${options.headers}');
          debugPrint('⏩ 接口-请求参数: ${options.data ?? options.queryParameters}');

          handler.next(options);
        },
        onResponse: (response, handler) async {
          // 自动关闭 loading（如果开启了自动 loading）
          final autoLoading =
              response.requestOptions.extra['autoLoading'] ?? false;
          if (autoLoading == true) {
            BaseToastLoading.dismiss();
          }

          debugPrint('✅ 接口-响应状态: ${response.statusCode}');
          debugPrint('✅ 接口-响应数据: ${response.data}');

          if (response.statusCode == 200) {
            final data = response.data;
            final code = ApiConfig.getCode(data);

            if (code == ApiConfig.unauthorizedCode) {
              // 只关闭 loading 类型的提示，不关闭 toast/success
              BaseToastLoading.dismissIfLoading();
              final retryResponse = await _retryRequestIfPossible(
                response.requestOptions,
                allowAuthDialog: _shouldShowAuthDialog(response.requestOptions),
              );

              if (retryResponse != null) {
                return handler.resolve(retryResponse);
              }

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
            final retryResponse = await _retryRequestIfPossible(
              response.requestOptions,
              allowAuthDialog: _shouldShowAuthDialog(response.requestOptions),
            );
            if (retryResponse != null) {
              return handler.resolve(retryResponse);
            }
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
        onError: (DioException e, handler) async {
          // 自动关闭 loading（如果开启了自动 loading）
          final autoLoading = e.requestOptions.extra['autoLoading'] ?? false;
          if (autoLoading == true) {
            BaseToastLoading.dismiss();
          }

          if (e.response?.statusCode == ApiConfig.unauthorizedCode) {
            BaseToastLoading.dismissIfLoading();
            final retryResponse = await _retryRequestIfPossible(
              e.requestOptions,
              allowAuthDialog: _shouldShowAuthDialog(e.requestOptions),
            );
            if (retryResponse != null) {
              return handler.resolve(retryResponse);
            }
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

extension _ApiServiceRetryHelpers on ApiService {
  bool _requestContainsFormData(RequestOptions options) =>
      options.data is FormData;

  bool _shouldShowAuthDialog(RequestOptions options) {
    final extraValue = options.extra['showAuthDialog'];
    if (extraValue is bool) {
      return extraValue;
    }
    return ApiService._showAuthDialog;
  }

  Future<Response<dynamic>?> _retryRequestIfPossible(
    RequestOptions options, {
    required bool allowAuthDialog,
  }) async {
    if (!allowAuthDialog) {
      debugPrint('⚠️ API拦截器: 调用方禁用登录弹窗，跳过重发');
      return null;
    }
    if (_requestContainsFormData(options)) {
      debugPrint('⚠️ API拦截器: FormData 请求无法自动重发: ${options.uri}');
      return null;
    }

    final authorized = await _ensureAuthenticated();
    if (!authorized) {
      debugPrint('⚠️ API拦截器: 登录未完成，放弃重发 ${options.uri}');
      return null;
    }

    final clonedOptions = await _cloneRequestOptionsWithLatestToken(options);

    debugPrint('🔄 API拦截器: 开始重发请求: ${options.uri}');
    try {
      final newResponse = await _dio.fetch(clonedOptions);
      debugPrint('✅ API拦截器: 重发请求成功: ${options.uri}');
      return newResponse;
    } on DioException catch (e) {
      debugPrint('❌ API拦截器: 重发请求失败: ${e.message}');
      rethrow;
    }
  }

  Future<RequestOptions> _cloneRequestOptionsWithLatestToken(
      RequestOptions options) async {
    final updatedHeaders = Map<String, dynamic>.from(options.headers);
    final newToken = await Storage.getString(StorageKeys.token);
    if (newToken != null && newToken.isNotEmpty) {
      updatedHeaders['accesstoken'] = newToken;
    }

    final clonedExtra = Map<String, dynamic>.from(options.extra);
    // 避免重复弹出 loading
    clonedExtra['autoLoading'] = false;

    return options.copyWith(
      data: _cloneRequestData(options.data),
      headers: updatedHeaders,
      extra: clonedExtra,
    );
  }

  dynamic _cloneRequestData(dynamic data) {
    if (data is Map) {
      return Map.of(data);
    }
    if (data is List) {
      return List.of(data);
    }
    return data;
  }

  Future<bool> _ensureAuthenticated() async {
    if (ApiService._authDialogCompleter != null) {
      debugPrint('⏳ API拦截器: 等待现有登录流程完成');
      return ApiService._authDialogCompleter!.future;
    }

    final completer = Completer<bool>();
    ApiService._authDialogCompleter = completer;

    try {
      BaseToastLoading.dismissIfLoading();
      debugPrint('🔐 API拦截器: 弹出登录对话框');
      final loginResult = await BaseAuthDialog.showAuthDialog();
      final success = loginResult != null && loginResult['login'] == true;
      completer.complete(success);
      if (success) {
        final newToken = await Storage.getString(StorageKeys.token);
        debugPrint(
            '🔑 API拦截器: 登录成功，刷新 token: ${newToken?.substring(0, 10)}...');
      } else {
        debugPrint('⚠️ API拦截器: 登录失败或取消');
      }
      return success;
    } catch (e) {
      debugPrint('⚠️ API拦截器: 登录流程异常: $e');
      completer.complete(false);
      return false;
    } finally {
      ApiService._authDialogCompleter = null;
    }
  }
}
