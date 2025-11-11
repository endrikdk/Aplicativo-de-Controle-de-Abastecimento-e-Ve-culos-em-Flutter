import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'tela_login.dart';
import 'tela_veiculos.dart';
import 'tela_form_abastecimento.dart';
import 'tela_historico_abastecimentos.dart';

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user != null
                    ? 'Bem-vindo, ${user.email}'
                    : 'Bem-vindo ao Controle de Abastecimento',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaFormAbastecimento(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_gas_station),
                label: const Text('Registrar Abastecimento'),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaHistoricoAbastecimentos(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Histórico de Abastecimentos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
