

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  Future<List<Product>> getProducts() async {
    final url = Uri.parse(
      'https://fakestoreapi.com/products',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}