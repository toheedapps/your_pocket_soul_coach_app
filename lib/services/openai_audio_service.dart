import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yspc/services/openai_service.dart';

class OpenAIAudioService {
  final Dio _dio = OpenAIService().dio;

  /// Transcribe an audio file using OpenAI transcription endpoint.
  Future<String?> transcribeAudio(File audioFile) async {
    final fileName = audioFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(audioFile.path, filename: fileName),
      'model': 'gpt-4o-mini-transcribe', // or your preferred transcription model
    });

    try {
      final resp = await _dio.post(
        '/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      if (resp.statusCode == 200 && resp.data != null) {
        // OpenAI returns { "text": "transcribed text" }
        return resp.data['text'] as String?;
      }
      return null;
    } on DioException catch (e) {
      // log details for debugging
      print('❌ Transcription error: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      print('❌ Transcription unexpected error: $e');
      rethrow;
    }
  }
}
