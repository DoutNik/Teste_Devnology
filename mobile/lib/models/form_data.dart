import 'product_model.dart';
import 'address_model.dart'; // Usa Address desde aquí

class FormData {
  String name;
  String email;
  String phone;
  String cpf;
  Address address;
  List<Product> products;

  FormData({
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.address,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': name,
      'customer_email': email,
      'customer_phone': phone,
      'customer_address':
          '${address.street}, ${address.number} ${address.complement != null ? "- ${address.complement}" : ""}, ${address.neighborhood}, ${address.city} - ${address.state}, ${address.cep}',
      'items': products.map((p) => p.toJson()).toList(),
    };
  }
}
