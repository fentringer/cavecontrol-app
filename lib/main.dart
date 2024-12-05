import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/product.dart';
import 'models/button.dart';
import 'pages/product_form.dart';

void main() {
  runApp(const CaveControlApp());
}

class CaveControlApp extends StatelessWidget {
  const CaveControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaveControl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _products;
  late Future<ButtonState> _buttonState;
  final ApiService apiService = ApiService(baseUrl: 'https://cavecontrol-api-production.up.railway.app');

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadButtonState();
  }

  void _loadProducts() {
    apiService.fetchProducts().then((products) {
      setState(() {
        _products = Future.value(products);
      });
    }).catchError((error) {
      setState(() {
        _products = Future.error(error);
      });
    });
  }

  void _loadButtonState() {
    setState(() {
      _buttonState = apiService.fetchButtonState();
    });
  }

  void _toggleButtonState() {
    _buttonState.then((currentState) {
      final newState = ButtonState(id: currentState.id, isActive: !currentState.isActive);
      apiService.updateButtonState(newState).then((_) {
        _loadButtonState();
      }).catchError((error) {
        // Handle error if needed
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossa Lista'),
      ),
      body: Stack(
        children: [
          // RefreshIndicator para recarregar a lista ao arrastar para baixo
          RefreshIndicator(
            onRefresh: () async {
              _loadProducts(); // Chama o método que atualiza os produtos
              await Future.delayed(const Duration(seconds: 1)); // Simula tempo de carregamento
            },
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Quantidade: ${product.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            apiService.deleteProduct(product.id).then((_) {
                              _loadProducts();
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao excluir produto: $error')),
                              );
                            });
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormPage(
                                apiService: apiService,
                                product: product,
                                onProductSaved: _loadProducts,
                              ),
                            ),
                          ).then((_) {
                            _loadProducts();
                          });
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Nenhum produto encontrado.'));
                }
              },
            ),
          ),

          // Botão de coração
          FutureBuilder<ButtonState>(
            future: _buttonState,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData) {
                final buttonState = snapshot.data!;
                return Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: _toggleButtonState,
                    backgroundColor: buttonState.isActive
                        ? Colors.red // Ativo: vermelho
                        : Theme.of(context).floatingActionButtonTheme.backgroundColor, // Inativo: cor padrão
                    child: Icon(
                      Icons.favorite,
                      color: buttonState.isActive
                          ? Colors.white // Ativo: ícone branco
                          : Theme.of(context).iconTheme.color, // Inativo: ícone padrão
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),

          // Novo botão com ícone de caixa de diálogo ao lado do botão de coração
          Positioned(
            bottom: 20,
            left: 90, // Alinha o botão ao lado do botão de coração
            child: FloatingActionButton(
              onPressed: () {
                // Adicionar funcionalidade aqui
              },
              child: const Icon(Icons.chat_bubble),
            ),
          ),

          // Botão flutuante para adicionar produto
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormPage(apiService: apiService, onProductSaved: _loadProducts),
                  ),
                );

                if (result != null && result == 'update') {
                  _loadProducts();
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
