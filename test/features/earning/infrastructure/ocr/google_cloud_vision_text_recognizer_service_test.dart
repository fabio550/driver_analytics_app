import 'dart:convert';
import 'dart:io';

import 'package:driver_analytics_app/features/earning/infrastructure/ocr/google_cloud_vision_text_recognizer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleCloudVisionTextRecognizerService', () {
    late File tempImage;

    setUp(() async {
      tempImage = await File(
        '${Directory.systemTemp.path}/gcv_test_${DateTime.now().microsecondsSinceEpoch}.png',
      ).create();
      await tempImage.writeAsBytes([0, 1, 2, 3]); // conteúdo não importa, só precisa existir
    });

    tearDown(() async {
      if (await tempImage.exists()) await tempImage.delete();
    });

    test('devolve fullTextAnnotation.text numa resposta de sucesso', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['key'], 'test-key');
        return http.Response(
          jsonEncode({
            'responses': [
              {
                'fullTextAnnotation': {'text': 'R\$ 18,35\nUber X · 10 min · 2 km'},
              },
            ],
          }),
          200,
        );
      });

      final service = GoogleCloudVisionTextRecognizerService(
        apiKey: 'test-key',
        client: client,
      );

      final text = await service.recognizeText(tempImage.path);
      expect(text, 'R\$ 18,35\nUber X · 10 min · 2 km');
    });

    test('lança quando a resposta HTTP não é 200 (cai pro fallback)', () async {
      final client = MockClient((request) async {
        return http.Response('erro de autenticação', 403);
      });

      final service = GoogleCloudVisionTextRecognizerService(
        apiKey: 'chave-invalida',
        client: client,
      );

      expect(() => service.recognizeText(tempImage.path), throwsA(isA<HttpException>()));
    });

    test('lança quando a Cloud Vision devolve um campo "error" na resposta', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'responses': [
              {
                'error': {'code': 3, 'message': 'Bad image data.'},
              },
            ],
          }),
          200,
        );
      });

      final service = GoogleCloudVisionTextRecognizerService(
        apiKey: 'test-key',
        client: client,
      );

      expect(() => service.recognizeText(tempImage.path), throwsA(isA<HttpException>()));
    });

    test('devolve string vazia quando não há fullTextAnnotation (imagem sem '
        'texto, não é erro)', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'responses': [{}]}), 200);
      });

      final service = GoogleCloudVisionTextRecognizerService(
        apiKey: 'test-key',
        client: client,
      );

      final text = await service.recognizeText(tempImage.path);
      expect(text, isEmpty);
    });
  });
}
