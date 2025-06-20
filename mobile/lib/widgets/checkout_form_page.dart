import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/form_data.dart';
import '../services/cep_service.dart' show CepService, CepAddress;
import '../utils/validators.dart';
import '../services/order_service.dart';
import '../models/address_model.dart';
import '../pages/confirmation_page.dart';
import '../models/cart_model.dart';

class CheckoutFormPage extends StatefulWidget {
  const CheckoutFormPage({super.key});

  @override
  State<CheckoutFormPage> createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();

  final cepController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  bool isLoadingCep = false;

  FormData formData = FormData(
    name: '',
    email: '',
    phone: '',
    cpf: '',
    address: Address(
      cep: '',
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
    ),
    products: [],
  );

  Map<String, String?> errors = {};

  Future<void> fetchAddressByCep(String cep) async {
    setState(() => isLoadingCep = true);
    try {
      final CepAddress? fetchedAddress = await CepService.fetchAddress(cep);
      if (fetchedAddress != null) {
  streetController.text = fetchedAddress.street;
  neighborhoodController.text = fetchedAddress.neighborhood;
  cityController.text = fetchedAddress.city;
  stateController.text = fetchedAddress.state;

  setState(() {
    formData.address.street = fetchedAddress.street;
    formData.address.neighborhood = fetchedAddress.neighborhood;
    formData.address.city = fetchedAddress.city;
    formData.address.state = fetchedAddress.state;
  });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar o CEP')),
      );
    } finally {
      setState(() => isLoadingCep = false);
    }
  }

  void _validateField(String field) {
    setState(() {
      switch (field) {
        case 'name':
          errors['name'] = validateName(formData.name);
          break;
        case 'email':
          errors['email'] = validateEmail(formData.email);
          break;
        case 'phone':
          errors['phone'] = validatePhone(formData.phone);
          break;
        case 'cpf':
          errors['cpf'] = validateCPF(formData.cpf);
          break;
        default:
          if (field.startsWith('address.')) {
            final addressErrors = validateAddress(formData.address);
            final key = field.split('.')[1];
            errors[field] = addressErrors[key];
          }
          break;
      }
    });
  }

  bool _validateAll() {
    final newErrors = <String, String?>{
      'name': validateName(formData.name),
      'email': validateEmail(formData.email),
      'phone': validatePhone(formData.phone),
      'cpf': validateCPF(formData.cpf),
    };

    final addressErrors = validateAddress(formData.address);
    for (var entry in addressErrors.entries) {
      newErrors['address.${entry.key}'] = entry.value;
    }

    setState(() => errors = newErrors);

    return newErrors.values.every((e) => e == null);
  }

  void handleSubmit() async {
    if (!_validateAll()) {
  print('Formulario inválido');
  return;
}
final cart = Provider.of<CartModel>(context, listen: false);

    formData.name = nameController.text;
    formData.email = emailController.text;
    formData.phone = phoneController.text;
    formData.cpf = cpfController.text;
    formData.address = Address(
      street: streetController.text,
      number: numberController.text,
      complement: complementController.text,
      neighborhood: neighborhoodController.text,
      city: cityController.text,
      state: stateController.text,
      cep: cepController.text,
    );
    formData.products = cart.items;
    formData.products = List.from(cart.items);

    print('Enviando datos del formulario...');
    print(formData.toJson());


    final success = await OrderService.sendOrder(formData);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Pedido enviado com sucesso!')),
  );
  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OrderConfirmationPage(formData: formData),
    ),
  );

  cart.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar o pedido')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    cepController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextField(
                controller: nameController,
                onChanged: (value) {
                  formData.name = value;
                  _validateField('name');
                },
                decoration: InputDecoration(
                  labelText: 'Nome',
                  errorText: errors['name'],
                ),
              ),
              TextField(
                controller: emailController,
                onChanged: (value) {
                  formData.email = value;
                  _validateField('email');
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: errors['email'],
                ),
              ),
              TextField(
                controller: phoneController,
                onChanged: (value) {
                  formData.phone = value;
                  _validateField('phone');
                },
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  errorText: errors['phone'],
                ),
              ),
              TextField(
                controller: cpfController,
                onChanged: (value) {
                  formData.cpf = value;
                  _validateField('cpf');
                },
                decoration: InputDecoration(
                  labelText: 'CPF',
                  errorText: errors['cpf'],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Endereço',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: cepController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  formData.address.cep = value;
                  _validateField('address.cep');
                },
                decoration: InputDecoration(
                  labelText: 'CEP',
                  errorText: errors['address.cep'],
                  suffixIcon: isLoadingCep
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => fetchAddressByCep(cepController.text),
                        ),
                ),
              ),
              TextField(
                controller: streetController,
                onChanged: (value) {
                  formData.address.street = value;
                  _validateField('address.street');
                },
                decoration: InputDecoration(
                  labelText: 'Rua',
                  errorText: errors['address.street'],
                ),
              ),
              TextField(
                controller: numberController,
                onChanged: (value) {
                  formData.address.number = value;
                  _validateField('address.number');
                },
                decoration: InputDecoration(
                  labelText: 'Número',
                  errorText: errors['address.number'],
                ),
              ),
              TextField(
                controller: complementController,
                onChanged: (value) => formData.address.complement = value,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              TextField(
                controller: neighborhoodController,
                onChanged: (value) {
                  formData.address.neighborhood = value;
                  _validateField('address.neighborhood');
                },
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  errorText: errors['address.neighborhood'],
                ),
              ),
              TextField(
                controller: cityController,
                onChanged: (value) {
                  formData.address.city = value;
                  _validateField('address.city');
                },
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  errorText: errors['address.city'],
                ),
              ),
              TextField(
                controller: stateController,
                maxLength: 2,
                onChanged: (value) {
                  formData.address.state = value.toUpperCase();
                  _validateField('address.state');
                },
                decoration: InputDecoration(
                  labelText: 'Estado (UF)',
                  errorText: errors['address.state'],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text('Enviar Pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
