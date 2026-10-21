import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<void> cadastrar(String nome, String email, String senha) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    try {
      await _db.collection('usuarios').doc(credencial.user!.uid).set({
        'nome': nome.trim(),
        'email': email.trim(),
      });
    } catch (_) {
      throw Exception('Conta criada, mas não foi possível salvar o perfil.');
    }
  }

  Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: senha);
  }

  Future<void> sair() => _auth.signOut();

  Stream<DocumentSnapshot<Map<String, dynamic>>> acompanharPerfil() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('usuarios').doc(uid).snapshots();
  }
}
