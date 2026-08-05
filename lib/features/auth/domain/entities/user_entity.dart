import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? name;
  final String? email;
  final String? uid;
  final String? status;
  final String? profileUrl;
  final String? password;
  final String? role;
  final String? phone;
  final String? city;
  final String? bio;

  const UserEntity({
    this.name,
    this.email,
    this.uid,
    this.status,
    this.profileUrl,
    this.password,
    this.role,
    this.phone,
    this.city,
    this.bio,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        uid,
        status,
        profileUrl,
        password,
        role,
        phone,
        city,
        bio,
      ];
}
