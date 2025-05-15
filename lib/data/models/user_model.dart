import 'package:gestionmedicamentos/domain/entities/user.dart';

class User {
  final int? id;
  final String name;
  final String password;
  final String role;
  final String? specialty;

  User({
    this.id,
    required this.name,
    required this.password,
    required this.role,
    this.specialty,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      password: map['password'],
      role: map['role'],
      specialty: map['specialty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'role': role,
      'specialty': specialty,
    };
  }
  
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      password: password,
      role: role,
      specialty: specialty,
    );
  }

  /// Conversión desde entidad
  static User fromEntity(UserEntity entity) {
    return User(
      id: entity.id,
      name: entity.name,
      password: entity.password,
      role: entity.role,
      specialty: entity.specialty,
    );
  }


  

}
