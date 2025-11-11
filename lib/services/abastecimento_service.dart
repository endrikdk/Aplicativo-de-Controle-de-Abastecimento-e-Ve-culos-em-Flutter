import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/abastecimento_model.dart';

class AbastecimentoService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _colecao => _db.collection('abastecimentos');

  Stream<List<Abastecimento>> listarAbastecimentosDoUsuario(String userId) {
    return _colecao
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Abastecimento.fromDocument(doc)).toList(),
        );
  }

  Stream<List<Abastecimento>> listarPorVeiculo(
    String userId,
    String veiculoId,
  ) {
    return _colecao
        .where('userId', isEqualTo: userId)
        .where('veiculoId', isEqualTo: veiculoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Abastecimento.fromDocument(doc)).toList(),
        );
  }

  Future<void> salvarAbastecimento(Abastecimento a) async {
    final data = a.toMap();

    if (a.id.isEmpty) {
      await _colecao.add(data);
    } else {
      await _colecao.doc(a.id).update(data);
    }
  }

  Future<void> deletarAbastecimento(String id) async {
    await _colecao.doc(id).delete();
  }
}
