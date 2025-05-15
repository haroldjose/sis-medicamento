import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestionmedicamentos/presentation/pages/qr_scan_page.dart';
import 'package:gestionmedicamentos/presentation/pages/retiro_medicamentos_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../application/providers/medicamento_provider.dart';
import '../../application/providers/user_provider.dart';
import '../pages/login_page.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/medicamento.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final UserEntity user;
  const AdminDashboard({super.key, required this.user});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController laboratorioController = TextEditingController();
  final TextEditingController origenController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  MedicamentoEntity? medicamentoEditando;

  @override
  void initState() {
    super.initState();
    ref.read(medicamentoProvider.notifier).loadMedicamentos();
    loadProfileImage();
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final user = ref.read(currentUserProvider);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${user?.name}_profile.png';
      final newImage = await File(pickedFile.path).copy(path);
      setState(() => _profileImage = newImage);
    }
  }

  Future<void> loadProfileImage() async {
    final user = ref.read(currentUserProvider);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${user?.name}_profile.png';
    if (File(path).existsSync()) {
      setState(() => _profileImage = File(path));
    }
  }

  void escanearQR() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QrScanPage(
              onScan: (code) {
                final parts = code.split(',');

                if (parts.length >= 6) {
                  nombreController.text = parts[0];
                  laboratorioController.text = parts[1];
                  origenController.text = parts[2];
                  tipoController.text = parts[3];
                  precioController.text = parts[4];
                  cantidadController.text = parts[5];
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formato de QR incorrecto')),
                  );
                }
              },
            ),
      ),
    );
  }

  void guardarMedicamento() {
    final nuevo = MedicamentoEntity(
      nombre: nombreController.text,
      laboratorio: laboratorioController.text,
      origenLaboratorio: origenController.text,
      tipoMedicamento: tipoController.text,
      precio: double.tryParse(precioController.text) ?? 0,
      cantidad: int.tryParse(cantidadController.text) ?? 0,
    );
    ref.read(medicamentoProvider.notifier).addMedicamento(nuevo);

    // Limpiar campos después de guardar
    nombreController.clear();
    laboratorioController.clear();
    origenController.clear();
    tipoController.clear();
    precioController.clear();
    cantidadController.clear();
  }

  void limpiarFormulario() {
    nombreController.clear();
    laboratorioController.clear();
    origenController.clear();
    tipoController.clear();
    precioController.clear();
    cantidadController.clear();
    setState(() {
      medicamentoEditando = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicamentosState = ref.watch(medicamentoProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Bienvenido, ${user?.name}'),
              accountEmail: Text(user?.role ?? ''),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('Tomar foto'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Seleccionar de galería'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child:
                      _profileImage == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                ),
              ),
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
            ),
            ListTile(
              title: const Text('Retiros de Medicamentos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetiroMedicamentosPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar Medicamentos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: laboratorioController,
              decoration: const InputDecoration(labelText: 'Laboratorio'),
            ),
            TextField(
              controller: origenController,
              decoration: const InputDecoration(labelText: 'Origen'),
            ),
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final nuevo = MedicamentoEntity(
                      nombre: nombreController.text,
                      laboratorio: laboratorioController.text,
                      origenLaboratorio: origenController.text,
                      tipoMedicamento: tipoController.text,
                      precio: double.tryParse(precioController.text) ?? 0,
                      cantidad: int.tryParse(cantidadController.text) ?? 0,
                    );

                    if (medicamentoEditando != null) {
                      // Es edición
                      final actualizado = medicamentoEditando!.copyWith(
                        nombre: nuevo.nombre,
                        laboratorio: nuevo.laboratorio,
                        origenLaboratorio: nuevo.origenLaboratorio,
                        tipoMedicamento: nuevo.tipoMedicamento,
                        precio: nuevo.precio,
                        cantidad: nuevo.cantidad,
                      );
                      ref
                          .read(medicamentoProvider.notifier)
                          .updateMedicamento(actualizado);
                    } else {
                      // Es nuevo
                      ref
                          .read(medicamentoProvider.notifier)
                          .addMedicamento(nuevo);
                    }

                    // Limpiar campos y resetear modo
                    limpiarFormulario();
                  },
                  child: Text(
                    medicamentoEditando != null ? 'Actualizar' : 'Guardar',
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Por QR'),
                  onPressed: escanearQR,
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Lista de Medicamentos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: medicamentosState.when(
                data:
                    (medicamentos) => ListView.builder(
                      itemCount: medicamentos.length,
                      itemBuilder: (_, i) {
                        final m = medicamentos[i]; 

                        return ListTile(
                          title: Text(m.nombre),
                          subtitle: Text(
                            'Lab: ${m.laboratorio} - Origen: ${m.origenLaboratorio} - Tipo: ${m.tipoMedicamento} - Precio: \$${m.precio} - Stock: ${m.cantidad}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    medicamentoEditando = m;
                                    nombreController.text = m.nombre;
                                    laboratorioController.text = m.laboratorio;
                                    origenController.text = m.origenLaboratorio;
                                    tipoController.text = m.tipoMedicamento;
                                    precioController.text = m.precio.toString();
                                    cantidadController.text =
                                        m.cantidad.toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text(
                                            '¿Eliminar medicamento?',
                                          ),
                                          content: Text(
                                            '¿Deseas eliminar "${m.nombre}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      medicamentoProvider
                                                          .notifier,
                                                    )
                                                    .deleteMedicamento(m);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Eliminar',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
