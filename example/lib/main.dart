import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';


import 'package:flutter_rust_sip/sip_service.dart';
import 'package:flutter_rust_sip_example/call_status_card.dart';

void main() async {
  runApp(const MyApp());
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
          body: Center(
            child: TabBarView(
              children: [
                FutureBuilder(
                    future: SIPService.init(
                        incomingCallStrategy: OnIncommingCall.autoAnswer),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final service = snapshot.data!;
                        return SIPWidget(service: service);
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator());
                      }
                    }),
                const Text("Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SIPWidget extends StatefulWidget {
  const SIPWidget({
    required this.service,
    super.key,
  });

  final SIPService service;

  @override
  State<SIPWidget> createState() => _SIPWidgetState();
}

class _SIPWidgetState extends State<SIPWidget> {
  Map<int, CallInfo> activeCalls = {};

  @override
  void initState() {
    widget.service.stateBroadcast.listen((state) {
      if (!widget.service.initialized) return;
      setState(() {
        activeCalls = widget.service.callIds;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    Future.microtask(() async => await widget.service.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CallerWidget(
          service: widget.service,
        ),
        Wrap(
          children: activeCalls.entries
              .map((e) => CallStatusCard(
                    callInfo: e.value,
                    service: widget.service,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

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
  String? error;
  String phoneNumber = '';
  String domain = "127.0.0.1";

  @override
  Widget build(BuildContext context) {
    return Column(
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
            widget.service.call(phoneNumber, domain);
          },
          child: Text('Call $phoneNumber'),
        ),
      ],
    );
  }
}
