import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/product.dart';
import 'models/button.dart';
import 'pages/product_form.dart';
import 'pages/comment_form.dart';

void main() {
  runApp(const CaveControlApp());
}

class CaveControlApp extends StatelessWidget {
  const CaveControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nossa Lista',
      debugShowCheckedModeBanner: false,
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
  bool _hasComment = false;
  final ApiService apiService = ApiService(baseUrl: 'https://cavecontrol-api-production.up.railway.app');

  @override
  void initState() {
    super.initState();
    _products = _loadProducts();
    _buttonState = _loadButtonState();
    _checkCommentState();
  }

  Future<List<Product>> _loadProducts() async {
    try {
      return await apiService.fetchProducts();
    } catch (error) {
      throw Exception('Erro ao carregar produtos: $error');
    }
  }

  Future<ButtonState> _loadButtonState() async {
    try {
      return await apiService.fetchButtonState();
    } catch (error) {
      throw Exception('Erro ao carregar estado do botão: $error');
    }
  }

  Future<void> _checkCommentState() async {
    try {
      final comment = await apiService.fetchComment();
      setState(() {
        _hasComment = comment.content != null && comment.content!.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _hasComment = false;
      });
    }
  }

  void _toggleButtonState() async {
    try {
      final currentState = await _buttonState;
      final newState = ButtonState(id: currentState.id, isActive: !currentState.isActive);
      await apiService.updateButtonState(newState);
      setState(() {
        _buttonState = Future.value(newState);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alternar botão: $error')),
      );
    }
  }

  void _onCommentSaved(bool hasComment) {
    setState(() {
      _hasComment = hasComment;
    });
  }

  void _openCommentForm() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await _checkCommentState();

    Navigator.pop(context);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentFormPage(
          apiService: apiService,
          onCommentSaved: _onCommentSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossa Lista'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _products = _loadProducts();
              });
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
                              setState(() {
                                _products = _loadProducts();
                              });
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
                                onProductSaved: () {
                                  setState(() {
                                    _products = _loadProducts();
                                  });
                                },
                              ),
                            ),
                          );
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
          FutureBuilder<ButtonState>(
            future: _buttonState,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData) {
                final buttonState = snapshot.data!;
                return Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: _toggleButtonState,
                    backgroundColor: buttonState.isActive ? Colors.red : Theme.of(context).floatingActionButtonTheme.backgroundColor,
                    child: Icon(
                      Icons.favorite,
                      color: buttonState.isActive ? Colors.white : Colors.black,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 90,
            child: FloatingActionButton(
              onPressed: _openCommentForm,
              backgroundColor: _hasComment ? Colors.red : Theme.of(context).floatingActionButtonTheme.backgroundColor,
              child: Icon(
                Icons.chat_bubble,
                color: _hasComment ? Colors.white : Colors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormPage(apiService: apiService, onProductSaved: () {
                      setState(() {
                        _products = _loadProducts();
                      });
                    }),
                  ),
                );

                if (result != null && result == 'update') {
                  setState(() {
                    _products = _loadProducts();
                  });
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
