import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/user.dart';

class MetricsViewModel extends ChangeNotifier {
  late DateTime _startTime;

  MetricsViewModel() {
    _startTime = DateTime.now();
  }

  Future<void> sendMetrics(User user) async {
    // Capturar el tiempo que tomó cargar la vista
    DateTime _endTime = DateTime.now();
    double loadTime = _endTime.difference(_startTime).inMilliseconds / 1000;

    // Obtener la URL del servicio desde el archivo .env
    String herokuApiUrl = dotenv.env['API_KEY_HEROKU'] ?? '';

    // Datos a enviar
    Map<String, dynamic> data = {
      "plataforma": Platform.operatingSystem, // "Android", "iOS", etc.
      "tiempo": loadTime,
      "timestamp": _endTime.toUtc().toIso8601String(),
      "userID": user.id,
    };

    // Enviar los datos al servicio de Heroku
    try {
      final response = await http.post(
        Uri.parse(herokuApiUrl), // Usar la variable del archivo .env
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Métricas enviadas correctamente.");
      } else {
        print("Error al enviar métricas: ${response.body}");
      }
    } catch (e) {
      print("Error al conectar con el servicio de Heroku: $e");
    }
  }
}
