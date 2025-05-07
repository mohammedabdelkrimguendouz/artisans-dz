
class Wilaya {
  final int wilayaId;
  final String name;

  Wilaya({
    required this.wilayaId,
    required this.name,
  });

  factory Wilaya.fromJson(Map<String, dynamic> map) {
    return Wilaya(
      wilayaId: map['wilayaid'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wilayaid': wilayaId,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Wilaya && runtimeType == other.runtimeType && wilayaId == other.wilayaId;

  @override
  int get hashCode => wilayaId.hashCode;
}
