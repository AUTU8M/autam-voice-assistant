import 'dart:convert';

import 'package:autam/secrets.dart';
import 'package:http/http.dart' as http;

class OpenaiService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromtAPI(String prompt) async {
    print('isArtPromtAPI called with prompt: $prompt');

    try {
      print('Sending request to OpenAI to check if art prompt...');
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApikey',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? "$prompt". Simply answer with a yes or no',
            },
          ],
        }),
      );

      print('isArtPromtAPI response status: ${res.statusCode}');
      print('isArtPromtAPI response body: ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        print('Content detection result: "$content"');

        // Enhanced logic to handle various forms of "yes"
        if (content.toLowerCase().contains('yes')) {
          print('Art prompt detected! Calling DALL-E API...');
          final res = await dallEAPI(prompt);
          return res;
        } else {
          print('Not an art prompt. Calling ChatGPT API...');
          final res = await chatGPTAPI(prompt);
          return res;
        }
      } else {
        print('API error: ${res.statusCode} - ${res.body}');
        return 'An internal error occurred: Status code ${res.statusCode}';
      }
    } catch (e) {
      print('Exception in isArtPromtAPI: $e');
      return 'Error: $e';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    print('chatGPTAPI called with prompt: $prompt');
    messages.add({'role': 'user', 'content': prompt});

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApikey',
        },
        body: jsonEncode({"model": "gpt-4o", "messages": messages}),
      );

      print('chatGPTAPI response status: ${res.statusCode}');
      print('chatGPTAPI response body: ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        print('ChatGPT response content: $content');
        messages.add({'role': 'assistant', 'content': content});
        return content;
      } else {
        print('ChatGPT API error: ${res.statusCode} - ${res.body}');
        return 'An internal error occurred: Status code ${res.statusCode}';
      }
    } catch (e) {
      print('Exception in chatGPTAPI: $e');
      return 'Error: $e';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    print('dallEAPI called with prompt: $prompt');

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApikey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      print('dallEAPI response status: ${res.statusCode}');
      print('dallEAPI response body: ${res.body}');

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        print('DALL-E generated image URL: $imageUrl');
        messages.add({'role': 'assistant', 'content': imageUrl});
        return imageUrl;
      } else {
        print('DALL-E API error: ${res.statusCode} - ${res.body}');
        return 'An internal error occurred: Status code ${res.statusCode}';
      }
    } catch (e) {
      print('Exception in dallEAPI: $e');
      return 'Error: $e';
    }
  }
}
