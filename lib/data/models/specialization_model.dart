class Specialization {
  final int specializationId;
  final String name;
  final String imageUrl;

  Specialization({
    required this.specializationId,
    required this.name,
    required this.imageUrl
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      specializationId: json['specializationid'] ?? -1,
      name: json['name'] ?? '',
      imageUrl: json['imageurl'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specializationid': specializationId,
      'name': name,
      'imageurl' : imageUrl
    };
  }
}