import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final ApiService apiService;
  final Product? product;
  final VoidCallback? onProductSaved;

  const ProductFormPage({
    super.key,
    required this.apiService,
    this.product,
    this.onProductSaved,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late FocusNode _nameFocusNode;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _nameFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }


  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? 0,
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
      );

      if (widget.product == null) {

        widget.apiService.createProduct(product).then((_) {
          if (widget.onProductSaved != null) {
            widget.onProductSaved!();
          }
          Navigator.pop(context);
        }).catchError((error) {
          _showErrorSnackbar('Erro ao adicionar produto: $error');
        });
      } else {

        widget.apiService.updateProduct(product).then((_) {
          if (widget.onProductSaved != null) {
            widget.onProductSaved!();
          }
          Navigator.pop(context);
        }).catchError((error) {
          _showErrorSnackbar('Erro ao editar produto: $error');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Adicionar Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(labelText: 'Nome'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_quantityFocusNode);
                },
              ),
              TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Por favor, insira uma quantidade válida maior que zero';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _saveProduct();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
