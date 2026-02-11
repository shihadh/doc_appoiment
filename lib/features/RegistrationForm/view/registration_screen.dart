import 'package:doc_appoinment/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controller/registration_controller.dart';
import '../model/branch_treatment_model.dart';
import '../widgets/treatment_dialog.dart';
import '../pdf/pdf_service.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _RegistrationScreenBody(formKey: _formKey);
  }
}

class _RegistrationScreenBody extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const _RegistrationScreenBody({required this.formKey});

  @override
  State<_RegistrationScreenBody> createState() =>
      _RegistrationScreenBodyState();
}

class _RegistrationScreenBodyState extends State<_RegistrationScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
            ],
            title: const Text('Register Patient'),
          ),
          body: controller.isLoading && controller.branches.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Patient Name'),
                        TextFormField(
                          controller: controller.nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter patient full name',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('WhatsApp Number'),
                        TextFormField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter WhatsApp number',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Full Address'),
                        TextFormField(
                          controller: controller.addressController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter full address',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Branch'),
                        DropdownButtonFormField<BranchModel>(
                          dropdownColor: AppTheme.secondaryColor,
                          initialValue: controller.selectedBranch,
                          items: controller.branches.map((b) {
                            return DropdownMenuItem(
                              value: b,
                              child: Text(b.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              context
                                      .read<RegistrationController>()
                                      .selectedBranch =
                                  val,
                          decoration: const InputDecoration(
                            hintText: 'Select branch',
                          ),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Treatments'),
                        ...controller.selectedTreatments.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((item) {
                              final index = item.key + 1;
                              final entry = item.value;
                              final t = controller.treatments.firstWhere(
                                (element) => element.id == entry.key,
                              );
                              return _buildTreatmentCard(
                                index,
                                t,
                                entry.value,
                                controller,
                              );
                            })
                            .toList(),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => const TreatmentDialog(),
                              );
                              context
                                  .read<RegistrationController>()
                                  .calculateTotals();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor
                                  .withValues(alpha: 0.2),
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add Treatments',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Total Amount'),
                        TextFormField(
                          controller: controller.totalController,
                          readOnly: true,
                          decoration: const InputDecoration(hintText: '0.00'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Discount Amount'),
                        TextFormField(
                          controller: controller.discountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => context
                              .read<RegistrationController>()
                              .updateBalance(),
                          decoration: const InputDecoration(hintText: '0.00'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Payment Method'),
                        Row(
                          children: [
                            _buildPaymentOption('Cash', controller),
                            _buildPaymentOption('Card', controller),
                            _buildPaymentOption('UPI', controller),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Advance Amount'),
                        TextFormField(
                          controller: controller.advanceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => context
                              .read<RegistrationController>()
                              .updateBalance(),
                          decoration: const InputDecoration(hintText: '0.00'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Balance Amount'),
                        TextFormField(
                          controller: controller.balanceController,
                          readOnly: true,
                          decoration: const InputDecoration(hintText: '0.00'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Executive'),
                        TextFormField(
                          controller: controller.executiveController,
                          decoration: const InputDecoration(
                            hintText: 'Enter executive name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Booking Date'),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              context
                                      .read<RegistrationController>()
                                      .selectedDate =
                                  date;
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            child: Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(controller.selectedDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Booking Time'),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: controller.selectedTime,
                            );
                            if (time != null) {
                              context
                                      .read<RegistrationController>()
                                      .selectedTime =
                                  time;
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            child: Text(
                              controller.selectedTime.format(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : () => _handleSubmit(context),
                            child: controller.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPaymentOption(String value, RegistrationController controller) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(value),
        value: value,
        groupValue: controller.paymentController.text,
        onChanged: (val) {
          if (val != null) {
            setState(
              () =>
                  context
                          .read<RegistrationController>()
                          .paymentController
                          .text =
                      val,
            );
          }
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTreatmentCard(
    int index,
    TreatmentModel treatment,
    Map<String, int> counts,
    RegistrationController controller,
  ) {
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
                  context.read<RegistrationController>().removeTreatment(
                    treatment.id,
                  );
                  context.read<RegistrationController>().calculateTotals();
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red.withValues(alpha:  0.4),
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
                  context.read<RegistrationController>().calculateTotals();
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

  void _handleSubmit(BuildContext context) async {
    if (widget.formKey.currentState!.validate()) {
      final controller = context.read<RegistrationController>();
      if (controller.selectedTreatments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one treatment')),
        );
        return;
      }

      final success = await controller.submitRegistration();

      if (success && mounted) {
        // Generate PDF
        final treatmentsList = controller.selectedTreatments.entries.map((e) {
          final t = controller.treatments.firstWhere(
            (element) => element.id == e.key,
          );
          return {
            'name': t.name,
            'price': t.price ?? '0',
            'male': e.value['male'],
            'female': e.value['female'],
          };
        }).toList();

        await PdfService.generatePatientPdf(
          name: controller.nameController.text,
          phone: controller.phoneController.text,
          address: controller.addressController.text,
          branch: controller.selectedBranch?.name ?? '',
          bookingDate: DateFormat(
            'dd/MM/yyyy - hh:mm a',
          ).format(DateTime.now()),
          treatments: treatmentsList,
          total: double.tryParse(controller.totalController.text) ?? 0,
          discount: double.tryParse(controller.discountController.text) ?? 0,
          advance: double.tryParse(controller.advanceController.text) ?? 0,
          balance: double.tryParse(controller.balanceController.text) ?? 0,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration Failed')));
      }
    }
  }
}
