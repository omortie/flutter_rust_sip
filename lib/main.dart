import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/src/rust/core/dart_types.dart';
import 'package:flutter_rust_sip/src/rust/core/types.dart';

void main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? error;
  String phoneNumber = '';
  String domain = "127.0.0.1";
  late Stream<SessionState> telephonyStream;
  final callStreamController = StreamController<CallState>();

  @override
  void initState() {
    final sid = createNewSession();
    telephonyStream = initTelephony(
        sessionId: sid,
        localPort: 5070,
        transportMode: TransportMode.udp,
      incomingCallStrategy: OnIncommingCall.autoAnswer,
    );

    telephonyStream.listen((event) {
      // Handle session state changes here
      debugPrint('Session State Changed: $event');

      switch (event) {
        case SessionState_Initialized _:
          // setup account
          accountSetup(
            username: 'user',
            password: 'pass',
            uri: domain,
          p2P: true,
            sessionId: sid,
        );
        case SessionState_Error state:
          error = state.field0;
          debugPrint('Session Error: $error');
          error = state.field0;
        case SessionState_Running _:
          debugPrint('Session is running');
        default:
          debugPrint('Unknown Session State: $event');
      }
    });

    callStreamController.stream.listen((event) {
      // Handle call state changes here
      debugPrint('Call State Changed: $event');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Column(
            spacing: 16,
            children: [
              Text(
                'Initialization state: ${error == null ? "Initialized" : "Not initialized, error: $error"}',
              ),
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
                  callStreamController.addStream(
                    makeCall(phoneNumber: phoneNumber, domain: domain),
                  );
                },
                child: Text('Call $phoneNumber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
