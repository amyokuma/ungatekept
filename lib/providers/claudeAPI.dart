import 'package:Loaf/config/api_keys.dart';
import 'dart:io';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

class AIService {
  static AIService? _instance;
  late final AnthropicClient _client;

  // Private constructor
  AIService._() {
    _client = AnthropicClient(
      apiKey: ApiKeys.anthropicAPIKey, // Or load from secure storage
    );
  }

  // Singleton getter
  static AIService get instance {
    _instance ??= AIService._();
    return _instance!;
  }

  // Generate landmark summary
  Future<String> generateLandmarkSummary(List<String> reviewComments) async {
    if (reviewComments.isEmpty) {
      return 'No reviews available.';
    }

    final commentsText = reviewComments
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');

    try {
      final res = await _client.createMessage(
        request: CreateMessageRequest(
          model: const Model.model(Models.claude35Sonnet20240620),
          maxTokens: 150,
          messages: [
            Message(
              role: MessageRole.user,
              content: MessageContent.text(
                'Based on the following landmark reviews, generate a concise summary '
                'in less than 40 words that captures the key impressions and highlights:\n\n'
                '$commentsText\n\n'
                'Summary:',
              ),
            ),
          ],
        ),
      );

      return res.content.text?.trim() ?? 'Unable to generate summary.';
    } catch (e) {
      print('Error generating summary: $e');
      return 'Error generating summary.';
    }
  }

  // Cleanup method (call when app closes if needed)
  void dispose() {
    _client.endSession();
  }
}