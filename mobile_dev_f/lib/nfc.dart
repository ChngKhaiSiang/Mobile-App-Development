// lib/nfc.dart
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'user_input_form.dart';
import 'user_info_page.dart';
import 'package:uuid/uuid.dart';

class NfcPage extends StatefulWidget {
  final String id;
  final VoidCallback onFriendAdded;

  const NfcPage({Key? key, required this.id, required this.onFriendAdded}) : super(key: key);

  @override
  _NfcPageState createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  bool _isReadingPending = false;
  bool _isWritingPending = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF203F81),
        title: const Text(
            'NFC Add Friend', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startNFCReading(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isReadingPending ? Colors.grey : const Color(
                    0xFF203F81),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 80, vertical: 20),
                elevation: 30, // Add shadow
              ),
              child: Text(_isReadingPending ? 'Pending...' : 'Add Friend'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startNFCWriting(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isWritingPending ? Colors.grey : const Color(
                    0xFF203F81),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 53, vertical: 20),
                elevation: 30,
              ),
              child: Text(
                  _isWritingPending ? 'Pending...' : 'Writing Info To Card'),
            ),
            const SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }

  void _startNFCReading(BuildContext context) async {
    setState(() {
      _isReadingPending = true;
      _statusMessage = 'Starting NFC session...';
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            try {
              Ndef? ndef = Ndef.from(tag);
              if (ndef == null) {
                setState(() {
                  _statusMessage = 'Tag is not NDEF formatted.';
                });
                return;
              }

              NdefMessage? message = await ndef.read();

              if (message == null) {
                setState(() {
                  _statusMessage = 'Empty or null NDEF message.';
                });
                return;
              }

              // Assuming the payload is in the first record
              String payload = utf8.decode(message.records.first.payload);

              // Remove language code if present
              payload = payload.substring(3);

              // Parse JSON payload
              Map<String, dynamic> userData = jsonDecode(payload);

              // Navigate to UserInfoPage with the parsed data and callback
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserInfoPage(
                        userData: userData,
                        onFriendAdded: widget.onFriendAdded,
                        // Pass the callback
                        id: widget.id,
                      ),
                ),
              );

              setState(() {
                _statusMessage = 'User data parsed successfully.';
              });
            } catch (e) {
              setState(() {
                _statusMessage = 'Error reading NFC: $e';
              });
            } finally {
              NfcManager.instance.stopSession();
              setState(() {
                _isReadingPending = false;
              });
            }
          },
        );
      } else {
        setState(() {
          _statusMessage = 'NFC not available.';
          _isReadingPending = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting NFC session: $e';
        _isReadingPending = false;
      });
    }
  }


  void _startNFCWriting(BuildContext context) async {
    setState(() {
      _isWritingPending = true;
      _statusMessage = 'Starting NFC session...';
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UserInputForm(
              onSubmit: (data) async {
                // Generate a UUID for the ID
                String id = Uuid().v4();

                // Add the generated ID to the data
                data['id'] = id;

                NfcManager.instance.startSession(
                  onDiscovered: (NfcTag tag) async {
                    try {
                      Ndef? ndef = Ndef.from(tag);
                      if (ndef == null) {
                        setState(() {
                          _statusMessage = 'Tag is not NDEF formatted.';
                        });
                        return;
                      }

                      String payload = jsonEncode(data);
                      NdefMessage message = NdefMessage([
                        NdefRecord.createText(payload),
                      ]);

                      await ndef.write(message);

                      setState(() {
                        _statusMessage = 'NDEF message written successfully.';
                      });
                    } catch (e) {
                      setState(() {
                        _statusMessage = 'Error writing NFC: $e';
                      });
                    } finally {
                      NfcManager.instance.stopSession();
                      setState(() {
                        _isWritingPending = false;
                      });
                    }
                  },
                );
              },
            );
          },
        );
      } else {
        setState(() {
          _statusMessage = 'NFC not available.';
          _isWritingPending = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting NFC session: $e';
        _isWritingPending = false;
      });
    }
  }
}