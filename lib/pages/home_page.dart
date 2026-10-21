import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/publicacao_service.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final texto = TextEditingController();
  final service = PublicacaoService();
  bool enviando = false;

  @override
  void dispose() {
    texto.dispose();
    super.dispose();
  }

  Future<void> publicar() async {
    if (texto.text.trim().isEmpty) return;
    setState(() => enviando = true);
    try {
      await service.publicar(texto.text);
      texto.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao publicar: $e')));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mural da Turma'), actions: [
        IconButton(tooltip: 'Meu perfil', icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilPage()))),
        IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () async => AuthService().sair()),
      ]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: AuthService().acompanharPerfil(),
            builder: (context, snapshot) {
              final nome = snapshot.data?.data()?['nome'] ?? FirebaseAuth.instance.currentUser?.email ?? 'Aluno';
              return Text('Olá, $nome!', style: Theme.of(context).textTheme.titleLarge);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: texto, maxLines: 2, maxLength: 280, decoration: const InputDecoration(labelText: 'O que você está pensando?', border: OutlineInputBorder())),
          Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: enviando ? null : publicar, child: const Text('Publicar'))),
        ])),
        const Divider(height: 1),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: service.acompanharMural(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Erro ao carregar mural: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final posts = snapshot.data!.docs;
            if (posts.isEmpty) return const Center(child: Text('Ninguém publicou ainda. Seja o primeiro!'));
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data();
                return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(post['autorNome'] ?? 'Usuário'),
                  subtitle: Text(post['texto'] ?? ''),
                ));
              },
            );
          },
        )),
      ]))),
    );
  }
}
