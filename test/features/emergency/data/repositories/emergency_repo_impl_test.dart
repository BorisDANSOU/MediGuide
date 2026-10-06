import 'package:flutter_test/flutter_test.dart';
import 'package:mediguid/features/emergency/data/datasources/emergency_local_ds.dart';
import 'package:mediguid/features/emergency/data/repositories/emergency_repo_impl.dart';

void main() {
  test('keeps Togo and Côte d’Ivoire emergency numbers separate', () async {
    final repository = EmergencyRepositoryImpl(EmergencyLocalDataSource());

    final togoNumbers = await repository.getEmergencyNumbers('TG');
    final ivoryCoastNumbers = await repository.getEmergencyNumbers('CI');

    expect(
      togoNumbers.map((item) => item.number),
      containsAll(['161', '117', '118']),
    );
    expect(togoNumbers.every((item) => item.country == 'TG'), isTrue);
    expect(
      ivoryCoastNumbers.map((item) => item.number),
      containsAll(['185', '180', '170']),
    );
    expect(
      ivoryCoastNumbers.every((item) => item.country == 'CI'),
      isTrue,
    );
  });
}
