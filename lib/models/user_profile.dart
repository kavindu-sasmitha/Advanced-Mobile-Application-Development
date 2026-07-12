import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String country;
  final String district;
  final DateTime birthday;
  final String gender; // "Male" or "Female"
  final String profilePicUrl;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.country,
    required this.district,
    required this.birthday,
    required this.gender,
    required this.profilePicUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'country': country,
      'district': district,
      'birthday': Timestamp.fromDate(birthday),
      'gender': gender,
      'profilePicUrl': profilePicUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      country: map['country'] ?? '',
      district: map['district'] ?? '',
      birthday: (map['birthday'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: map['gender'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
