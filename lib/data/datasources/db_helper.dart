import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/medicamento_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        specialty TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medicamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        laboratorio TEXT NOT NULL,
        origenLaboratorio TEXT,
        tipoMedicamento TEXT,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE retiros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicamento TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        doctor TEXT NOT NULL
      )
    ''');
  }

  // MÉTODOS DE USUARIOS
  Future<User?> getUser(String name, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertUser(User user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap());
  }

  // MÉTODOS DE MEDICAMENTOS
  Future<List<Medicamento>> getMedicamentos() async {
    final db = await instance.database;
    final result = await db.query('medicamentos');
    return result.map((e) => Medicamento.fromMap(e)).toList();
  }

  Future<void> updateMedicamento(Medicamento m) async {
    final db = await instance.database;
    await db.update(
      'medicamentos',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  Future<void> deleteMedicamento(int id) async {
  final db = await instance.database;
  await db.delete('medicamentos', where: 'id = ?', whereArgs: [id]);
}

  // MÉTODOS DE RETIROS
  Future<void> registrarRetiro(String medicamento, int cantidad, String doctor) async {
    final db = await instance.database;
    await db.insert('retiros', {
      'medicamento': medicamento,
      'cantidad': cantidad,
      'doctor': doctor,
    });
  }

  Future<List<Map<String, dynamic>>> getRetiros() async {
    final db = await instance.database;
    return await db.query('retiros');
  }

  Future<void> insertMedicamento(Medicamento medicamento) async {
  final db = await database;
  await db.insert('medicamentos', medicamento.toMap());
}

}
