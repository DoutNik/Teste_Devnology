import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> futureProducts;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  String searchQuery = '';
  String selectedProvider = 'Todos';
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService.fetchProducts();
    futureProducts.then((products) {
      setState(() {
        allProducts = products;
        filteredProducts = products;
      });
    });
  }

  void applyFilters() {
    setState(() {
      filteredProducts = allProducts.where((p) {
        final matchesSearch =
            p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesProvider =
            selectedProvider == 'Todos' || p.provider == selectedProvider;

        final matchesMinPrice = minPrice == null || p.price >= minPrice!;
        final matchesMaxPrice = maxPrice == null || p.price <= maxPrice!;

        return matchesSearch &&
            matchesProvider &&
            matchesMinPrice &&
            matchesMaxPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            final providers = [
              'Todos',
              ...{...allProducts.map((p) => p.provider)},
            ];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Buscar'),
                        onChanged: (value) {
                          searchQuery = value;
                          applyFilters();
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedProvider,
                              items: providers
                                  .map(
                                    (provider) => DropdownMenuItem(
                                      value: provider,
                                      child: Text(provider),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                selectedProvider = value!;
                                applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Min \$',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                minPrice = double.tryParse(value);
                                applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Max \$',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                maxPrice = double.tryParse(value);
                                applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final p = filteredProducts[index];
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
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            cart.add(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${p.name} adicionado ao carrinho',
                                ),
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
