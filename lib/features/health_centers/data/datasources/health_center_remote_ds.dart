import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_center.dart';

class HealthCenterRemoteDataSource {
  HealthCenterRemoteDataSource({this.firestore});

  static const _collection = 'medical_centers';

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  Future<List<MedicalCenter>> fetchCenters({
    String? countryCode,
    String? city,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(_collection);
    if (countryCode != null) {
      query = query.where('countryCode', isEqualTo: countryCode);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((document) => MedicalCenter.fromMap(document.id, document.data()))
        .toList();
  }

  Stream<List<MedicalCenter>> watchCenters({
    required String countryCode,
    required String city,
  }) {
    return _db
        .collection(_collection)
        .where('countryCode', isEqualTo: countryCode)
        .where('city', isEqualTo: city)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    MedicalCenter.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }
}
