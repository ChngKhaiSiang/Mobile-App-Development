// lib/user_info_card.dart
import 'package:flutter/material.dart';
import 'user_info_model.dart';

class UserInfoCard extends StatelessWidget {
  final user_info_model userInfo;

  const UserInfoCard({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Color(0xFF708ABB), width: 1),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${userInfo.username}'),
            Text('Phone: ${userInfo.phone}'),
            Text('Email: ${userInfo.contact}'),
            Text('Instagram: ${userInfo.instagram}'),
            Text('WeChat: ${userInfo.wechat}'),
            Text('Facebook: ${userInfo.facebook}'),

          ],
        ),
      ),
    );
  }
}