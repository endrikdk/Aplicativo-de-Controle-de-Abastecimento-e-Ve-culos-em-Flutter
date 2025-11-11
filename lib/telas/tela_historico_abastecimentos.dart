import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/abastecimento_model.dart';
import '../services/abastecimento_service.dart';
import 'tela_form_abastecimento.dart';

class TelaHistoricoAbastecimentos extends StatelessWidget {
  const TelaHistoricoAbastecimentos({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = AbastecimentoService();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Abastecimentos')),
      body: StreamBuilder<List<Abastecimento>>(
        stream: service.listarAbastecimentosDoUsuario(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar dados: ${snapshot.error}'),
            );
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum abastecimento registrado ainda.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final a = lista[index];
              final dataFormatada =
                  "${a.data.day.toString().padLeft(2, '0')}/${a.data.month.toString().padLeft(2, '0')}/${a.data.year}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.local_gas_station,
                    color: Colors.indigo,
                  ),
                  title: Text(
                    '$dataFormatada • ${a.tipoCombustivel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Litros: ${a.quantidadeLitros.toStringAsFixed(1)} L\n'
                      'Valor: R\$ ${a.valorPago.toStringAsFixed(2)}\n'
                      'KM Atual: ${a.quilometragem} km\n'
                      'Consumo: ${a.consumo.toStringAsFixed(2)} km/L',
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    // 🔹 Abre o formulário de edição
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaFormAbastecimento(abastecimento: a),
                      ),
                    );

                    // ✅ Após voltar da edição, recarrega lista automaticamente
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro atualizado.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Excluir registro',
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Excluir abastecimento'),
                          content: const Text(
                            'Tem certeza que deseja excluir este registro?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        await service.deletarAbastecimento(a.id);

                        // ✅ Exibe mensagem sem travar rebuild
                        Future.microtask(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Abastecimento excluído com sucesso!',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
