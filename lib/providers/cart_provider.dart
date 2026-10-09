
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  final Set<int> _wishlist = {};

  Map<int, CartItem> get items => _items;
  Set<int> get wishlist => _wishlist;

  CartProvider() {
    loadSavedData();
  }

  int get itemCount {
    return _items.values.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, item) =>
          sum + item.product.price * item.quantity,
    );
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final savedCart = prefs.getString('cart');

      if (savedCart != null) {
        final List data = jsonDecode(savedCart);

        for (final entry in data) {
          final product = Product.fromJson(
            Map<String, dynamic>.from(entry['product']),
          );

          _items[product.id] = CartItem(
            product: product,
            quantity: entry['quantity'] as int,
          );
        }
      }

      final savedWishlist =
          prefs.getStringList('wishlist') ?? [];

      _wishlist.addAll(
        savedWishlist.map((id) => int.parse(id)),
      );
    } catch (_) {
      // Ignore invalid saved data.
    }

    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _items.values.map((item) {
      return {
        'product': item.product.toJson(),
        'quantity': item.quantity,
      };
    }).toList();

    await prefs.setString('cart', jsonEncode(data));
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'wishlist',
      _wishlist.map((id) => id.toString()).toList(),
    );
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }

    _saveCart();
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }

    _saveCart();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    if (_wishlist.contains(product.id)) {
      _wishlist.remove(product.id);
    } else {
      _wishlist.add(product.id);
    }

    _saveWishlist();
    notifyListeners();
  }

  bool isWishlisted(int productId) {
    return _wishlist.contains(productId);
  }
}