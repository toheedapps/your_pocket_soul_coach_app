import 'package:dio/dio.dart';
import 'package:yspc/core/env_loader.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  late final Dio _dio;
  late final String _apiKey;

  void _initializeService() {
    // Try to read key from env.json first
    final envApiKey = EnvLoader.get('OPENAI_API_KEY');

    // Fallback to build-time environment if not found
    const defineKey = String.fromEnvironment('OPENAI_API_KEY');

    _apiKey = envApiKey?.isNotEmpty == true
        ? envApiKey!
        : (defineKey.isNotEmpty ? defineKey : '');

    if (_apiKey.isEmpty) {
      throw Exception(
          'OPENAI_API_KEY must be provided via env.json or --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (e.response?.statusCode == 429) {
          handler.reject(DioException(
            requestOptions: e.requestOptions,
            error: 'Rate limit exceeded. Please try again in a moment.',
          ));
        } else if (e.response?.statusCode == 401) {
          handler.reject(DioException(
            requestOptions: e.requestOptions,
            error: 'Invalid OpenAI API key. Please check your configuration.',
          ));
        } else {
          handler.next(e);
        }
      },
    ));
  }

  /// Call this after EnvLoader.load() is done (in main.dart)
  static Future<void> initialize() async {
    _instance._initializeService();
  }

  Dio get dio => _dio;
}
