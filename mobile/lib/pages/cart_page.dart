import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Seu carrinho está vazio.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.uniqueItems.length,
                    itemBuilder: (context, index) {
                      final Product p = cart.uniqueItems[index];
                      final quantity = cart.getQuantity(p);
                      return ListTile(
                        leading: p.image.isNotEmpty
                            ? Image.network(
                                p.image,
                                width: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(p.name),
                        subtitle: Text(
                          '${p.description}\nProveedor: ${p.provider}\nR\$ ${p.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cart.decrease(p),
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => cart.add(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => cart.removeAll(p),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkout');
                          },
                          child: const Text('Finalizar Pedido'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
