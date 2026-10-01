import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile_entity.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider();

  UserProfileEntity _profile = const UserProfileEntity();

  UserProfileEntity get profile => _profile;

  Future<void> loadProfile() async {
    _profile = const UserProfileEntity(country: 'Togo', city: 'Lomé');
    notifyListeners();
  }

  Future<void> updateCountry({
    required String country,
    required String city,
  }) async {
    _profile = UserProfileEntity(country: country, city: city);
    notifyListeners();
  }
}
