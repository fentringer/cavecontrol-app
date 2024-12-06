import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class CommentFormPage extends StatefulWidget {
  final ApiService apiService;
  final Function(bool) onCommentSaved;

  const CommentFormPage({super.key, required this.apiService, required this.onCommentSaved});

  @override
  State<CommentFormPage> createState() => _CommentFormPageState();
}

class _CommentFormPageState extends State<CommentFormPage> {
  TextEditingController _commentController = TextEditingController();
  String _comment = '';

  @override
  void initState() {
    super.initState();
    _loadComment();
  }

  void _loadComment() async {
    try {
      final comment = await widget.apiService.fetchComment();
      setState(() {
        _comment = comment.content ?? '';
        _commentController.text = utf8.decode(_comment.codeUnits);
      });
    } catch (e) {
      setState(() {
        _comment = '';
        _commentController.clear();
      });
    }
  }

  void _saveComment() async {
    final newComment = _commentController.text;

    if (newComment.isNotEmpty) {
      try {
        final encodedComment = utf8.encode(newComment);
        await widget.apiService.updateComment(utf8.decode(encodedComment));
        widget.onCommentSaved(true);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar comentário: $e')));
      }
    }
  }

  void _deleteComment() async {
    try {
      await widget.apiService.updateComment('');
      widget.onCommentSaved(false);
      Navigator.pop(context);
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar comentário: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (text) {
                setState(() {
                  _comment = text;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveComment,
                  child: const Text('Salvar'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
