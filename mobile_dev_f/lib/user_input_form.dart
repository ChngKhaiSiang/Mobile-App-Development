// lib/user_input_form.dart
import 'package:flutter/material.dart';

class UserInputForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  UserInputForm({required this.onSubmit});

  @override
  _UserInputFormState createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _data = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter NFC Details'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) => _data['username'] = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Gmail'),
                onSaved: (value) => _data['contact'] = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _data['phone'] = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instagram'),
                onSaved: (value) => _data['instagram'] = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'WeChat ID'),
                onSaved: (value) => _data['wechat'] = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Facebook'),
                onSaved: (value) => _data['facebook'] = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Back'),
        ),
        TextButton(
          onPressed: () {
            _formKey.currentState?.save();
            widget.onSubmit(_data);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
