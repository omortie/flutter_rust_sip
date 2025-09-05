import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';

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
  final callStreamController = StreamController<CallInfo>();
  final Map<int, CallInfo> activeCalls = {};

  @override
  void initState() {
    callStreamController.stream.listen((event) {
      // Handle call state changes here
      debugPrint('Call State Changed: $event');
      setState(() {
        activeCalls[event.callId] = event;
      });
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
            children: [
              CallerWidget(
                callStreamController: callStreamController,
                callBack: (callID) {
                  setState(() {
                    activeCalls[callID] = CallInfo(
                      callId: callID,
                      state: const CallState.early(),
                    );
                  });
                },
              ),
              Wrap(
                children:
                    activeCalls.entries
                        .map((e) => CallStatusCard(callInfo: e.value))
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension CallInfoExtension on CallState {
  bool get isActive {
    return when(
      early: () => false,
      calling: () => true,
      connecting: () => true,
      confirmed: () => true,
      disconnected: () => false,
      error: (_) => false,
    );
  }
}

class CallStatusCard extends StatelessWidget {
  final CallInfo callInfo;
  final void Function(int)? onHangup;

  const CallStatusCard({super.key, required this.callInfo, this.onHangup});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: callInfo.state.isActive ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              callInfo.state.isActive ? Icons.phone_in_talk : Icons.phone,
              color: callInfo.state.isActive ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Call #${callInfo.callId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  callInfo.state.toString(),
                  style: TextStyle(
                    color:
                        callInfo.state.isActive ? Colors.green : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Hangup button
            ElevatedButton.icon(
              onPressed: callInfo.state.isActive
                  ? () async {
                      try {
                        await hangupCall(callId: callInfo.callId);
                        // notify parent to remove/update the call entry
                        if (onHangup != null) onHangup!(callInfo.callId);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hangup failed: $e')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.call_end),
              label: const Text('Hang Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    callInfo.state.isActive ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CallerWidget extends StatefulWidget {
  final StreamController<CallInfo> callStreamController;
  final Function(int) callBack;

  const CallerWidget({
    super.key,
    required this.callStreamController,
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
  void initState() {
    widget.callStreamController.addStream(
      initTelephony(
        uri: domain,
        localPort: 5060,
        transportMode: TransportMode.udp,
        incomingCallStrategy: OnIncommingCall.autoAnswer,
        stunSrv: "stun.l.google.com",
      ).handleError((e) {
        setState(() {
          error = e.toString();
        });
      }),
    );

    super.initState();
  }

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
            makeCall(phoneNumber: phoneNumber, domain: domain).then((callID) {
              widget.callBack(callID);
            });
          },
          child: Text('Call $phoneNumber'),
        ),
      ],
    );
  }
}
