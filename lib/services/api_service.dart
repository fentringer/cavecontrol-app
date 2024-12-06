import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/button.dart';
import '../models/product.dart';
import '../models/comment.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(responseBody);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar produtos. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar produtos');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode != 204) {
        throw Exception('Falha ao excluir produto. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir produto');
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao criar produto. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar produto');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao editar produto. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao editar produto');
    }
  }

  Future<ButtonState> fetchButtonState() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/button/state'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ButtonState.fromJson(data);
      } else {
        throw Exception('Falha ao carregar estado do botão. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar estado do botão');
    }
  }

  Future<void> updateButtonState(ButtonState buttonState) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/button/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(buttonState.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao alterar estado do botão. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao alterar estado do botão');
    }
  }

  Future<Comment> fetchComment() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comment'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Comment.fromJson(data);
      } else {
        throw Exception('Falha ao carregar comentário. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar comentário');
    }
  }

  Future<void> updateComment(String content) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/comment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': content}),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar comentário. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar comentário');
    }
  }

  Future<void> deleteComment() async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/comment'));

      if (response.statusCode != 204) {
        throw Exception('Falha ao excluir comentário. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir comentário');
    }
  }
}
