import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/registration_controller.dart';
import '../model/branch_treatment_model.dart';
import 'treatment_dialog.dart';

class TreatmentCard extends StatelessWidget {
  final int index;
  final TreatmentModel treatment;
  final Map<String, int> counts;

  const TreatmentCard({
    super.key,
    required this.index,
    required this.treatment,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index. ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  treatment.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final controller = context.read<RegistrationController>();
                  controller.removeTreatment(treatment.id);
                  controller.calculateTotals();
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red.withOpacity(0.4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 25),
              const Text(
                'Male',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${counts['male']}'),
              ),
              const SizedBox(width: 20),
              const Text(
                'Female',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${counts['female']}'),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => TreatmentDialog(
                      initialTreatment: treatment,
                      initialMale: counts['male']!,
                      initialFemale: counts['female']!,
                    ),
                  );
                  if (context.mounted) {
                    context.read<RegistrationController>().calculateTotals();
                  }
                },
                child: const Icon(
                  Icons.edit,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
