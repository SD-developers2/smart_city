class Complaint {
  final String id;
  final String title;
  final String category;
  final String address;
  final String description;
  final String status;
  final DateTime createdAt;

  // Murojaatning xaritadagi koordinatalari
  final double? latitude;
  final double? longitude;

  const Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.address,
    required this.description,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });
}