import 'dart:convert';

import 'package:autam/secrets.dart';
import 'package:http/http.dart' as http;

class OpenaiService {
  Future<String> isArtPromtAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApikey',
        },
        body: {
          jsonEncode({
            "model": "gpt-4o",
            "messages": [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an Ai picture, image, art or anything similar? $prompt . Simply answer with a yes or no',
              },
            ],
          }),
        },
      );
      print(res.body);
      if (res.statusCode == 200) {
        print("yay");
      }
      return 'AI';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    return 'CHATGPT';
  }

  Future<String> dallEAPI(String prompt) async {
    return 'DALL-E';
  }
}
