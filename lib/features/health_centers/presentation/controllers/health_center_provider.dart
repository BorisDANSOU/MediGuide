import 'package:flutter/foundation.dart';

import '../../domain/entities/health_center_entity.dart';

class HealthCenterProvider extends ChangeNotifier {
  HealthCenterProvider();

  List<HealthCenterEntity> _centers = const [];
  bool _isLoading = false;

  List<HealthCenterEntity> get centers => _centers;
  bool get isLoading => _isLoading;

  Future<void> loadCenters() async {
    _isLoading = true;
    notifyListeners();

    _centers = const [
      HealthCenterEntity(
        id: 'demo',
        name: 'Centre Hospitalier Régional',
        type: 'hospital',
        latitude: 6.1375,
        longitude: 1.2123,
        city: 'Lomé',
        country: 'Togo',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
