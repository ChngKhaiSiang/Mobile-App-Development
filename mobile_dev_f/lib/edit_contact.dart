// edit_contact.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'relationship_model.dart';

class EditContactPopup extends StatefulWidget {
  final relationship_model relationship;
  final Function() funcLoadContact;

  const EditContactPopup({
    Key? key,
    required this.relationship,
    required this.funcLoadContact,
  }) : super(key: key);

  @override
  _EditContactPopupState createState() => _EditContactPopupState();
}

class _EditContactPopupState extends State<EditContactPopup> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNickname();
  }

  void loadNickname() {
    _nicknameController.text = widget.relationship.nickname;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'EDIT',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: 'Nickname',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () async {
              relationship_model relationship = relationship_model(
                id1: widget.relationship.id1,
                id2: widget.relationship.id2,
                nickname: _nicknameController.text,
              );

              DatabaseHelper.instance.updateNickname(relationship);
              widget.funcLoadContact();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text('SET NICKNAME'),
          ),
          const SizedBox(height: 10.0),
          const Divider(),
          const SizedBox(height: 10.0),
          Dismissible(
            key: UniqueKey(), // Provide a unique key for each item
            direction: DismissDirection.endToStart, // Allow swiping from right to left
            background: Container(
              color: Color(0xFFE88181),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              // Show confirmation dialog
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Delete this contact?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false), // Cancel
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirm
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (DismissDirection direction) {
              // Perform deletion here if confirmed
              if (direction == DismissDirection.endToStart) {
                relationship_model relationship = relationship_model(
                  id1: widget.relationship.id1,
                  id2: widget.relationship.id2,
                  nickname: _nicknameController.text,
                );

                DatabaseHelper.instance.deleteRelationship(relationship);
                widget.funcLoadContact();
              }
            },
            child: ListTile(
              title: const Text('SLIDE LEFT TO DELETE'),
              tileColor: Colors.grey[200],
              leading: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10.0),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'CLOSE',
            ),
          ),
        ],
      ),
    );
  }
}
