import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    String? name,
    String? email,
    String? uid,
    String? status,
    String? profileUrl,
    String? role,
    String? phone,
    String? city,
    String? bio,
  }) : super(
          name: name,
          email: email,
          uid: uid,
          status: status,
          profileUrl: profileUrl,
          role: role,
          phone: phone,
          city: city,
          bio: bio,
        );

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    var snapshotMap = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      name: snapshotMap['name'],
      profileUrl: snapshotMap['profileUrl'],
      status: snapshotMap['status'],
      uid: snapshotMap['uid'],
      email: snapshotMap['email'],
      role: snapshotMap['role'] ?? 'adopter',
      phone: snapshotMap['phone'],
      city: snapshotMap['city'],
      bio: snapshotMap['bio'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "name": name,
      "email": email,
      "uid": uid,
      "status": status,
      "profileUrl": profileUrl,
      "role": role ?? 'adopter',
      "phone": phone ?? "",
      "city": city ?? "",
      "bio": bio ?? "",
    };
  }
}
