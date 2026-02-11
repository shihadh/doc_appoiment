class BranchModel {
  final int id;
  final String name;
  final String location;

  BranchModel({required this.id, required this.name, required this.location});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class TreatmentModel {
  final int id;
  final String name;
  final String? duration;
  final String? price;

  TreatmentModel({
    required this.id,
    required this.name,
    this.duration,
    this.price,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      duration: json['duration'],
      price: json['price'],
    );
  }
}
