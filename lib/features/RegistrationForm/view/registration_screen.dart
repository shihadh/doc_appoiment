import 'package:doc_appoinment/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controller/registration_controller.dart';
import '../model/branch_treatment_model.dart';
import '../widgets/treatment_dialog.dart';
import '../widgets/treatment_card.dart';
import '../widgets/payment_option.dart';
import '../widgets/custom_label.dart';
import '../widgets/custom_text_field.dart';
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
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomLabel(text: 'Patient Name'),
                        CustomTextField(
                          controller: controller.nameController,
                          hintText: 'Enter patient full name',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'WhatsApp Number'),
                        CustomTextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          hintText: 'Enter WhatsApp number',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Full Address'),
                        CustomTextField(
                          controller: controller.addressController,
                          maxLines: 3,
                          hintText: 'Enter full address',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Branch'),
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
                        const CustomLabel(text: 'Treatments'),
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
                              return TreatmentCard(
                                index: index,
                                treatment: t,
                                counts: entry.value,
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
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
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
                        const CustomLabel(text: 'Total Amount'),
                        CustomTextField(
                          controller: controller.totalController,
                          readOnly: true,
                          hintText: '0.00',
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Discount Amount'),
                        CustomTextField(
                          controller: controller.discountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => controller.updateBalance(),
                          hintText: '0.00',
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Payment Method'),
                        Row(
                          children: [
                            PaymentOption(
                              value: 'Cash',
                              controller: controller,
                            ),
                            PaymentOption(
                              value: 'Card',
                              controller: controller,
                            ),
                            PaymentOption(value: 'UPI', controller: controller),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const CustomLabel(text: 'Advance Amount'),
                        CustomTextField(
                          controller: controller.advanceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => controller.updateBalance(),
                          hintText: '0.00',
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Balance Amount'),
                        CustomTextField(
                          controller: controller.balanceController,
                          readOnly: true,
                          hintText: '0.00',
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Executive'),
                        CustomTextField(
                          controller: controller.executiveController,
                          hintText: 'Enter executive name',
                        ),
                        const SizedBox(height: 16),
                        const CustomLabel(text: 'Booking Date'),
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
                              controller.selectedDate = date;
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
                        const CustomLabel(text: 'Booking Time'),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: controller.selectedTime,
                            );
                            if (time != null) {
                              controller.selectedTime = time;
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
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
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
            'dd/MM/yyyy | hh:mm a',
          ).format(DateTime.now()),
          treatmentDate: DateFormat(
            'dd/MM/yyyy',
          ).format(controller.selectedDate),
          treatmentTime: controller.selectedTime.format(context),
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
        controller.clearData();
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration Failed')));
      }
    }
  }
}
