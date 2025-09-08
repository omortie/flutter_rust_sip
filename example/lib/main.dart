import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart' as frs;
import 'package:flutter_rust_sip/sip_service.dart';
import 'package:flutter_rust_sip_example/call_status_card.dart';

void main() async {
  await frs.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: FutureBuilder(
              future: SIPService.init(uri: "127.0.0.1"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final service = snapshot.data!;
                  return SIPWidget(service: service);
                } else {
                  return Text(
                      'Error initializing SIPService: ${snapshot.error}');
                }
              }),
        ),
      ),
    );
  }
}

class SIPWidget extends StatefulWidget {
  const SIPWidget({
    super.key,
    required this.service,
  });

  final SIPService service;

  @override
  State<SIPWidget> createState() => _SIPWidgetState();
}

class _SIPWidgetState extends State<SIPWidget> {
  final Map<int, frs.CallInfo> activeCalls = {};

  @override
  void initState() {
    widget.service.stateBroadcast.listen((state) {
      setState(() {
        activeCalls[state.callId] = state;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CallerWidget(
          service: widget.service,
          callBack: (callID) {
            setState(() {
              activeCalls[callID] = frs.CallInfo(
                callId: callID,
                state: const frs.CallState.early(),
              );
            });
          },
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
  final Function(int) callBack;

  const CallerWidget({
    super.key,
    required this.service,
    required this.callBack,
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
            widget.service.call(phoneNumber, domain).then((callID) {
              widget.callBack(callID);
            });
          },
          child: Text('Call $phoneNumber'),
        ),
      ],
    );
  }
}
