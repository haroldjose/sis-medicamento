import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/login_page.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()) );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gestion de Medicamentos',
      home: LoginPage(),
    );
  }
}
