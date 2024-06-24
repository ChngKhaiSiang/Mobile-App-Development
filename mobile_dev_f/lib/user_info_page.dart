// lib/user_info_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_dev_f/database_helper.dart';
import 'package:mobile_dev_f/user_info_model.dart';
import 'package:uuid/uuid.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onFriendAdded;
  final String id;

  UserInfoPage(
      {required this.userData, required this.id, required this.onFriendAdded});

  @override
  Widget build(BuildContext context) {
    // Define the fields to be shown
    final fieldsToShow = [
      'username',
      'contact',
      'phone',
      'instagram',
      'wechat',
      'facebook'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF203F81),
        title: const Text(
            'User Information', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...userData.entries
                  .where((entry) => fieldsToShow.contains(entry.key))
                  .map((entry) =>
                  _buildInfoCard(entry.key, entry.value.toString()))
                  .toList(),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addFriend(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF203F81),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 53, vertical: 20),
                    elevation: 30, // Add shadow
                  ),
                  child: Text('Add Friend'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    IconData? iconData;

    switch (label.toLowerCase()) {
      case 'username':
        iconData = Icons.person;
        break;
      case 'contact':
        iconData = Icons.email;
        break;
      case 'phone':
        iconData = Icons.phone;
        break;
      case 'instagram':
        iconData = Icons.camera_alt;
        break;
      case 'wechat':
        iconData = Icons.wechat;
        break;
      case 'facebook':
        iconData = Icons.facebook;
        break;
      default:
        iconData = null;
    }


    if (iconData == null) {
      return Container();
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade300,
              Colors.blue.shade100
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(iconData, size: 40.0, color: Colors.white),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addFriend(BuildContext context) async {
    try {
      // Check if 'id' key exists in userData and if its value is not null
      if (userData.containsKey('id') && userData['id'] != null) {
        final accountId = id;
        final username = userData['username'] ?? '';
        final contact = userData['contact'] ?? '';
        final phone = userData['phone'] ?? '';
        final instagram = userData['instagram'] ?? '';
        final wechat = userData['wechat'] ?? '';
        final facebook = userData['facebook'] ?? '';
        final uuid = Uuid();
        final generatedId = uuid.v4();

        // Create a user_info_model instance
        final userInfo = user_info_model(
          id: generatedId,
          username: username,
          contact: contact,
          phone: phone,
          instagram: instagram,
          wechat: wechat,
          facebook: facebook,
          accountId: accountId,
        );

        // Print the information that will be saved
        print('Saving the following user info:');
        print('ID: $generatedId');
        print('Username: $username');
        print('Contact: $contact');
        print('Phone: $phone');
        print('Instagram: $instagram');
        print('WeChat: $wechat');
        print('Facebook: $facebook');
        print('AccountId: $accountId');


        final insertedUserInfo = await DatabaseHelper.instance.addUserInfo(
            userInfo);

        onFriendAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend added successfully!')),
        );

        Navigator.pop(context);
      } else {

        print('Error: The "id" value in userData is null.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add friend. Missing user ID.')),
        );
      }
    } catch (e) {

      if (e.toString() ==
          'Exception: A user with this phone number already exists.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed phone number already exists.')),
        );
      } else {
        // Handle other exceptions
        print('Error adding friend: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add friend. Please try again later.'),
          ),
        );
      }
    }
  }
}

