import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/publicacao_service.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final publicacoes = PublicacaoService();
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: auth.acompanharPerfil(),
          builder: (context, snapshot) {
            final perfil = snapshot.data?.data();
            return Column(children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 35)),
              const SizedBox(height: 10),
              Text(perfil?['nome'] ?? 'Meu perfil', style: Theme.of(context).textTheme.titleLarge),
              Text(FirebaseAuth.instance.currentUser?.email ?? ''),
            ]);
          },
        )),
        const Text('Minhas publicações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: publicacoes.acompanharMinhas(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final posts = snapshot.data!.docs.toList();
            // Ordena localmente para evitar exigir índice composto no Firestore.
            posts.sort((a, b) {
              final ta = a.data()['data'] as Timestamp?;
              final tb = b.data()['data'] as Timestamp?;
              return (tb?.millisecondsSinceEpoch ?? 0).compareTo(ta?.millisecondsSinceEpoch ?? 0);
            });
            if (posts.isEmpty) return const Center(child: Text('Você ainda não publicou nada.'));
            return ListView.builder(itemCount: posts.length, itemBuilder: (context, index) {
              final post = posts[index];
              return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(
                title: Text(post.data()['texto'] ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Excluir publicação', onPressed: () async {
                  try {
                    await publicacoes.excluir(post.id);
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível excluir: $e')));
                  }
                }),
              ));
            });
          },
        )),
      ]))),
    );
  }
}
