import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  final String id;
  final String veiculoId;
  final String userId;
  final DateTime data;
  final double quantidadeLitros;
  final double valorPago;
  final int quilometragem;
  final String tipoCombustivel;
  final double consumo;
  final String observacao;

  Abastecimento({
    required this.id,
    required this.veiculoId,
    required this.userId,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    required this.consumo,
    required this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'veiculoId': veiculoId,
      'userId': userId,
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'consumo': consumo,
      'observacao': observacao,
    };
  }

  factory Abastecimento.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Abastecimento(
      id: doc.id,
      veiculoId: data['veiculoId'] ?? '',
      userId: data['userId'] ?? '',
      data: (data['data'] as Timestamp).toDate(),
      quantidadeLitros: (data['quantidadeLitros'] ?? 0).toDouble(),
      valorPago: (data['valorPago'] ?? 0).toDouble(),
      quilometragem: (data['quilometragem'] ?? 0).toInt(),
      tipoCombustivel: data['tipoCombustivel'] ?? '',
      consumo: (data['consumo'] ?? 0).toDouble(),
      observacao: data['observacao'] ?? '',
    );
  }
}
