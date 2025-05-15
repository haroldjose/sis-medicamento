import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestionmedicamentos/domain/entities/user.dart';
import 'package:gestionmedicamentos/presentation/pages/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gestionmedicamentos/application/providers/user_provider.dart';
import '../../application/providers/medicamento_provider.dart';
import 'retiro_medicamentos_page.dart';

class DoctorDashboard extends ConsumerStatefulWidget {
  final UserEntity user;
  const DoctorDashboard({super.key,required this.user});

  @override
  ConsumerState<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends ConsumerState<DoctorDashboard> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    ref.read(medicamentoProvider.notifier).loadMedicamentos();
    loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final medicamentosState = ref.watch(medicamentoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Médico')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Dr. ${user?.name} (${user?.specialty})'),
              accountEmail: Text(user?.role ??''),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Column(
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
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,);
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
          children: [
            const Text(
              'Lista de Medicamentos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: medicamentosState.when(
                data: (medicamentos) {
                  return ListView.builder(
                    itemCount: medicamentos.length,
                    itemBuilder: (_, i) {
                      final m = medicamentos[i];
                      return ListTile(
                        title: Text(m.nombre),
                        subtitle: Text(
                          'Lab: ${m.laboratorio} - \$${m.precio} - Stock: ${m.cantidad}',
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
