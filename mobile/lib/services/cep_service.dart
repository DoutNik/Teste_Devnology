import 'dart:convert';
import 'package:http/http.dart' as http;

class CepAddress {
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  CepAddress({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory CepAddress.fromJson(Map<String, dynamic> json) {
    return CepAddress(
      street: json['logradouro'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['localidade'] ?? '',
      state: json['uf'] ?? '',
    );
  }
}

class CepService {
  static Future<CepAddress?> fetchAddress(String cep) async {
    final sanitizedCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitizedCep.length != 8) {
      throw Exception('CEP inválido');
    }

    final url = Uri.parse('https://viacep.com.br/ws/$sanitizedCep/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('erro')) {
          return null; // CEP não encontrado
        }

        return CepAddress.fromJson(data);
      } else {
        throw Exception('Erro ao consultar CEP');
      }
    } catch (e) {
      throw Exception('Erro na requisição do CEP: $e');
    }
  }
}