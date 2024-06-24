import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'relationship_model.dart';

class AddContactPopup extends StatefulWidget {
  final String id;
  final Function() funcLoadContact;

  const AddContactPopup({
    super.key,
    required this.id,
    required this.funcLoadContact,
  });

  @override
  _AddContactPopupState createState() => _AddContactPopupState();
}

class _AddContactPopupState extends State<AddContactPopup> {
  final TextEditingController _idController = TextEditingController();
  String _errorMessage = '';
  String _buttonText = 'MY FRIEND CODE';

  Future<bool> _checkExistance(String cid) async {
    bool userExists = await DatabaseHelper.instance.checkUserExistance(cid);
    return userExists;
  }

  Future<bool> _checkDuplication(String id1,String id2)async {
    bool checkDuplicate = await DatabaseHelper.instance.checkDuplication(id1, id2);
    return checkDuplicate;
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
            'ENTER FRIEND CODE',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: 'Friend Code',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () async {
              bool exists = await _checkExistance(_idController.text);
              if (exists) {
                bool duplicate = await _checkDuplication(widget.id, _idController.text);
                if (duplicate){
                  setState(() {
                    _errorMessage = 'User is already in your friend list';
                  });
                } else {
                  relationship_model relationship = relationship_model(
                    id1: widget.id,
                    id2: _idController.text,
                    nickname: '',
                  );

                  DatabaseHelper.instance.addRelationship(relationship);
                  widget.funcLoadContact();
                  Navigator.of(context).pop();
                }
              } else {
                setState(() {
                  _errorMessage = 'No user found';
                });
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text('ADD FRIEND'),
          ),
          const SizedBox(height: 10.0),
          const Divider(),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.id));
              setState(() {
                _buttonText = 'COPIED';
              });
              },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              minimumSize: const Size.fromHeight(40),
            ),
            child: Text(_buttonText),
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
