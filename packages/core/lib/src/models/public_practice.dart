/// Public practice data for patient-facing views.
class PublicPractice {
  /// Practice identifier.
  final String id;

  /// Practice display name.
  final String name;

  /// Full address string.
  final String address;

  /// Contact phone number.
  final String phone;

  /// Contact email address.
  final String email;

  /// Optional practice website URL.
  final String? website;

  /// Opening hours string (raw backend format).
  final String? openingHours;

  /// Average wait time for the practice in minutes.
  final int averageWaitTimeMinutes;

  const PublicPractice({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.openingHours,
    required this.averageWaitTimeMinutes,
  });

  /// Create a PublicPractice from API JSON.
  factory PublicPractice.fromJson(Map<String, dynamic> json) {
    return PublicPractice(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String?,
      openingHours: json['opening_hours'] as String?,
      averageWaitTimeMinutes: json['average_wait_time_minutes'] as int,
    );
  }
}
