class Product {
  final int id;
  final String name;
  final int quantity;

  Product({required this.id, required this.name, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : 0, // Garantir que o id é um int
      name: json['name'] ?? '', // Se 'name' for null, atribui uma string vazia
      quantity: json['quantity'] is int ? json['quantity'] : 0, // Garantir que quantity é um int
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }
}
