import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class VaccineCard extends StatelessWidget {
  const VaccineCard({
    super.key,
    required this.name,
    required this.month,
    required this.completed,
    this.description,
    this.onScheduleReminder,
  });

  final String name;
  final int month;
  final bool completed;
  final String? description;
  final VoidCallback? onScheduleReminder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.pending,
          color: completed ? AppColors.primary : AppColors.info,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mois recommandé : $month'),
            if (description != null) Text(description!),
          ],
        ),
        trailing: onScheduleReminder != null
            ? IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onScheduleReminder,
                tooltip: 'Planifier un rappel',
              )
            : null,
      ),
    );
  }
}
