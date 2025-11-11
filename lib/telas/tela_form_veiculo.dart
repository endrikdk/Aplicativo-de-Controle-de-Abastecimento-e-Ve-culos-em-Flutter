import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/veiculo_model.dart';
import '../services/veiculo_service.dart';

class TelaFormVeiculo extends StatefulWidget {
  final Veiculo? veiculo; // null = novo, não null = edição

  const TelaFormVeiculo({super.key, this.veiculo});

  @override
  State<TelaFormVeiculo> createState() => _TelaFormVeiculoState();
}

class _TelaFormVeiculoState extends State<TelaFormVeiculo> {
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  String _tipoCombustivel = 'Gasolina';

  final _service = VeiculoService();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final v = widget.veiculo;
    if (v != null) {
      _modeloController.text = v.modelo;
      _marcaController.text = v.marca;
      _placaController.text = v.placa;
      _anoController.text = v.ano.toString();
      _tipoCombustivel = v.tipoCombustivel;
    }
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
      return;
    }

    setState(() => _salvando = true);

    final ano = int.tryParse(_anoController.text.trim()) ?? 0;

    final veiculo = Veiculo(
      id: widget.veiculo?.id ?? '',
      modelo: _modeloController.text.trim(),
      marca: _marcaController.text.trim(),
      placa: _placaController.text.trim(),
      ano: ano,
      tipoCombustivel: _tipoCombustivel,
      userId: user.uid,
    );

    await _service.salvarVeiculo(veiculo);

    setState(() => _salvando = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.veiculo == null
              ? 'Veículo cadastrado com sucesso!'
              : 'Veículo atualizado com sucesso!',
        ),
      ),
    );

    Navigator.pop(context); // volta para a lista de veículos
  }

  @override
  Widget build(BuildContext context) {
    final edicao = widget.veiculo != null;

    return Scaffold(
      appBar: AppBar(title: Text(edicao ? 'Editar Veículo' : 'Novo Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o modelo' : null,
              ),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a marca' : null,
              ),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a placa' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o ano' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoCombustivel,
                items: const [
                  DropdownMenuItem(value: 'Gasolina', child: Text('Gasolina')),
                  DropdownMenuItem(value: 'Etanol', child: Text('Etanol')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'GNV', child: Text('GNV')),
                  DropdownMenuItem(value: 'Flex', child: Text('Flex')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoCombustivel = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(edicao ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
