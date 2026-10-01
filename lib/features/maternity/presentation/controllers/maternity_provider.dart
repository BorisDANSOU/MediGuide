import 'package:flutter/foundation.dart';

import '../../domain/entities/vaccine_entity.dart';

class MaternityProvider extends ChangeNotifier {
  MaternityProvider();

  List<VaccineEntity> _vaccines = const [];

  List<VaccineEntity> get vaccines => _vaccines;

  Future<void> loadVaccines() async {
    _vaccines = const [
      VaccineEntity(
        id: 'bcg',
        name: 'BCG',
        recommendedMonth: 0,
        status: false,
        description: 'Vaccin à la naissance',
      ),
    ];
    notifyListeners();
  }
}
