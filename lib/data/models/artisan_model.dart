import './wilaya_model.dart';
import './specialization_model.dart';
import './artisan_image_model.dart';

class Artisan {
  final int artisanId;
  final String uid;
  final String fullName;
  final String? phone;
  final Wilaya wilaya;
  final DateTime createdDate;
  final String? bio;
  final String? profileImage;
  late double? latitude;
  late double? longitude;
  final List<Specialization> specializations;
  final List<ArtisanImage> images;

  Artisan({
    required this.artisanId,
    required this.uid,
    required this.fullName,
    this.phone,
    required this.wilaya,
    required this.createdDate,
    this.bio,
    this.profileImage,
    this.latitude,
    this.longitude,
    this.specializations = const [],
    this.images = const [],
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      artisanId: json['artisanid'] ?? 0,
      uid: json['uid'] ?? '',
      fullName: json['fullname'] ?? '',
      phone: json['phone'],
      wilaya: Wilaya.fromJson(json['wilayas'] ?? {}),
      createdDate: DateTime.parse(json['createddate'] ?? DateTime.now().toString()),
      bio: json['bio'],
      profileImage: json['profileimage'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      specializations: (json['artisanspecializations'] as List<dynamic>?)
          ?.map((s) => Specialization.fromJson(s['specializations'] ?? {}))
          .toList() ?? [],
      images: (json['artisanimages'] as List<dynamic>?)
          ?.map((i) => ArtisanImage.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artisanid': artisanId,
      'uid': uid,
      'fullname': fullName,
      'phone': phone,
      'wilayas': wilaya.toJson(),
      'createddate': createdDate.toIso8601String(),
      'bio': bio,
      'profileimage': profileImage,
      'latitude': latitude,
      'longitude': longitude,
      'artisanspecializations': specializations
          .map((s) => {'specializations': s.toJson()})
          .toList(),
      'artisanimages': images.map((i) => i.toJson()).toList(),
    };
  }

}