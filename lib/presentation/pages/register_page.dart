import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestionmedicamentos/domain/entities/user.dart';
import '../../application/providers/user_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  String role = 'admin';
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final specialtyController = TextEditingController();

  void register() async {
  final name = nameController.text;
  final password = passwordController.text;
  final specialty = role == 'doctor' ? specialtyController.text : null;

  if (name.isEmpty || password.isEmpty || (role == 'doctor' && (specialty?.isEmpty ?? true))) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Por favor, completa todos los campos')));
    return;
  }

  final user = UserEntity(
    name: name,
    password: password,
    role: role,
    specialty: specialty,
  );

  try {
    await ref.read(userNotifierProvider).register(user);
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error al registrar usuario')));
  }
}


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Registro')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButton<String>(
                value: role,
                onChanged: (value) => setState(() => role = value!),
                items: ['admin', 'doctor']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
              ),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
              if (role == 'doctor')
                TextField(controller: specialtyController, decoration: InputDecoration(labelText: 'Especialidad')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: register, child: Text('Registrarse'))
            ],
          ),
        ),
      );
}
