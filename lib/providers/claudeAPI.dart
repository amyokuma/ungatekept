import 'package:Loaf/config/api_keys.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:flutter/material.dart';
class Claudeapi {

  Future<void> _setup() async{
  final client = AnthropicClient(apiKey:ApiKeys.anthropicAPIKey);
  }

  Future<void> genDescription({required List <String> args }) async {
    await _setup();
    final res = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude-haiku-4-5-20251001),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello, Claude'),
      ),
    ],
  ),
);
print(res.content.text);

  }




}