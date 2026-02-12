import 'package:flutter/material.dart';
import '../controller/registration_controller.dart';

class PaymentOption extends StatelessWidget {
  final String value;
  final RegistrationController controller;

  const PaymentOption({
    super.key,
    required this.value,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(
          value,
          style: const TextStyle(fontSize: 12), // Adjusted for space
        ),
        value: value,
        groupValue: controller.paymentController.text,
        onChanged: (val) {
          if (val != null) {
            controller.paymentController.text = val;
            controller.updateBalance();
          }
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
