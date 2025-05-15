class UserEntity {
  final int? id;
  final String name;
  final String password;
  final String role;
  final String? specialty;

  UserEntity({
    this.id,
    required this.name,
    required this.password,
    required this.role,
    this.specialty,
  });

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, role: $role, specialty: $specialty)';
  }
}
