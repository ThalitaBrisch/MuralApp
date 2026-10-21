import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cadastro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    if (email.text.trim().isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha e-mail e senha.')));
      return;
    }
    setState(() => carregando = true);
    try {
      // O AuthGate na main.dart mostrará a Home automaticamente.
      await AuthService().entrar(email.text, senha.text);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha no login: $e')));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.forum, size: 72),
              const SizedBox(height: 12),
              const Text('Mural da Turma', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: senha, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: carregando ? null : entrar, child: const Text('Entrar')),
              TextButton(onPressed: carregando ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroPage())), child: const Text('Criar conta')),
            ]),
          ),
        ),
      ),
    );
  }
}
