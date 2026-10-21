import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muralapp/services/comentario_service.dart';
import 'package:provider/provider.dart';
import '../services/comentario_service.dart';
class ComentariosPage extends StatefulWidget {
  final String publicacaoId;
  final String autorNome;
  final String texto;

  const ComentariosPage({
    super.key,
    required this.publicacaoId,
    required this.autorNome,
    required this.texto,
  });

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  final comentarioController = TextEditingController();
  bool enviando = false;

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  Future<void> enviarComentario() async {
    if (comentarioController.text.trim().isEmpty) return;

    setState(() => enviando = true);

    try {
      await context.read<ComentarioService>().comentar(
            texto: comentarioController.text,
            publicacaoId: widget.publicacaoId,
          );
      comentarioController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao comentar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Future<void> excluirComentario(String id) async {
    try {
      await context.read<ComentarioService>().excluir(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ComentarioService>(
      create: (_) => ComentarioService(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Comentários')),
          body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(widget.autorNome),
                subtitle: Text(widget.texto),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: context
                    .read<ComentarioService>()
                    .acompanharComentarios(widget.publicacaoId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar comentários: ${snapshot.error}',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final comentarios = snapshot.data!.docs.toList();

                  comentarios.sort((a, b) {
                    final ta = a.data()['data'] as Timestamp?;
                    final tb = b.data()['data'] as Timestamp?;
                    return (ta?.millisecondsSinceEpoch ?? 0)
                        .compareTo(tb?.millisecondsSinceEpoch ?? 0);
                  });

                  if (comentarios.isEmpty) {
                    return const Center(
                      child: Text('Nenhum comentário ainda.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: comentarios.length,
                    itemBuilder: (context, index) {
                      final comentario = comentarios[index];
                      final dados = comentario.data();

                      final meuUid =
                          FirebaseAuth.instance.currentUser?.uid;
                      final uidDoComentario = dados['uid'] ?? '';

                      final meuComentario = meuUid == uidDoComentario;

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(dados['nome'] ?? 'Usuário'),
                        subtitle: Text(dados['texto'] ?? ''),
                        trailing: meuComentario
                            ? IconButton(
                                tooltip: 'Excluir comentário',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    excluirComentario(comentario.id),
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: comentarioController,
                      maxLines: 2,
                      maxLength: 280,
                      decoration: const InputDecoration(
                        labelText: 'Escreva um comentário...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: enviando ? null : enviarComentario,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
