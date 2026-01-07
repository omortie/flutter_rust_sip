import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/sip_service.dart';

class CallerWidget extends StatefulWidget {
  final SIPService service;

  const CallerWidget({
    super.key,
    required this.service,
  });

  @override
  State<CallerWidget> createState() => _CallerWidgetState();
}

class _CallerWidgetState extends State<CallerWidget> {
  int? accountID;
  int registrationStatusCode = -1;
  String phoneNumber = '';
  String domain = "127.0.0.1";

  @override
  Widget build(BuildContext context) {
    widget.service.accountStream.listen((state) {
      setState(() {
        registrationStatusCode = state.statusCode;
      });
    });
    
    return Column(
      spacing: 16,
      children: [
        Text(
          'Initialization state: ${accountID != null ? "Initialized" : "Not initialized, error: ${widget.service.error}"}',
        ),
        Text(
            'Registration state: ${registrationStatusCode == 200 ? "Registered" : "Not registered (err code: $registrationStatusCode)"}'),
        TextField(
          decoration: const InputDecoration(hintText: 'Phone Number'),
          onChanged: (value) async {
            setState(() {
              phoneNumber = value;
            });
          },
        ),
        TextField(
          decoration: const InputDecoration(hintText: 'Domain'),
          onChanged: (value) async {
            setState(() {
              domain = value;
            });
          },
        ),
        Text('Action: Call `("$phoneNumber")`'),
        ElevatedButton(
          onPressed: () {
            widget.service.call(phoneNumber, domain);
          },
          child: Text('Call $phoneNumber'),
        ),
      ],
    );
  }
}
