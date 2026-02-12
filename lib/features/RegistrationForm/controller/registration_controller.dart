import 'dart:developer';

import 'package:flutter/material.dart';
import '../model/branch_treatment_model.dart';
import '../service/registration_service.dart';

class RegistrationController with ChangeNotifier {
  final RegistrationService _service = RegistrationService();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final executiveController = TextEditingController();
  final paymentController = TextEditingController(text: 'Cash');
  final totalController = TextEditingController();
  final discountController = TextEditingController();
  final advanceController = TextEditingController();
  final balanceController = TextEditingController();

  List<BranchModel> _branches = [];
  List<TreatmentModel> _treatments = [];

  List<BranchModel> get branches => _branches;
  List<TreatmentModel> get treatments => _treatments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Selected Data
  BranchModel? _selectedBranch;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  BranchModel? get selectedBranch => _selectedBranch;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;

  set selectedBranch(BranchModel? val) {
    _selectedBranch = val;
    notifyListeners();
  }

  set selectedDate(DateTime val) {
    _selectedDate = val;
    notifyListeners();
  }

  set selectedTime(TimeOfDay val) {
    _selectedTime = val;
    notifyListeners();
  }

  // Selected treatments list for the patient
  // Format: {treatmentId: {male: count, female: count}}
  final Map<int, Map<String, int>> _selectedTreatments = {};
  Map<int, Map<String, int>> get selectedTreatments => _selectedTreatments;

  void calculateTotals() {
    double total = 0;
    for (var entry in _selectedTreatments.entries) {
      final t = _treatments.firstWhere((element) => element.id == entry.key);
      final price = double.tryParse(t.price ?? '0') ?? 0;
      total += price * (entry.value['male']! + entry.value['female']!);
    }

    totalController.text = total.toStringAsFixed(2);
    updateBalance();
  }

  void updateBalance() {
    double total = double.tryParse(totalController.text) ?? 0;
    double discount = double.tryParse(discountController.text) ?? 0;
    double advance = double.tryParse(advanceController.text) ?? 0;
    double balance = total - discount - advance;
    balanceController.text = balance.toStringAsFixed(2);
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final (branchesData, _) = await _service.getBranches();
    final (treatmentsData, _) = await _service.getTreatments();

    _branches = branchesData ?? [];
    _treatments = treatmentsData ?? [];

    _isLoading = false;
    notifyListeners();
  }

  void addTreatment(int treatmentId, int male, int female) {
    if (male > 0 || female > 0) {
      _selectedTreatments[treatmentId] = {'male': male, 'female': female};
      notifyListeners();
    }
  }

  void removeTreatment(int treatmentId) {
    _selectedTreatments.remove(treatmentId);
    notifyListeners();
  }

  String getSelectedTreatmentNames() {
    return _selectedTreatments.keys
        .map((id) {
          return _treatments.firstWhere((element) => element.id == id).name;
        })
        .join(', ');
  }

  Future<bool> submitRegistration() async {
    _isLoading = true;
    notifyListeners();

    final treatmentIds = _selectedTreatments.keys.join(',');
    final maleIds = _selectedTreatments.entries
        .where((e) => e.value['male']! > 0)
        .map((e) => e.key)
        .join(',');
    final femaleIds = _selectedTreatments.entries
        .where((e) => e.value['female']! > 0)
        .map((e) => e.key)
        .join(',');

    final data = {
      'name': nameController.text,
      'excecutive': executiveController.text,
      'payment': paymentController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'total_amount': (double.tryParse(totalController.text) ?? 0).toInt(),
      'discount_amount': (double.tryParse(discountController.text) ?? 0)
          .toInt(),
      'advance_amount': (double.tryParse(advanceController.text) ?? 0).toInt(),
      'balance_amount': (double.tryParse(balanceController.text) ?? 0).toInt(),
      'date_nd_time':
          '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}-${selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
      'id': '',
      'male': maleIds,
      'female': femaleIds,
      'branch': selectedBranch?.id.toString() ?? '',
      'treatments': treatmentIds,
    };
    log('Submitting registration with data: $data');
    final (success, _) = await _service.registerPatient(data);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void clearData() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    executiveController.clear();
    paymentController.text = 'Cash';
    totalController.clear();
    discountController.clear();
    advanceController.clear();
    balanceController.clear();
    _selectedBranch = null;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedTreatments.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    executiveController.dispose();
    paymentController.dispose();
    totalController.dispose();
    discountController.dispose();
    advanceController.dispose();
    balanceController.dispose();
    super.dispose();
  }
}
