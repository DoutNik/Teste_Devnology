import 'package:mobile/models/address_model.dart';

final RegExp _emailRegex = RegExp(r"\S+@\S+\.\S+");
final RegExp _phoneRegex = RegExp(r"^\+?[1-9]\d{7,14}$");
final RegExp _cepRegex = RegExp(r"^\d{5}-?\d{3}$");
final RegExp _namePartRegex = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ]{2,}$");

const List<String> validStates = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

String? validateName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Nome é obrigatório';
  if (trimmed.length < 5) return 'Digite o nome completo';

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length < 2) return 'Digite o nome completo';

  final validWords = parts
      .where((part) => _namePartRegex.hasMatch(part))
      .toList();
  if (validWords.length < 2)
    return 'Cada parte do nome deve conter apenas letras';

  if (!RegExp(r'^[A-ZÀ-Ö]').hasMatch(parts[0]))
    return 'O nome deve começar com letra maiúscula';

  return null;
}

String? validateEmail(String email) {
  if (email.trim().isEmpty) return 'Email é obrigatório';
  if (!_emailRegex.hasMatch(email)) return 'Email inválido';
  return null;
}

String? validatePhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.isEmpty) return 'Telefone é obrigatório';
  if (!_phoneRegex.hasMatch(cleaned)) {
    return 'Telefone inválido. Use formato internacional, ex: +5511999999999';
  }
  return null;
}

String? validateCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
  if (cpf.length != 11) return "CPF inválido";
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return "CPF inválido";

  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int rest = (sum * 10) % 11;
  if (rest == 10 || rest == 11) rest = 0;
  if (rest != int.parse(cpf[9])) return "CPF inválido";

  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  rest = (sum * 10) % 11;
  if (rest == 10 || rest == 11) rest = 0;
  if (rest != int.parse(cpf[10])) return "CPF inválido";

  return null;
}

Map<String, String> validateAddress(Address address) {
  final Map<String, String> errors = {};

  if (address.street.trim().isEmpty) errors['street'] = 'Rua é obrigatória';

  if (address.number.trim().isEmpty) {
    errors['number'] = 'Número é obrigatório';
  } else if (address.number != 'S/N' &&
      !RegExp(r'^\d+$').hasMatch(address.number.trim())) {
    errors['number'] = 'Número inválido';
  }

  if (address.neighborhood.trim().isEmpty)
    errors['neighborhood'] = 'Bairro é obrigatório';
  if (address.city.trim().isEmpty) errors['city'] = 'Cidade é obrigatória';
  if (!validStates.contains(address.state.toUpperCase())) {
    errors['state'] = 'Estado inválido';
  }

  if (!_cepRegex.hasMatch(address.cep)) errors['cep'] = 'CEP inválido';

  return errors;
}
