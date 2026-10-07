import 'dart:convert';
import 'dart:io';

import 'package:driver_analytics_app/features/earning/infrastructure/ocr/text_recognizer_service.dart';
import 'package:http/http.dart' as http;

/// OCR via Google Cloud Vision (`DOCUMENT_TEXT_DETECTION`) — usado como
/// motor principal quando há internet, porque é um modelo bem maior que
/// o do ML Kit on-device e erra muito menos em texto pequeno sobre mapa/
/// ícone (o pior caso pra OCR, e exatamente o que um print de corrida
/// do Uber é). `fullTextAnnotation.text` já vem com quebra de linha no
/// lugar certo — ao contrário do ML Kit, não precisa reordenar blocos
/// por posição Y aqui, o próprio serviço do Google já devolve nessa
/// ordem.
///
/// A chave de API é restrita no Google Cloud Console (nome do pacote +
/// assinatura do app) — ver `docs/google-cloud-vision-setup.md` — então
/// não precisa (nem deve) ficar hardcoded aqui: vem de
/// `String.fromEnvironment`, passada no build/run via `--dart-define`.
class GoogleCloudVisionTextRecognizerService implements TextRecognizerService {
  final String apiKey;
  final http.Client _client;
  final Duration timeout;

  GoogleCloudVisionTextRecognizerService({
    required this.apiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  static final Uri _endpoint = Uri.parse('https://vision.googleapis.com/v1/images:annotate');

  @override
  Future<String> recognizeText(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final body = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Encode(bytes)},
          'features': [
            {'type': 'DOCUMENT_TEXT_DETECTION'},
          ],
        },
      ],
    });

    final response = await _client
        .post(
          _endpoint.replace(queryParameters: {'key': apiKey}),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Cloud Vision respondeu ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final responses = decoded['responses'] as List<dynamic>?;
    if (responses == null || responses.isEmpty) {
      throw const FormatException('Cloud Vision não devolveu nenhuma resposta.');
    }

    final first = responses.first as Map<String, dynamic>;
    final error = first['error'];
    if (error != null) {
      throw HttpException('Cloud Vision devolveu erro: $error');
    }

    final fullTextAnnotation = first['fullTextAnnotation'] as Map<String, dynamic>?;
    return (fullTextAnnotation?['text'] as String?) ?? '';
  }

  @override
  Future<void> dispose() async => _client.close();
}
