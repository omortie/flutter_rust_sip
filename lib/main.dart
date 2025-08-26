import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_app/src/rust/api/simple.dart';
import 'package:my_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useState('');
    final result = useState(1);
    const domain = "127.0.0.1";

    useEffect(() {
      result.value = ffiAccountSetup(
        username: 'user1',
        uri: domain,
        password: 'user1',
      );
      return null;
    }, []);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Column(
            spacing: 16,
            children: [
              Text(
                'Initialization state: ${result.value == 0 ? "Initialized" : "Not initialized"}',
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Phone Number'),
                onChanged: (value) async {
                  name.value = value;
                },
              ),
              Text(
                'Action: Call Rust `greet("${name.value}")`\nResult: `${result.value}`',
              ),
              ElevatedButton(
                onPressed:
                    name.value.isEmpty
                        ? null
                        : () async {
                  if (name.value.isNotEmpty) {
                    ffiMakeCall(phoneNumber: name.value, domain: domain);
                  }
                },
                child: Text('Call ${name.value}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
