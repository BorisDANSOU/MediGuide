import '../../domain/entities/health_task_entity.dart';

class HealthTasksLocalDataSource {
  const HealthTasksLocalDataSource();

  Future<List<HealthTaskEntity>> loadHealthTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _healthTasks;
  }

  static final List<HealthTaskEntity> _healthTasks = [
    // --- Consultations ---
    HealthTaskEntity(
      id: 'cpn1',
      title: 'CPN 1 - Première consultation',
      description: 'Bilan initial, prise de sang, évaluation générale',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'cpn2',
      title: 'CPN 2 - Deuxième consultation',
      description: 'Suivi échographie, dépistage anomalies',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'cpn3',
      title: 'CPN 3 - Troisième consultation',
      description: 'Préparation accouchement, plan naissance',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 60)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'cpn4',
      title: 'CPN 4 - Quatrième consultation',
      description: 'Suivi position fœtale, préparation final',
      category: HealthTaskCategory.consultation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 90)),
      isCompleted: false,
    ),

    // --- Vaccinations ---
    HealthTaskEntity(
      id: 'vat1',
      title: 'Vaccination antitétanique (VAT) 1',
      description: 'Première dose pour protection mère et bébé',
      category: HealthTaskCategory.vaccination,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'vat2',
      title: 'Vaccination antitétanique (VAT) 2',
      description: 'Deuxième dose 1 mois après la première',
      category: HealthTaskCategory.vaccination,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 45)),
      isCompleted: false,
    ),

    // --- Examens ---
    HealthTaskEntity(
      id: 'echo1',
      title: 'Échographie 1er trimestre',
      description: 'Détermination âge gestationnel, viabilité',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'echo2',
      title: 'Échographie morphologique',
      description: 'Bilan anatomique complet (20-22 SA)',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 25)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'echo3',
      title: 'Échographie 3ème trimestre',
      description: 'Biométrie et position fœtale (30-32 SA)',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 85)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'blood1',
      title: 'Bilan biologique T1',
      description: 'Groupe sanguin, sérologie, dépistage IST',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'blood2',
      title: 'Bilan biologique T2',
      description: 'Hémoglobine, glycémie, OMS',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'blood3',
      title: 'Bilan biologique T3',
      description: 'Contrôle final avant accouchement',
      category: HealthTaskCategory.examination,
      priority: HealthTaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 90)),
      isCompleted: false,
    ),

    // --- Nutrition ---
    HealthTaskEntity(
      id: 'supp1',
      title: 'Supplémentation en fer',
      description: 'Complémentation quotidienne (100-200 mg/jour)',
      category: HealthTaskCategory.nutrition,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'supp2',
      title: 'Supplémentation en acide folique',
      description: '400 µg/jour jusqu\'à 12 SA',
      category: HealthTaskCategory.nutrition,
      priority: HealthTaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'diet1',
      title: 'Consultation nutritionniste',
      description: 'Équilibre alimentaire, prévention anémie',
      category: HealthTaskCategory.nutrition,
      priority: HealthTaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
    ),

    // --- Sécurité / Signes d'alerte ---
    HealthTaskEntity(
      id: 'safety1',
      title: 'Reconnaître les signes d\'alerte',
      description: 'Saignements, contractions, perte liquide',
      category: HealthTaskCategory.safety,
      priority: HealthTaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'safety2',
      title: 'Numéros d\'urgence enregistrés',
      description: 'SAMU, maternité de garde, taxi maternité',
      category: HealthTaskCategory.safety,
      priority: HealthTaskPriority.urgent,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'safety3',
      title: 'Itinéraire vers maternité',
      description: 'Connaître le chemin et temps de trajet',
      category: HealthTaskCategory.safety,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 85)),
      isCompleted: false,
    ),

    // --- Préparation ---
    HealthTaskEntity(
      id: 'prep1',
      title: 'Trousse d\'accouchement',
      description: 'Préparer les affaires pour la maternité',
      category: HealthTaskCategory.preparation,
      priority: HealthTaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 110)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'prep2',
      title: 'Inscription maternité',
      description: 'Enregistrer la naissance à l\'avance',
      category: HealthTaskCategory.preparation,
      priority: HealthTaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 85)),
      isCompleted: false,
    ),
    HealthTaskEntity(
      id: 'prep3',
      title: 'Séance de préparation à l\'accouchement',
      description: 'Exercices respiratoires, relaxation',
      category: HealthTaskCategory.preparation,
      priority: HealthTaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 100)),
      isCompleted: false,
    ),
  ];
}
