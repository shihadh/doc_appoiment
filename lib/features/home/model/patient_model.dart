class PatientModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String? dateAndTime;
  final String? branch;
  final String? executive;
  final List<String> treatments;

  PatientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.dateAndTime,
    this.branch,
    this.executive,
    this.treatments = const [],
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      dateAndTime: json['date_nd_time'],
      branch: json['branch'] is Map ? json['branch']['name'] : json['branch'],
      executive: json['user'] ?? json['excecutive'],
      treatments: (json['patientdetails_set'] as List? ?? [])
          .map((e) => e['treatment_name'].toString())
          .toList(),
    );
  }
}
