import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/maternity/domain/entities/cpn_entity.dart';
import 'package:mediguid/features/maternity/domain/entities/vaccine_entity.dart';
import 'package:mediguid/features/maternity/domain/repositories/maternity_repository.dart';
import 'package:mediguid/features/maternity/presentation/controllers/maternity_provider.dart';

void main() {
  test('loads CPN and vaccine schedules from the repository', () async {
    final provider = MaternityProvider(
      _FakeMaternityRepository(
        vaccines: const [
          VaccineEntity(
            id: 'bcg',
            name: 'BCG',
            recommendedMonth: 0,
            status: false,
          ),
        ],
        cpnSchedules: const [
          CpnEntity(id: 'cpn1', name: 'CPN 1', week: 12, completed: false),
        ],
      ),
    );

    await provider.loadSchedules();

    expect(provider.vaccines, hasLength(1));
    expect(provider.vaccines.single.name, 'BCG');
    expect(provider.cpnSchedules, hasLength(1));
    expect(provider.cpnSchedules.single.name, 'CPN 1');
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });

  test('exposes a generic error when schedule loading fails', () async {
    final provider = MaternityProvider(
      _FakeMaternityRepository(error: Exception('private detail')),
    );

    await provider.loadSchedules();

    expect(
      provider.errorMessage,
      'Impossible de charger les données maternité.',
    );
    expect(provider.errorMessage, isNot(contains('private detail')));
    expect(provider.isLoading, isFalse);
    provider.dispose();
  });
}

class _FakeMaternityRepository implements MaternityRepository {
  const _FakeMaternityRepository({
    this.vaccines = const [],
    this.cpnSchedules = const [],
    this.error,
  });

  final List<VaccineEntity> vaccines;
  final List<CpnEntity> cpnSchedules;
  final Object? error;

  @override
  Future<List<VaccineEntity>> getVaccinationSchedule() async {
    if (error != null) throw error!;
    return vaccines;
  }

  @override
  Future<List<CpnEntity>> getCpnSchedule() async {
    if (error != null) throw error!;
    return cpnSchedules;
  }
}
