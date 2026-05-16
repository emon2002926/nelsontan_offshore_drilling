
class WeeklySafetyFocusModel {
  final String id;
  final String title;
  final String description;
  final String sectionTitle;
  final String? detailsUrl;
  final String? imageUrl;
  final String? fullDetails;
  final DateTime? publishedAt;

  WeeklySafetyFocusModel({
    required this.id,
    required this.title,
    required this.description,
    this.detailsUrl,
    this.imageUrl,
    this.fullDetails,
    this.publishedAt, required this.sectionTitle,
  });

  factory WeeklySafetyFocusModel.fromJson(Map<String, dynamic> json) {
    return WeeklySafetyFocusModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      sectionTitle: json['sectionTitle'] ?? '',
      description: json['description'] ?? '',
      detailsUrl: json['details_url'],
      imageUrl: json['image_url'],
      fullDetails: json['full_details'],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sectionTitle': sectionTitle,
      'description': description,
      'details_url': detailsUrl,
      'image_url': imageUrl,
      'full_details': fullDetails,
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  static WeeklySafetyFocusModel dummy() {
    return WeeklySafetyFocusModel(
      id: '1',
      title: 'Proper Lifting Techniques',
      sectionTitle: 'sectionTitle Title',
      description: 'Protect your back. Lift with your legs.',
      detailsUrl: null,
      imageUrl: null,
      fullDetails: '''Keep your back straight at all times. Bend at your knees, not your waist. Lift smoothly using your leg muscles. Keep the load close to your body. Avoid twisting while lifting or carrying. Test the weight before lifting. Ask for help with heavy or awkward loads. Maintain a firm, secure grip. Set the load down slowly and carefully. Protect your back lift smart every time.''',
      publishedAt: DateTime.now(),
    );
  }
}