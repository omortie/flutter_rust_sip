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
  String name = '';
  int result = 1;
  final String domain = "127.0.0.1";
  final streamController = StreamController<CallState>();
  late Stream<ServiceState> telephonyStream;

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
      // Handle service state changes here
      debugPrint('Service State Changed: $event');

      if (event == ServiceState.initialized()) {
        // setup account
        accountSetup(
          username: 'user',
          password: 'pass',
          uri: '127.0.0.1',
          p2P: true,
        );
      }
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
                'Result: `$result` Initialization state: ${result == 0 ? "Initialized" : "Not initialized"}',
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Phone Number'),
                onChanged: (value) async {
                  setState(() {
                    name = value;
                  });
                },
              ),
              Text('Action: Call `("$name")`'),
              ElevatedButton(
                onPressed: () async {
                  makeCall(phoneNumber: name, domain: domain);
                }
                ,
                child: Text('Call $name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
