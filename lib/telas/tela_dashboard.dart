import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../modelos/abastecimento_model.dart';
import '../services/abastecimento_service.dart';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  final _service = AbastecimentoService();
  final _user = FirebaseAuth.instance.currentUser;

  double totalGasto = 0;
  double totalLitros = 0;
  double mediaConsumo = 0;
  Map<String, double> gastosPorMes = {};
  Map<String, double> consumoPorMes = {};

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (_user == null) return;
    final abastecimentos = await _service
        .listarAbastecimentosDoUsuario(_user!.uid)
        .first;

    if (abastecimentos.isEmpty) {
      setState(() => _carregando = false);
      return;
    }

    double somaGasto = 0;
    double somaLitros = 0;
    double somaConsumo = 0;

    final Map<String, double> gastoMes = {};
    final Map<String, double> consumoMes = {};

    for (final ab in abastecimentos) {
      somaGasto += ab.valorPago;
      somaLitros += ab.quantidadeLitros;
      somaConsumo += ab.consumo;

      final mes = "${ab.data.month.toString().padLeft(2, '0')}/${ab.data.year}";
      gastoMes.update(
        mes,
        (v) => v + ab.valorPago,
        ifAbsent: () => ab.valorPago,
      );
      consumoMes.update(mes, (v) => v + ab.consumo, ifAbsent: () => ab.consumo);
    }

    setState(() {
      totalGasto = somaGasto;
      totalLitros = somaLitros;
      mediaConsumo = somaConsumo / abastecimentos.length;
      gastosPorMes = gastoMes;
      consumoPorMes = consumoMes;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Consumo')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResumoCard(
                          icon: Icons.attach_money,
                          titulo: 'Total Gasto',
                          valor: 'R\$ ${totalGasto.toStringAsFixed(2)}',
                          color: Colors.indigo,
                        ),
                        _buildResumoCard(
                          icon: Icons.local_gas_station,
                          titulo: 'Total Litros',
                          valor: '${totalLitros.toStringAsFixed(1)} L',
                          color: Colors.orange,
                        ),
                        _buildResumoCard(
                          icon: Icons.speed,
                          titulo: 'Média Consumo',
                          valor: '${mediaConsumo.toStringAsFixed(2)} km/L',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    _buildGraficoBarras(),
                    const SizedBox(height: 40),

                    _buildGraficoLinhas(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildResumoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoBarras() {
    if (gastosPorMes.isEmpty) {
      return const Text('Nenhum dado suficiente para gerar gráfico.');
    }

    final meses = gastosPorMes.keys.toList();
    final dados = gastosPorMes.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gasto Mensal (R\$)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i >= 0 && i < meses.length) {
                        return Text(
                          meses[i],
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              barGroups: List.generate(meses.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: dados[i],
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(4),
                      width: 16,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoLinhas() {
    if (consumoPorMes.isEmpty) {
      return const Text('Nenhum dado suficiente para gerar gráfico.');
    }

    final meses = consumoPorMes.keys.toList();
    final dados = consumoPorMes.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consumo Médio (km/L)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.5,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i >= 0 && i < meses.length) {
                        return Text(
                          meses[i],
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    meses.length,
                    (i) => FlSpot(i.toDouble(), dados[i]),
                  ),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
