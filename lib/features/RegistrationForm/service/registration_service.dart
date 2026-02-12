import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/branch_treatment_model.dart';

class RegistrationService {
  final DioClient _dioClient = DioClient();

  Future<(List<BranchModel>?, String?)> getBranches() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.branchList);
      if (response.statusCode == 200) {
        final List datas = response.data['branches'] ?? [];
        final data = datas.map((e) => BranchModel.fromJson(e)).toList();
        return (data, null);
      }
      return (null, 'Failed to fetch branches');
    } catch (e) {
      return (null, e.toString());
    }
  }

  Future<(List<TreatmentModel>?, String?)> getTreatments() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.treatmentList);
      if (response.statusCode == 200) {
        final List datas = response.data['treatments'] ?? [];
        final data = datas.map((e) => TreatmentModel.fromJson(e)).toList();
        return (data, null);
      }
      return (null, 'Failed to fetch treatments');
    } catch (e) {
      return (null, e.toString());
    }
  }

  Future<(bool, String?)> registerPatient(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      log(  'FormData for registration: ${formData.fields} and files: ${formData.files}');
      final response = await _dioClient.dio.post(
        ApiConstants.patientUpdate,
        data: formData,
      );

      if (response.statusCode == 200) {
        return (true, null);
      }
      return (false, 'Registration failed: ${response.statusCode}');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
