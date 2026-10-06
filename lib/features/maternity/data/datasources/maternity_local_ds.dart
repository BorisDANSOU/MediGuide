class MaternityLocalDataSource {
  const MaternityLocalDataSource();

  Future<List<Map<String, dynamic>>> loadVaccines() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      {
        'id': 'bcg',
        'name': 'BCG',
        'recommendedMonth': 0,
        'status': false,
        'description': 'Vaccin indispensable à la naissance contre la tuberculose',
      },
      {
        'id': 'polio0',
        'name': 'Polio (VPO)',
        'recommendedMonth': 0,
        'status': false,
        'description': 'Première dose contre la poliomyélite',
      },
      {
        'id': 'penta1',
        'name': 'Pentavalent 1',
        'recommendedMonth': 2,
        'status': false,
        'description': 'Contre diphtérie, tétanos, coqueluche, hépatite B, Hib',
      },
      {
        'id': 'polio1',
        'name': 'Polio (VPO) 1',
        'recommendedMonth': 2,
        'status': false,
        'description': 'Deuxième dose contre la poliomyélite',
      },
      {
        'id': 'penta2',
        'name': 'Pentavalent 2',
        'recommendedMonth': 3,
        'status': false,
        'description': 'Deuxième dose pentavalent',
      },
      {
        'id': 'polio2',
        'name': 'Polio (VPO) 2',
        'recommendedMonth': 3,
        'status': false,
        'description': 'Troisième dose contre la poliomyélite',
      },
      {
        'id': 'penta3',
        'name': 'Pentavalent 3',
        'recommendedMonth': 4,
        'status': false,
        'description': 'Troisième dose pentavalent',
      },
      {
        'id': 'polio3',
        'name': 'Polio (VPO) 3',
        'recommendedMonth': 4,
        'status': false,
        'description': 'Quatrième dose contre la poliomyélite',
      },
      {
        'id': 'rrv1',
        'name': 'Rougeole-Rubéole (RRV) 1',
        'recommendedMonth': 9,
        'status': false,
        'description': 'Contre la rougeole et la rubéole',
      },
      {
        'id': 'mena',
        'name': 'Méningite A',
        'recommendedMonth': 15,
        'status': false,
        'description': 'Contre la méningite à méningocoque A',
      },
      {
        'id': 'rrv2',
        'name': 'Rougeole-Rubéole (RRV) 2',
        'recommendedMonth': 18,
        'status': false,
        'description': 'Deuxième dose contre la rougeole et la rubéole',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> loadCpnSchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      {
        'id': 'cpn1',
        'name': 'CPN 1',
        'recommendedWeek': 12,
        'completed': false,
        'description': 'Première consultation prénatale - Bilan initial',
      },
      {
        'id': 'cpn2',
        'name': 'CPN 2',
        'recommendedWeek': 20,
        'completed': false,
        'description': 'Deuxième consultation prénatale - Suivi échographie',
      },
      {
        'id': 'cpn3',
        'name': 'CPN 3',
        'recommendedWeek': 26,
        'completed': false,
        'description': 'Troisième consultation prénatale - Préparation accouchement',
      },
      {
        'id': 'cpn4',
        'name': 'CPN 4',
        'recommendedWeek': 32,
        'completed': false,
        'description': 'Quatrième consultation prénatale - Suivi position fœtale',
      },
    ];
  }
}
