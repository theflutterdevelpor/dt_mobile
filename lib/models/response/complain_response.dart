class Complaint {
  final String id;
  final String title;
  final String name;
  final String status;
  final DateTime createdAt;

  final String? contact;
  final String? email;
  final String? description;
  final String? priority;
  final String? organization;
  final String? building;
  final String? floor;
  final String? space;
  final String? compliantId;
  final List<String>? images;
  final DateTime? updatedAt;

  Complaint({
    required this.id,
    required this.title,
    required this.name,
    required this.status,
    required this.createdAt,

    this.contact,
    this.email,
    this.description,
    this.priority,
    this.organization,
    this.building,
    this.floor,
    this.space,
    this.compliantId,
    this.images,
    this.updatedAt,
  });

  Complaint copyWith({String? status}) {
    return Complaint(
      id: this.id,
      title: this.title,
      name: this.name,
      createdAt: this.createdAt,
      status: status ?? this.status,

      contact: contact,
      email: email,
      description: description,
      priority: priority,
      organization: organization,
      building: building,
      floor: floor,
      space: space,
      compliantId: compliantId,
      images: images,
      updatedAt: updatedAt,
    );
  }



  factory Complaint.fromJson(Map<String, dynamic> json) {
    List<String>? imageUrls;
    if (json['images'] != null) {
      imageUrls = (json['images'] as List)
          .map((img) {
        if (img is Map<String, dynamic> && img['url'] != null) {
          return img['url'].toString();
        } else if (img is String) {
          return img;
        }
        return null;
      })
          .where((url) => url != null)
          .cast<String>()
          .toList();
    }
    return Complaint(
      id: json['_id']?.toString()??'',
      title: json['title']?.toString()?? '',
      name: json['name']?.toString() ?? '',
      status: json['status'] ?.toString()?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),

      contact: json['contact']?.toString(),
      email: json['email']?.toString(),
      description: json['description']?.toString(),
      priority: json['priority']?.toString(),
      organization: json['organization']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      space: json['space']?.toString(),
      compliantId: json['compliantId']?.toString(),
      images: imageUrls,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }
}
