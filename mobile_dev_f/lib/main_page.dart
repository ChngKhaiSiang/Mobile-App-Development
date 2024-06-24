import 'package:flutter/material.dart';
import 'contact_card.dart';
import 'login_page.dart';
import 'relationship_model.dart';
import 'user_model.dart';
import 'profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_contact.dart';
import 'edit_contact.dart';
import 'database_helper.dart';
import 'nfc.dart';
import 'user_info_card.dart';
import 'user_info_model.dart';
import 'user_info_page.dart';

class MainPage extends StatefulWidget {
  final String id;

  const MainPage({super.key, required this.id});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isDarkTheme = false;
  List<user_model> contactList = [];
  List<user_info_model> nfcList = []; // List for NFC-added friends
  user_model? user;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadContact();
    loadNfcFriends(widget.id); // Load NFC-added friends
  }

  Future<void> loadContact() async {
    List<user_model> contactList = await DatabaseHelper.instance.getUsers(widget.id);
    setState(() {
      this.contactList = contactList;
    });
  }

  Future<void> loadNfcFriends(String accountId) async {
    List<user_info_model> nfcList = await DatabaseHelper.instance.getAllUserInfo(accountId);
    setState(() {
      this.nfcList = nfcList;
    });
  }

  Future<void> loadUser() async {
    user_model? checkUser = await DatabaseHelper.instance.getUser(widget.id);
    setState(() {
      user = checkUser;
      if (user!.theme == '0') {
        isDarkTheme = false;
      } else {
        isDarkTheme = true;
      }
    });
  }

  phoneUser(String contactNo) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: contactNo,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('cannot launch this url');
    }
  }

  emailUser(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('cannot launch this url');
    }
  }

  editUser(relationship_model relationship) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: EditContactPopup(funcLoadContact: loadContact, relationship: relationship,),
          ),
        );
      },
    );
  }

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });

    String themeValue = isDarkTheme ? '1' : '0';
    DatabaseHelper.instance.updateUserTheme(user!.id, themeValue);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF203F81),
          title: Text(user!.name, style: TextStyle(color: Colors.white),),
          actions: [
            Theme(
              data: ThemeData(
                iconTheme: IconThemeData(color: Colors.white), // Setting the icon color to white
              ),
              child: PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(id: widget.id),),
                    );
                  } else if (value == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Profile'),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Theme'),
                            Switch(
                              value: isDarkTheme,
                              onChanged: (bool value) {
                                setState(() {});
                                _toggleTheme();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Log Out'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Text('Code Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...contactList.map((t) => Column(
              children: [
                FutureBuilder<String?>(
                  future: DatabaseHelper.instance.getNickname(widget.id, t.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return contact_card(
                        contact: t,
                        id1: widget.id,
                        nickname: snapshot.data ?? '',
                        phone: phoneUser,
                        mail: emailUser,
                        edit: editUser,
                      );
                    }
                  },
                ),
              ],
            )).toList(),
            const SizedBox(height: 20.0), // Add some spacing between the lists
            Text('NFC Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...nfcList.map((userInfo) => UserInfoCard(userInfo: userInfo)).toList(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: const Color(0xFF203F81),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: AddContactPopup(funcLoadContact: loadContact, id: widget.id,),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              backgroundColor: const Color(0xFF203F81),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NfcPage(id: widget.id, onFriendAdded: () => loadNfcFriends(widget.id))), // Navigate to NFC operations page with callback
                );
              },
              child: const Icon(Icons.nfc, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
