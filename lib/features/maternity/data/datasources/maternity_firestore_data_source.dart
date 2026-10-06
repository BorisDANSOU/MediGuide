import 'package:cloud_firestore/cloud_firestore.dart';

class MaternityFirestoreDataSource {
  MaternityFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Map<String, dynamic>>> loadReferences(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((document) => {'id': document.id, ...document.data()})
        .toList(growable: false);
  }

  Future<Map<String, Map<String, dynamic>>> loadProgress({
    required String uid,
    required String collection,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection(collection)
        .get();
    return {
      for (final document in snapshot.docs) document.id: document.data(),
    };
  }

  Future<void> mergeProgress({
    required String uid,
    required String collection,
    required String documentId,
    required Map<String, dynamic> fields,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(collection)
        .doc(documentId)
        .set(fields, SetOptions(merge: true));
  }
}
