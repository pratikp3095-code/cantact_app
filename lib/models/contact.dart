import 'dart:convert';

class Contact {
  final String id;
  String firstName;
  String lastName;
  String phoneNumber;
  String? email;
  String? company;
  String? jobTitle;
  String? address;
  String? notes;
  String? avatarPath;
  bool isFavorite;
  String? secondaryPhone;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.company,
    this.jobTitle,
    this.address,
    this.notes,
    this.avatarPath,
    this.isFavorite = false,
    this.secondaryPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'company': company,
      'jobTitle': jobTitle,
      'address': address,
      'notes': notes,
      'avatarPath': avatarPath,
      'isFavorite': isFavorite ? 1 : 0,
      'secondaryPhone': secondaryPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      company: map['company'],
      jobTitle: map['jobTitle'],
      address: map['address'],
      notes: map['notes'],
      avatarPath: map['avatarPath'],
      isFavorite: map['isFavorite'] == 1,
      secondaryPhone: map['secondaryPhone'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? company,
    String? jobTitle,
    String? address,
    String? notes,
    String? avatarPath,
    bool? isFavorite,
    String? secondaryPhone,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
      isFavorite: isFavorite ?? this.isFavorite,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
