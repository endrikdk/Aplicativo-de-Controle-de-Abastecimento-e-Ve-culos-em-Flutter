import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/veiculo_model.dart';
import '../services/veiculo_service.dart';
import 'tela_form_veiculo.dart';

class TelaVeiculos extends StatelessWidget {
  const TelaVeiculos({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = VeiculoService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Veículos')),
      body: StreamBuilder<List<Veiculo>>(
        stream: service.listarVeiculosDoUsuario(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar veículos: ${snapshot.error}'),
            );
          }

          final veiculos = snapshot.data ?? [];

          if (veiculos.isEmpty) {
            return const Center(
              child: Text('Nenhum veículo cadastrado ainda.'),
            );
          }

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final v = veiculos[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text('${v.modelo} - ${v.placa}'),
                subtitle: Text('${v.marca} • ${v.ano} • ${v.tipoCombustivel}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaFormVeiculo(veiculo: v),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir veículo'),
                        content: const Text(
                          'Tem certeza que deseja excluir este veículo?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await service.deletarVeiculo(v.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Novo veículo
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaFormVeiculo()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
