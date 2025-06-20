import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/form_data.dart';

class OrderService {
  static const String baseUrl = 'http://10.0.2.2:3001';

  static Future<bool> sendOrder(FormData formData) async {
    final url = Uri.parse('$baseUrl/orders');
    final body = jsonEncode(formData.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error en backend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error enviando pedido: $e');
      return false;
    }
  }
}
