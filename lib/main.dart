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
    final result = useState('');

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Column(
            children: [
              TextField(
                onChanged: (value) async {
                  name.value = value;
                  if (name.value.isNotEmpty) {
                    ffiAccountSetup(username: 'user1', uri: '127.0.0.1', password: 'user1');
                  }
                },
              ),
              Text(
                'Action: Call Rust `greet("${name.value}")`\nResult: `${result.value}`',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
