import 'product_model.dart';
import 'address_model.dart';

class Order {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerCpf;
  final Address customerAddress;
  final List<Product> items;

  Order({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerCpf,
    required this.customerAddress,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'customer_email': customerEmail,
    'customer_phone': customerPhone,
    'customer_cpf': customerCpf,
    'customer_address': customerAddress.toJson(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
