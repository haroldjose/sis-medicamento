import 'package:gestionmedicamentos/data/models/medicamento_model.dart';
import 'package:gestionmedicamentos/data/models/user_model.dart';

import '../../data/datasources/db_helper.dart';
import '../../domain/entities/medicamento.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  final DBHelper dbHelper;
  

  AppRepositoryImpl(this.dbHelper);

  @override
  Future<List<MedicamentoEntity>> getMedicamentos() async {
    final list = await dbHelper.getMedicamentos();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateMedicamento(MedicamentoEntity medicamento) async {
    await dbHelper.updateMedicamento(Medicamento.fromEntity(medicamento));
  }

  @override
  Future<void> registrarRetiro(String medicamento, int cantidad, String doctor) async {
    await dbHelper.registrarRetiro(medicamento, cantidad, doctor);
  }

  @override
  Future<List<Map<String, dynamic>>> getRetiros() {
    return dbHelper.getRetiros();
  }

  @override
  Future<UserEntity?> getUser(String name, String password) async {
    final model = await dbHelper.getUser(name, password);
    return model?.toEntity();
  }

  @override
  Future<void> insertUser(UserEntity user) async {
    await dbHelper.insertUser(User.fromEntity(user));
  }
  
  @override
Future<void> addMedicamento(MedicamentoEntity medicamento) async {
  await dbHelper.insertMedicamento(Medicamento.fromEntity(medicamento));
}

@override
Future<void> deleteMedicamento(int id) async {
  await dbHelper.deleteMedicamento(id);
}


}
