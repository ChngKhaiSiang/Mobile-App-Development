import 'package:flutter/material.dart';
import 'relationship_model.dart';
import 'user_model.dart';

class contact_card extends StatelessWidget {
  final user_model contact;
  final String id1;
  final String nickname;
  final Function(String) phone;
  final Function(String) mail;
  final Function(relationship_model) edit;

  const contact_card({
    super.key,
    required this.contact,
    required this.id1,
    required this.nickname,
    required this.phone,
    required this.mail,
    required this.edit,
  });

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
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: contact.pic == null
                ? const AssetImage('assets/default_avatar.png')
                : MemoryImage(contact.pic!) as ImageProvider,
          ),
          title: Text(
            contact.name,
            style: TextStyle(
              color: Color(0xFFD197F3),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            nickname,
            style: const TextStyle(
              color: Color(0xFFF3BB97),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                color: const Color(0xFF6DCFC0),
                onPressed: () {
                  phone(contact.contact_no);
                },
              ),
              IconButton(
                icon: const Icon(Icons.email),
                color: const Color(0xFF6DCFC0),
                onPressed: () {
                  mail(contact.email);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: const Color(0xFF6DCFC0),
                onPressed: () {
                  edit(
                    relationship_model(
                      id1: id1,
                      id2: contact.id,
                      nickname: nickname,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
