import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/registration_controller.dart';
import '../model/branch_treatment_model.dart';

class TreatmentDialog extends StatefulWidget {
  final TreatmentModel? initialTreatment;
  final int initialMale;
  final int initialFemale;

  const TreatmentDialog({
    super.key,
    this.initialTreatment,
    this.initialMale = 0,
    this.initialFemale = 0,
  });

  @override
  State<TreatmentDialog> createState() => _TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog> {
  TreatmentModel? selectedTreatment;
  late int maleCount;
  late int femaleCount;

  @override
  void initState() {
    super.initState();
    selectedTreatment = widget.initialTreatment;
    maleCount = widget.initialMale;
    femaleCount = widget.initialFemale;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<RegistrationController>(
            builder: (context, controller, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Treatment',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TreatmentModel>(
                    isExpanded: true,
                    value: selectedTreatment,
                    items: controller.treatments.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.name));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedTreatment = val),
                    decoration: const InputDecoration(
                      hintText: 'Choose preferred treatment',
                      fillColor: Color(0xFFF1F1F1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add Patients',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  _buildPatientCountRow('Male', maleCount, (val) {
                    setState(() => maleCount = val);
                  }),
                  const SizedBox(height: 15),
                  _buildPatientCountRow('Female', femaleCount, (val) {
                    setState(() => femaleCount = val);
                  }),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          selectedTreatment == null ||
                              (maleCount == 0 && femaleCount == 0)
                          ? null
                          : () {
                              context
                                  .read<RegistrationController>()
                                  .addTreatment(
                                    selectedTreatment!.id,
                                    maleCount,
                                    femaleCount,
                                  );
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCountRow(
    String label,
    int count,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => onChanged(count > 0 ? count - 1 : 0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 45,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => onChanged(count + 1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
