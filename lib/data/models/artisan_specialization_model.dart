class ArtisanSpecialization {
  final int artisanspecializationid;
  final int artisanId;
  final int specializationid;

  ArtisanSpecialization({
    required this.artisanspecializationid,
    required this.artisanId,
    required this.specializationid,
  });

  factory ArtisanSpecialization.fromJson(Map<String, dynamic> json) {
    return ArtisanSpecialization(
      artisanspecializationid: json['artisanspecializationid'] ?? 0,
      artisanId: json['artisanid'] ?? 0,
      specializationid: json['specializationid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artisanspecializationid': artisanspecializationid,
      'artisanid': artisanId,
      'specializationid': specializationid,
    };
  }
}