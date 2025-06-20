import 'package:flutter/material.dart';
import '../widgets/checkout_form_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: CheckoutFormPage(),
    );
  }
}
