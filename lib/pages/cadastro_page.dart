import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    if (nome.text.trim().isEmpty || email.text.trim().isEmpty || senha.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha tudo. A senha precisa de pelo menos 6 caracteres.')));
      return;
    }
    setState(() => carregando = true);
    try {
      await AuthService().cadastrar(nome.text, email.text, senha.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no cadastro: $e')));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: senha, obscureText: true, decoration: const InputDecoration(labelText: 'Senha (mínimo 6 caracteres)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: carregando ? null : cadastrar, child: const Text('Cadastrar')),
        ]),
      ))),
    );
  }
}
