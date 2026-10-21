
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComentarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> acompanharComentarios(
      String publicacaoId) {
    return _db
        .collection('comentarios')
        .where('publicacaoId', isEqualTo: publicacaoId)
        .snapshots();
  }

  Future<void> comentar({
    required String texto,
    required String publicacaoId,
  }) async {
    final usuario = _auth.currentUser!;

    final perfil =
        await _db.collection('usuarios').doc(usuario.uid).get();

    final nome = (perfil.data()?['nome'] as String?) ?? 'Usuário';

    await _db.collection('comentarios').add({
      'texto': texto.trim(),
      'nome': nome,
      'uid': usuario.uid,
      'publicacaoId': publicacaoId,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluir(String comentarioId) async {
    await _db.collection('comentarios').doc(comentarioId).delete();
  }
}
