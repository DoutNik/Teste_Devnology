import 'package:flutter/foundation.dart';
import 'product_model.dart';

class CartModel extends ChangeNotifier {
  final Map<Product, int> _items = {};

  List<Product> get items =>
      _items.entries.expand((e) => List.filled(e.value, e.key)).toList();

  List<Product> get uniqueItems => _items.keys.toList();

  int getQuantity(Product product) => _items[product] ?? 0;

  void add(Product product) {
    _items[product] = (_items[product] ?? 0) + 1;
    notifyListeners();
  }

  void decrease(Product product) {
    if (_items.containsKey(product)) {
      final count = _items[product]!;
      if (count > 1) {
        _items[product] = count - 1;
      } else {
        _items.remove(product);
      }
      notifyListeners();
    }
  }

  void removeAll(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice => _items.entries
      .fold(0, (total, entry) => total + (entry.key.price * entry.value));
}
