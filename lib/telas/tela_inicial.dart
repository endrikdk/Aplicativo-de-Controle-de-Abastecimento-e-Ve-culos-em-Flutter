import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'tela_login.dart';
import 'tela_veiculos.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user != null
                  ? 'Bem-vindo, ${user.email}'
                  : 'Bem-vindo ao Controle de Abastecimento',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaVeiculos()),
                );
              },
              icon: const Icon(Icons.directions_car),
              label: const Text('Meus Veículos'),
            ),
          ],
        ),
      ),
    );
  }
}
