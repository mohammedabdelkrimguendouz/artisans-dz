class ArtisanImage {
  final int artisanImageId;
  final int artisanId;
  final String imageUrl;

  ArtisanImage({
    required this.artisanImageId,
    required this.artisanId,
    required this.imageUrl,
  });

  factory ArtisanImage.fromJson(Map<String, dynamic> json) {
    return ArtisanImage(
      artisanImageId: json['artisanImageid'] ?? 0,
      artisanId: json['artisanid'] ?? 0,
      imageUrl: json['imageurl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artisanImageid': artisanImageId,
      'artisanid': artisanId,
      'imageurl': imageUrl,
    };
  }
}