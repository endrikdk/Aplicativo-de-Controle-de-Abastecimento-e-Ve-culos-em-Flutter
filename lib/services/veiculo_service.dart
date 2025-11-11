import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/veiculo_model.dart';

class VeiculoService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _colecao => _db.collection('veiculos');

  Stream<List<Veiculo>> listarVeiculosDoUsuario(String userId) {
    return _colecao
        .where('userId', isEqualTo: userId)
        .orderBy('modelo')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Veiculo.fromDocument(doc)).toList(),
        );
  }

  Future<void> salvarVeiculo(Veiculo veiculo) async {
    final data = veiculo.toMap();

    if (veiculo.id.isEmpty) {
      await _colecao.add(data);
    } else {
      await _colecao.doc(veiculo.id).update(data);
    }
  }

  Future<void> deletarVeiculo(String id) async {
    await _colecao.doc(id).delete();
  }
}
