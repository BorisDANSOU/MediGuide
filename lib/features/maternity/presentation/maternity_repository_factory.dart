import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../data/datasources/health_tasks_firestore_data_source.dart';
import '../data/datasources/health_tasks_local_ds.dart';
import '../data/datasources/maternity_firestore_data_source.dart';
import '../data/datasources/maternity_guest_local_data_source.dart';
import '../data/datasources/maternity_local_ds.dart';
import '../data/repositories/health_tasks_firestore_repo_impl.dart';
import '../data/repositories/health_tasks_repo_impl.dart';
import '../data/repositories/maternity_firestore_repo_impl.dart';
import '../data/repositories/maternity_repo_impl.dart';
import '../domain/repositories/health_tasks_repository.dart';
import '../domain/repositories/maternity_repository.dart';

class MaternityRepositoryFactory {
  const MaternityRepositoryFactory._();

  static String? get currentUid {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Stream<User?>? get authChanges {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.authStateChanges();
  }

  static MaternityRepository maternity({required String? uid}) {
    if (uid == null) {
      return const MaternityRepositoryImpl(
        MaternityLocalDataSource(),
        guestDataSource: MaternityGuestLocalDataSource(),
      );
    }
    return MaternityFirestoreRepoImpl(
      uid: uid,
      dataSource: MaternityFirestoreDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );
  }

  static HealthTasksRepository healthTasks({required String? uid}) {
    const templates = HealthTasksLocalDataSource();
    if (uid == null) {
      return const HealthTasksRepoImpl(
        templates,
        guestDataSource: MaternityGuestLocalDataSource(),
      );
    }
    return HealthTasksFirestoreRepoImpl(
      dataSource: HealthTasksFirestoreDataSource(
        uid: uid,
        firestore: FirebaseFirestore.instance,
      ),
      templateDataSource: templates,
    );
  }
}
