import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/abastecimento_model.dart';
import '../modelos/veiculo_model.dart';
import '../services/abastecimento_service.dart';
import '../services/veiculo_service.dart';

class TelaFormAbastecimento extends StatefulWidget {
  final Abastecimento? abastecimento;

  const TelaFormAbastecimento({super.key, this.abastecimento});

  @override
  State<TelaFormAbastecimento> createState() => _TelaFormAbastecimentoState();
}

class _TelaFormAbastecimentoState extends State<TelaFormAbastecimento> {
  final _formKey = GlobalKey<FormState>();
  final _service = AbastecimentoService();
  final _veiculoService = VeiculoService();

  final _dataController = TextEditingController();
  final _litrosController = TextEditingController();
  final _valorController = TextEditingController();
  final _kmController = TextEditingController();
  final _consumoController = TextEditingController();
  final _obsController = TextEditingController();

  String _tipoCombustivel = 'Gasolina';
  String? _veiculoSelecionadoId;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final ab = widget.abastecimento;
    if (ab != null) {
      _dataController.text = _formatarData(ab.data);
      _litrosController.text = ab.quantidadeLitros.toString();
      _valorController.text = ab.valorPago.toStringAsFixed(2);
      _kmController.text = ab.quilometragem.toString();
      _consumoController.text = ab.consumo.toStringAsFixed(2);
      _tipoCombustivel = ab.tipoCombustivel;
      _veiculoSelecionadoId = ab.veiculoId;
      _obsController.text = ab.observacao;
    } else {
      _dataController.text = _formatarData(DateTime.now());
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    _litrosController.dispose();
    _valorController.dispose();
    _kmController.dispose();
    _consumoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _selecionarData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dataEscolhida != null) {
      _dataController.text = _formatarData(dataEscolhida);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _salvando = true);

    try {
      final partesData = _dataController.text.split('/');
      final data = Timestamp.fromDate(
        DateTime(
          int.parse(partesData[2]),
          int.parse(partesData[1]),
          int.parse(partesData[0]),
        ),
      );

      final litros = double.tryParse(_litrosController.text) ?? 0;
      final kmAtual = int.tryParse(_kmController.text) ?? 0;
      final valor = double.tryParse(_valorController.text) ?? 0;
      double consumo = 0;

      final ultimos = await FirebaseFirestore.instance
          .collection('abastecimentos')
          .where('userId', isEqualTo: user.uid)
          .where('veiculoId', isEqualTo: _veiculoSelecionadoId)
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (ultimos.docs.isNotEmpty) {
        final kmAnterior = (ultimos.docs.first['quilometragem'] ?? 0) as int;
        final kmRodado = (kmAtual - kmAnterior).toDouble();
        if (litros > 0 && kmRodado > 0) {
          consumo = kmRodado / litros;
        }
      } else {
        if (litros > 0 && kmAtual > 0) {
          consumo = kmAtual / litros;
        }
      }

      _consumoController.text = consumo.toStringAsFixed(2);

      final ab = Abastecimento(
        id: widget.abastecimento?.id ?? '',
        veiculoId: _veiculoSelecionadoId ?? '',
        userId: user.uid,
        data: data.toDate(),
        quantidadeLitros: litros,
        valorPago: valor,
        quilometragem: kmAtual,
        tipoCombustivel: _tipoCombustivel,
        consumo: consumo,
        observacao: _obsController.text.trim(),
      );

      await _service.salvarAbastecimento(ab);

      if (!mounted) return;
      setState(() => _salvando = false);

      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.abastecimento == null
                    ? 'Abastecimento registrado com sucesso!'
                    : 'Abastecimento atualizado com sucesso!',
              ),
            ),
          );
        }
      });
    } catch (e) {
      setState(() => _salvando = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.abastecimento == null
              ? 'Registrar Abastecimento'
              : 'Editar Abastecimento',
        ),
      ),
      body: StreamBuilder<List<Veiculo>>(
        stream: _veiculoService.listarVeiculosDoUsuario(user!.uid),
        builder: (context, snapshot) {
          final veiculos = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _dataController,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selecionarData,
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _veiculoSelecionadoId,
                    items: veiculos
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text('${v.modelo} - ${v.placa}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _veiculoSelecionadoId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Selecione um veículo' : null,
                    decoration: const InputDecoration(
                      labelText: 'Veículo associado',
                    ),
                  ),
                  TextFormField(
                    controller: _litrosController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade (L)',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Informe a quantidade de litros' : null,
                  ),
                  TextFormField(
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor pago (R\$)',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Informe o valor pago' : null,
                  ),
                  TextFormField(
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quilometragem atual',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Informe a quilometragem' : null,
                  ),
                  TextFormField(
                    controller: _consumoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Consumo (km/L)',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _tipoCombustivel,
                    items: const [
                      DropdownMenuItem(
                        value: 'Gasolina',
                        child: Text('Gasolina'),
                      ),
                      DropdownMenuItem(value: 'Etanol', child: Text('Etanol')),
                      DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                      DropdownMenuItem(value: 'GNV', child: Text('GNV')),
                      DropdownMenuItem(value: 'Flex', child: Text('Flex')),
                    ],
                    onChanged: (value) =>
                        setState(() => _tipoCombustivel = value ?? 'Gasolina'),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de combustível',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _obsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observação (opcional)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _salvando ? null : _salvar,
                    child: _salvando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
