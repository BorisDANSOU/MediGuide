import 'package:flutter/foundation.dart';

import '../../domain/entities/emergency_number_entity.dart';

class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider();

  List<EmergencyNumberEntity> _numbers = const [];

  List<EmergencyNumberEntity> get numbers => _numbers;

  Future<void> loadForCountry(String country) async {
    _numbers = [
      EmergencyNumberEntity(
        id: '112',
        name: 'Urgence médicale',
        number: '112',
        country: country,
      ),
      EmergencyNumberEntity(
        id: '117',
        name: 'Police',
        number: '117',
        country: country,
      ),
    ];
    notifyListeners();
  }
}
