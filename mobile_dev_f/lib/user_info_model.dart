//lib/user_info_model.dart
class user_info_model {
  final String id;
  final String username;
  final String phone;
  final String contact;
  final String instagram;
  final String wechat;
  final String facebook;
  final String accountId;

  user_info_model({
    required this.id,
    required this.username,
    required this.phone,
    required this.contact,
    required this.instagram,
    required this.wechat,
    required this.facebook,
    required this.accountId,
  });

  // Convert a user_info_model into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'contact': contact,
      'instagram': instagram,
      'wechat': wechat,
      'facebook': facebook,
      'accountId':accountId,
    };
  }

  // Extract a user_info_model from a Map
  factory user_info_model.fromMap(Map<String, dynamic> map) {
    return user_info_model(
      id: map['id'],
      username: map['username'] ?? '',
      phone: map['phone'] ?? '',
      contact: map['contact'] ?? '',
      instagram: map['instagram'] ?? '',
      wechat: map['wechat'] ?? '',
      facebook: map['facebook'] ?? '',
      accountId: map['accountId'] ?? '',
    );
  }
}
