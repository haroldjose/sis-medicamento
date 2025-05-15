import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestionmedicamentos/core/providers.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';


final currentUserProvider = StateProvider<UserEntity?>((ref) => null);

final userNotifierProvider = Provider((ref) {
  final repository = ref.watch(appRepositoryProvider);
  return UserNotifier(repository, ref);
});

class UserNotifier {
  final AppRepository repository;
  final Ref ref;

  UserNotifier(this.repository, this.ref);

  Future<bool> login(String name, String password) async {
    final user = await repository.getUser(name, password);
    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user;
      return true;
    }
    return false;
  }

  Future<void> register(UserEntity user) async {
    await repository.insertUser(user);
  }
}
