import 'dart:convert';

import 'package:flutter/services.dart';

class MaternityLocalDataSource {
  const MaternityLocalDataSource({this._bundle});

  static const _assetPath = 'assets/data/maternity_reference.json';

  final AssetBundle? _bundle;

  Future<List<Map<String, dynamic>>> loadVaccines() async {
    final data = await _loadReferences();
    return _records(data, 'vaccines', 'recommendedMonth');
  }

  Future<List<Map<String, dynamic>>> loadCpnSchedule() async {
    final data = await _loadReferences();
    return _records(data, 'cpnSchedules', 'recommendedWeek');
  }

  Future<Map<String, dynamic>> _loadReferences() async {
    final content = await (_bundle ?? rootBundle).loadString(_assetPath);
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Maternity reference file must be an object.',
      );
    }
    return decoded;
  }

  List<Map<String, dynamic>> _records(
    Map<String, dynamic> data,
    String key,
    String scheduleField,
  ) {
    final records = data[key];
    if (records is! List) {
      throw FormatException('Missing maternity reference list "$key".');
    }
    final ids = <String>{};
    return records
        .map((record) {
          if (record is! Map<String, dynamic>) {
            throw FormatException(
              'Invalid record in maternity reference list "$key".',
            );
          }
          final id = record['id'];
          final name = record['name'];
          final scheduleValue = record[scheduleField];
          if (id is! String ||
              id.isEmpty ||
              !ids.add(id) ||
              name is! String ||
              name.isEmpty ||
              scheduleValue is! int ||
              scheduleValue < 0) {
            throw FormatException(
              'Invalid maternity reference record in "$key".',
            );
          }
          return Map<String, dynamic>.unmodifiable(record);
        })
        .toList(growable: false);
  }
}
