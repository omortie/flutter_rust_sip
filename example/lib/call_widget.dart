import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/rust/core/dart_types.dart' as frs;
import 'package:flutter_rust_sip/sip_service.dart';
import 'package:flutter_rust_sip_example/call_status_card.dart';
import 'package:flutter_rust_sip_example/caller_widget.dart';

class CallWidget extends StatefulWidget {
  const CallWidget({
    required this.service,
    super.key,
  });

  final SIPService service;

  @override
  State<CallWidget> createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  Map<int, frs.CallInfo> activeCalls = {};
  late int accountID;

  @override
  void initState() {
    widget.service.callStateBroadcast.listen((state) {
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