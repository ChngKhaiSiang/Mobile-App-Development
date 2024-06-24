import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main_page.dart';
import 'user_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String id;

  const ProfilePage({super.key, required this.id});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkTheme = false;
  bool isEditing = false;
  late String _uid;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? profilePic;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic = File(pickedFile!.path).readAsBytesSync();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user_model? user = await DatabaseHelper.instance.getUser(widget.id);
    setState(() {
      _uid = user!.id;
      _usernameController.text = user.name;
      _emailController.text = user.email;
      _contactController.text = user.contact_no;
      _passwordController.text = user.password;
      profilePic = user.pic;
      if (user.theme == '0') {
        isDarkTheme = false;
      } else {
        isDarkTheme = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF203F81),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainPage(id: _uid)),
              );
            },
          ),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: profilePic == null
                      ? const AssetImage('assets/default_avatar.png')
                      : MemoryImage(profilePic!) as ImageProvider,
                ),
              ),
              Center(child: Text(_uid)),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact No',
                  prefixIcon: Icon(Icons.phone),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Save changes?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await DatabaseHelper.instance.updateUser(user_model(
                                  id: _uid,
                                  name: _usernameController.text,
                                  email: _emailController.text,
                                  contact_no: _contactController.text,
                                  password: _passwordController.text,
                                  pic: profilePic,
                                  theme: isDarkTheme ? '1' : '0',
                                ));
                                setState(() {
                                  isEditing = false;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text(isEditing ? 'Save' : 'Edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
