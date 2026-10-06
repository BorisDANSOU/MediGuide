import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/data/datasources/emergency_local_ds.dart';
import 'package:mediguid/features/emergency/data/repositories/emergency_repo_impl.dart';
import 'package:mediguid/features/emergency/domain/entities/emergency_facilities_snapshot.dart';
import 'package:mediguid/features/health_centers/data/datasources/health_center_remote_ds.dart';
import 'package:mediguid/features/health_centers/data/models/medical_center.dart';

class _FakeHealthCenterRemoteDataSource extends HealthCenterRemoteDataSource {
  _FakeHealthCenterRemoteDataSource(this.stream);

  final Stream<List<MedicalCenter>> stream;
  String? requestedCountryCode;
  String? requestedCity;

  @override
  Stream<List<MedicalCenter>> watchCenters({
    required String countryCode,
    required String city,
  }) {
    requestedCountryCode = countryCode;
    requestedCity = city;
    return stream;
  }
}

MedicalCenter _center({
  required String id,
  String type = 'hospital',
  bool isGuard = false,
  double latitude = 6.13,
  double longitude = 1.22,
  String? phone,
  String? address,
  bool is24h = false,
}) => MedicalCenter(
  id: id,
  name: 'Centre $id',
  nameLower: 'centre $id',
  type: type,
  countryCode: 'TG',
  country: 'Togo',
  city: 'Lomé',
  latitude: latitude,
  longitude: longitude,
  phone: phone,
  address: address,
  is24h: is24h,
  isGuard: isGuard,
);

EmergencyRepositoryImpl _repository(
  Stream<List<MedicalCenter>> stream, {
  bool signedIn = true,
}) => EmergencyRepositoryImpl(
  const EmergencyLocalDataSource(),
  remoteDataSource: _FakeHealthCenterRemoteDataSource(stream),
  isAuthenticated: () => signedIn,
);

void main() {
  test('maps and sorts hospitals and on-duty pharmacies by distance', () async {
    final remote = _FakeHealthCenterRemoteDataSource(
      Stream.value([
        _center(
          id: 'hospital-far',
          latitude: 6.2,
          longitude: 1.3,
          phone: '+228 22 00 00',
        ),
        _center(
          id: 'pharmacy-near',
          type: 'pharmacy',
          isGuard: true,
          address: 'Quartier Centre',
          phone: '+228 22 11 11',
        ),
        _center(id: 'clinic', type: 'clinic'),
        _center(id: 'pharmacy-not-guard', type: 'pharmacy'),
        _center(id: 'hospital-near', is24h: true),
      ]),
    );
    final repository = EmergencyRepositoryImpl(
      const EmergencyLocalDataSource(),
      remoteDataSource: remote,
      isAuthenticated: () => true,
    );

    final snapshot = await repository
        .watchFacilities(
          countryCode: 'TG',
          city: 'Lomé',
          lat: 6.13,
          lng: 1.22,
        )
        .single;

    expect(remote.requestedCountryCode, 'TG');
    expect(remote.requestedCity, 'Lomé');
    expect(snapshot.source, EmergencyFacilitiesSource.firestore);
    expect(
      snapshot.hospitals.map((center) => center.id),
      ['hospital-near', 'hospital-far'],
    );
    expect(snapshot.hospitals.first.isOpen24h, isTrue);
    expect(snapshot.hospitals.first.phone, isNull);
    expect(snapshot.pharmacies.map((center) => center.id), ['pharmacy-near']);
    expect(snapshot.pharmacies.single.address, 'Quartier Centre');
    expect(snapshot.pharmacies.single.isOnDuty, isTrue);
  });

  test('a valid empty Firestore snapshot does not use local facilities', () async {
    final snapshot = await _repository(
      Stream.value(const <MedicalCenter>[]),
    ).watchFacilities(
      countryCode: 'TG',
      city: 'Lomé',
      lat: 6.13,
      lng: 1.22,
    ).single;

    expect(snapshot.source, EmergencyFacilitiesSource.firestore);
    expect(snapshot.hospitals, isEmpty);
    expect(snapshot.pharmacies, isEmpty);
  });

  test('a guest gets explicit local facility fallback', () async {
    final snapshot = await _repository(
      const Stream<List<MedicalCenter>>.empty(),
      signedIn: false,
    ).watchFacilities(
      countryCode: 'TG',
      city: 'Lomé',
      lat: 6.13,
      lng: 1.22,
    ).single;

    expect(snapshot.source, EmergencyFacilitiesSource.localFallback);
    expect(snapshot.hospitals, isNotEmpty);
    expect(snapshot.pharmacies, isNotEmpty);
  });

  test('missing Firebase initialization falls back to local facilities', () async {
    final repository = EmergencyRepositoryImpl(
      const EmergencyLocalDataSource(),
      remoteDataSource: _FakeHealthCenterRemoteDataSource(
        const Stream<List<MedicalCenter>>.empty(),
      ),
      isAuthenticated: () => throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'no-app',
      ),
    );

    final snapshot = await repository
        .watchFacilities(
          countryCode: 'TG',
          city: 'Lomé',
          lat: 6.13,
          lng: 1.22,
        )
        .single;

    expect(snapshot.source, EmergencyFacilitiesSource.localFallback);
    expect(snapshot.hospitals, isNotEmpty);
  });

  for (final code in ['permission-denied', 'unavailable']) {
    test('Firestore $code switches to local facilities', () async {
      final snapshot = await _repository(
        Stream<List<MedicalCenter>>.error(
          FirebaseException(plugin: 'cloud_firestore', code: code),
        ),
      ).watchFacilities(
        countryCode: 'TG',
        city: 'Lomé',
        lat: 6.13,
        lng: 1.22,
      ).single;

      expect(snapshot.source, EmergencyFacilitiesSource.localFallback);
      expect(snapshot.hospitals, isNotEmpty);
      expect(snapshot.pharmacies, isNotEmpty);
    });
  }

  test('non-recoverable Firestore errors are propagated', () async {
    final error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'failed-precondition',
    );

    await expectLater(
      _repository(Stream<List<MedicalCenter>>.error(error)).watchFacilities(
        countryCode: 'TG',
        city: 'Lomé',
        lat: 6.13,
        lng: 1.22,
      ),
      emitsError(same(error)),
    );
  });

  test('remote stream keeps emitting updates while subscribed', () async {
    final controller = StreamController<List<MedicalCenter>>();
    final snapshots = _repository(controller.stream)
        .watchFacilities(
          countryCode: 'TG',
          city: 'Lomé',
          lat: 6.13,
          lng: 1.22,
        )
        .take(2)
        .toList();

    controller
      ..add([_center(id: 'first')])
      ..add([_center(id: 'second')]);

    final values = await snapshots;
    expect(values.map((value) => value.hospitals.single.id), [
      'first',
      'second',
    ]);
    await controller.close();
  });
}
