//lib/user_model.dart
import 'dart:typed_data';

class user_model{

  final String id;
  final String name;
  final String contact_no;
  final String email;
  final String password;
  final Uint8List? pic;
  final String theme;


  user_model({
    required this.id,
    required this.name,
    required this.contact_no,
    required this.email,
    required this.password,
    required this.pic,
    required this.theme,
  });

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'contact_no': contact_no,
      'email': email,
      'password' : password,
      'pic': pic,
      'theme' : theme,
    };
  }

  // Extract a UserModel from a Map
  factory user_model.fromMap(Map<String, dynamic> map) {
    return user_model(
      id: map['id'],
      name: map['name'],
      contact_no: map['contact_no'],
      email: map['email'],
      password: map['password'],
      pic: map['pic'],
      theme: map['theme'],
    );
  }
}