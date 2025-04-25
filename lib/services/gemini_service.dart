import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/api.dart';
import '../utils/constants.dart';

class GeminiService {
  final GenerativeModel _generativeModel;

  GeminiService()
      : _generativeModel = GenerativeModel(
          model: ApiConstants.geminiModel,
          apiKey: GEMINI_API_KEY,
        );

  Future<String> getHealthResponse(String prompt) async {
    // Add healthcare context to the prompt
    final enhancedPrompt =
        'When I start with a greeting like "Hello," "Hi,"or "Good day,"please acknowledge it in a friendly manner before addressing my healthcare-related question.As a healthcare assistant, please provide accurate information ,include Medication if possible, include some references , just give the answer.Here is the prompt: $prompt ';

    try {
      final response = await _generativeModel.generateContent([
        Content.text(enhancedPrompt),
      ]);

      return response.text ?? AppConstants.errorMessage;
    } catch (e) {
      return '${AppConstants.networkErrorMessage} Error: $e';
    }
  }
}
