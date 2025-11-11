import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'tela_login.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaLogin()),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bem-vindo ao Controle de Abastecimento!'),
      ),
    );
  }
}
