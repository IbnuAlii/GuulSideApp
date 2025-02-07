class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? imageUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          location == other.location &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      location.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone, location: $location, imageUrl: $imageUrl}';
  }
}
