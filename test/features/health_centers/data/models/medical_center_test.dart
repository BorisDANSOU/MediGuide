import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/health_centers/data/models/medical_center.dart';

void main() {
  test('parses Firestore fields and uses the document ID', () {
    final center = MedicalCenter.fromMap('node_123', {
      'name': 'Centre Médical',
      'nameLower': 'centre medical',
      'type': 'clinic',
      'countryCode': 'TG',
      'country': 'Togo',
      'city': 'Lomé',
      'latitude': 6.13,
      'longitude': 1.21,
      'phone': '+228 00 00 00',
      'address': 'Avenue de la Paix',
      'openingHours': 'Mo-Fr 08:00-18:00',
      'is24h': true,
      'isGuard': true,
    });

    expect(center.id, 'node_123');
    expect(center.name, 'Centre Médical');
    expect(center.type, 'clinic');
    expect(center.countryCode, 'TG');
    expect(center.country, 'Togo');
    expect(center.city, 'Lomé');
    expect(center.latitude, 6.13);
    expect(center.longitude, 1.21);
    expect(center.phone, '+228 00 00 00');
    expect(center.address, 'Avenue de la Paix');
    expect(center.openingHours, 'Mo-Fr 08:00-18:00');
    expect(center.is24h, isTrue);
    expect(center.isGuard, isTrue);
  });

  test('preserves absent optional fields and boolean defaults', () {
    final center = MedicalCenter.fromMap('node_456', {
      'latitude': 6.13,
      'longitude': 1.21,
    });

    expect(center.phone, isNull);
    expect(center.address, isNull);
    expect(center.openingHours, isNull);
    expect(center.is24h, isFalse);
    expect(center.isGuard, isFalse);
  });
}
