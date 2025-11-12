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
        title: const Text('Controle de Abastecimento'),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Bem-vindo!'),
              accountEmail: Text(user?.email ?? 'Usuário'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo, size: 40),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaVeiculos()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_gas_station),
              title: const Text('Registrar Abastecimento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TelaFormAbastecimento(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Abastecimentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TelaHistoricoAbastecimentos(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaLogin()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                height: 500,
                child: Image.asset(
                  'assets/images/endrik.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.directions_car,
                    size: 120,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Bem-vindo ao Controle de Abastecimento',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Gerencie seus veículos e acompanhe o consumo de forma simples e prática!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaVeiculos()),
                  );
                },
                icon: const Icon(Icons.directions_car),
                label: const Text('Acessar Meus Veículos'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
