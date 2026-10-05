import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/data/datasources/emergency_local_ds.dart';
import 'package:mediguid/features/emergency/data/repositories/emergency_repo_impl.dart';

void main() {
  test('keeps Togo and Côte d’Ivoire emergency numbers separate', () async {
    const repository = EmergencyRepositoryImpl(EmergencyLocalDataSource());

    final togoNumbers = await repository.getEmergenciesByCountry('Togo');
    final ivoryCoastNumbers = await repository.getEmergenciesByCountry(
      'Côte d’Ivoire',
    );

    expect(
      togoNumbers.map((item) => item.number),
      containsAll(['112', '117', '118']),
    );
    expect(togoNumbers.every((item) => item.country == 'Togo'), isTrue);
    expect(
      ivoryCoastNumbers.map((item) => item.number),
      containsAll(['185', '180', '170 / 111', '+225 27 20 25 35']),
    );
    expect(
      ivoryCoastNumbers.every((item) => item.country == 'Côte d’Ivoire'),
      isTrue,
    );
  });
}
