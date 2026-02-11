import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/patient_model.dart';

class PatientService {
  final DioClient _dioClient = DioClient();

  Future<(List<PatientModel>?, String?)> getPatients() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.patientList);

      if (response.statusCode == 200) {
        final List datas = response.data['patient'];
        final data = datas.map((e) => PatientModel.fromJson(e)).toList();
        return (data, null);
      }
      return (null, 'Failed to fetch patients: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return (null, 'Unauthorized access');
      }
      return (null, e.message ?? 'An unexpected error occurred');
    } catch (e) {
      return (null, e.toString());
    }
  }
}
