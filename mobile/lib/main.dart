import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'package:mobile/models/cart_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => CartModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}
