class TimetableImage {
  final String id;
  final String imagePath;
  final DateTime uploadedAt;
  final String name;

  TimetableImage({
    required this.id,
    required this.imagePath,
    required this.uploadedAt,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'name': name,
    };
  }

  factory TimetableImage.fromJson(Map<String, dynamic> json) {
    return TimetableImage(
      id: json['id'],
      imagePath: json['imagePath'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      name: json['name'],
    );
  }
}
