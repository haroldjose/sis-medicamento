import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/user_provider.dart';
import '../../application/providers/medicamento_provider.dart';

class RetiroMedicamentosPage extends ConsumerStatefulWidget {

  const RetiroMedicamentosPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RetiroMedicamentosPage> createState() =>
      _RetiroMedicamentosPageState();
}

class _RetiroMedicamentosPageState
    extends ConsumerState<RetiroMedicamentosPage> {
  final cantidadController = TextEditingController();
  dynamic seleccionado;

  @override
  void initState() {
    super.initState();
    ref.read(medicamentoProvider.notifier).loadMedicamentos();
    ref.read(medicamentoProvider.notifier).loadRetiros();
  }

  void registrarRetiro() async {
    final user = ref.read(currentUserProvider);
    final cantidad = int.tryParse(cantidadController.text) ?? 0;

    if (seleccionado == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona medicamento y cantidad válida')),
      );
      return;
    }

    final success = await ref.read(medicamentoProvider.notifier).retirarMedicamento(
          medicamento: seleccionado,
          cantidad: cantidad,
          doctor: user?.name,
        );

    if (success) {
      cantidadController.clear();
      setState(() => seleccionado = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay suficiente stock')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final medicamentosState = ref.watch(medicamentoProvider);
    
    final retiros = ref.watch(medicamentoProvider.notifier).retiro;


    return Scaffold(
      appBar: AppBar(title: const Text('Retiros de Medicamentos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (user?.role == 'doctor') ...[
              medicamentosState.when(
                data: (data) {
                  final medicamentos = data;
                  return DropdownButtonFormField(
                    hint: const Text('Selecciona medicamento'),
                    value: seleccionado,
                    onChanged: (m) => setState(() => seleccionado = m),
                    items: medicamentos
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text('${m.nombre} (Stock: ${m.cantidad})'),
                            ))
                        .toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error al cargar medicamentos'),
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad a retirar'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: registrarRetiro,
                child: const Text('Retirar'),
              ),
              const Divider(),
            ],
            const Text(
              'Historial de Retiros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: retiros.length,
                itemBuilder: (_, i) {
                  final r = retiros[i];
                  return ListTile(
                    title: Text('${r['medicamento']} - ${r['cantidad']} u.'),
                    subtitle: Text('Retirado por: ${r['doctor']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

