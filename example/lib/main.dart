import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart' as frs;
import 'package:flutter_rust_sip_example/sip_widget_builder.dart';

void main() async {
  await frs.RustLib.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('flutter_rust_sip example'),
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.call), text: "SIP Calls"),
              Tab(icon: Icon(Icons.settings), text: "Settings"),
            ]),
          ),
          body: const Center(
            child: TabBarView(
              children: [
                SIPWidgetBuilder(),
                Text("Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

