import 'package:dio/dio.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/core/errors/exceptions.dart';
import 'package:web_dashboard/core/storage/local_storage.dart';

/// Dio-based HTTP client with automatic auth token injection and error mapping.
class ApiClient {
  late final Dio _dio;
  final LocalStorage _localStorage;

  ApiClient(this._localStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_localStorage),
      _ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => obj.toString(),
      ),
    ]);
  }

  /// Performs a GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a PUT request.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a PATCH request.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a DELETE request.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Uploads a file using multipart form data with optional progress callback.
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? additionalFields,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fileFieldName: await MultipartFile.fromFile(filePath),
      if (additionalFields != null) ...additionalFields,
    });

    return _dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(hours: 1),
        receiveTimeout: const Duration(hours: 1),
      ),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Uploads file from bytes (useful for web platform).
  Future<Response> uploadFileBytes(
    String path, {
    required List<int> fileBytes,
    required String fileName,
    required String fileFieldName,
    Map<String, dynamic>? additionalFields,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fileFieldName: MultipartFile.fromBytes(fileBytes, filename: fileName),
      if (additionalFields != null) ...additionalFields,
    });

    return _dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(hours: 1),
        receiveTimeout: const Duration(hours: 1),
      ),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}

// ── Auth Interceptor ──────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  _AuthInterceptor(this._localStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ── Error Interceptor ─────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException(
          'انتهت مهلة الاتصال. حاول مرة أخرى.',
        );
      case DioExceptionType.connectionError:
        throw const NetworkException(
          'لا يوجد اتصال بالإنترنت. تحقق من الشبكة.',
        );
      case DioExceptionType.badResponse:
        _handleBadResponse(err);
        break;
      case DioExceptionType.cancel:
        throw const ServerException('تم إلغاء الطلب.');
      case DioExceptionType.unknown:
        if (err.message != null && err.message!.contains('XMLHttpRequest error')) {
          throw const NetworkException(
            'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت أو إعدادات الحماية.',
          );
        }
        throw ServerException(
          'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.',
          statusCode: err.response?.statusCode,
        );
      default:
        throw ServerException(
          'حدث خطأ في الشبكة، يرجى المحاولة مرة أخرى.',
          statusCode: err.response?.statusCode,
        );
    }
    handler.next(err);
  }

  void _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final message = data is Map ? (data['message'] as String?) : null;

    switch (statusCode) {
      case 401:
        throw AuthException(
          message ?? 'غير مصرح. يرجى تسجيل الدخول.',
          statusCode,
        );
      case 403:
        throw AuthException(
          message ?? 'ليس لديك صلاحية للوصول.',
          statusCode,
        );
      case 404:
        throw ServerException(
          message ?? 'المورد غير موجود.',
          statusCode: statusCode,
        );
      case 422:
        final errors = data is Map && data['errors'] is Map
            ? (data['errors'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  (value as List).cast<String>(),
                ),
              )
            : null;
        throw ValidationException(
          message ?? 'خطأ في البيانات المدخلة.',
          errors,
          statusCode,
        );
      case 429:
        throw ServerException(
          message ?? 'طلبات كثيرة. حاول لاحقاً.',
          statusCode: statusCode,
        );
      case 500:
        throw ServerException(
          message ?? 'خطأ داخلي في الخادم.',
          statusCode: statusCode,
        );
      default:
        throw ServerException(
          message ?? 'حدث خطأ غير متوقع.',
          statusCode: statusCode,
        );
    }
  }
}
