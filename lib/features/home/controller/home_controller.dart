import 'package:flutter/material.dart';
import '../model/patient_model.dart';
import '../service/patient_service.dart';

class HomeController with ChangeNotifier {
  final PatientService _service = PatientService();

  final TextEditingController searchController = TextEditingController();

  List<PatientModel> _allPatients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = false;
  String? _error;

  List<PatientModel> get patients => _filteredPatients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final (data, error) = await _service.getPatients();

    if (error != null) {
      _error = error;
      _allPatients = [];
    } else {
      _allPatients = data ?? [];
    }
    _filteredPatients = List.from(_allPatients);

    _isLoading = false;
    notifyListeners();
  }

  void searchPatients() {
    final query = searchController.text;
    if (query.isEmpty) {
      _filteredPatients = List.from(_allPatients);
    } else {
      _filteredPatients = _allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query.toLowerCase()) ||
            patient.phone.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  void sortPatientsByDate() {
    _filteredPatients.sort((a, b) {
      final dateA = DateTime.tryParse(a.dateAndTime ?? '') ?? DateTime(0);
      final dateB = DateTime.tryParse(b.dateAndTime ?? '') ?? DateTime(0);
      return dateB.compareTo(dateA); // Descending order
    });
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
