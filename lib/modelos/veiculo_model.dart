import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  final String id;
  final String modelo;
  final String marca;
  final String placa;
  final int ano;
  final String tipoCombustivel;
  final String userId;

  Veiculo({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
      'userId': userId,
    };
  }

  factory Veiculo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Veiculo(
      id: doc.id,
      modelo: data['modelo'] ?? '',
      marca: data['marca'] ?? '',
      placa: data['placa'] ?? '',
      ano: (data['ano'] ?? 0) is int
          ? data['ano'] ?? 0
          : int.tryParse(data['ano'].toString()) ?? 0,
      tipoCombustivel: data['tipoCombustivel'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}
