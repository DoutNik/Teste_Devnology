import 'package:flutter/material.dart';
import '../models/form_data.dart';

class OrderConfirmationPage extends StatelessWidget {
  final FormData formData;

  const OrderConfirmationPage({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    final double total = formData.products.fold(0, (sum, p) => sum + p.price);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedido Confirmado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Dados do Pedido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Nome: ${formData.name}'),
            Text('Email: ${formData.email}'),
            Text('Telefone: ${formData.phone}'),
            Text('CPF: ${formData.cpf}'),
            const SizedBox(height: 16),
            const Text(
              'Endereço',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${formData.address.street}, ${formData.address.number}'),
            if ((formData.address.complement ?? '').isNotEmpty)
              Text('Complemento: ${formData.address.complement}'),

            Text(
              '${formData.address.neighborhood} - ${formData.address.city}/${formData.address.state}',
            ),
            Text('CEP: ${formData.address.cep}'),
            const SizedBox(height: 16),
            const Text(
              'Produtos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...formData.products.map(
              (p) => ListTile(
                title: Text(p.name),
                subtitle: Text(p.description ?? ''),
                trailing: Text('R\$ ${p.price.toStringAsFixed(2)}'),
              ),
            ),
            const Divider(),
            Text(
              'Total do Pedido:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('R\$ ${total.toStringAsFixed(2)}'),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Início'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
