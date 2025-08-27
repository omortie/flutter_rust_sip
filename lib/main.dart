import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String name = '';
  int result = 1;
  final String domain = "127.0.0.1";

  @override
  void initState() {
    result = ffiAccountSetup(
        username: 'user1',
        uri: domain,
        password: 'user1',
      );
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
              Text(
                'Action: Call `("$name")`',
              ),
              ElevatedButton(
                onPressed:
                    name.isEmpty
                        ? null
                        : () async {
                  if (name.isNotEmpty) {
                            final res = await ffiMakeCall(
                              phoneNumber: name,
                              domain: domain,
                            );
                            setState(() {
                              result = res;
                            });
                  }
                },
                child: Text('Call $name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  await RustLib.init();
  runApp(MyApp());
}