import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/rust/core/dart_types.dart' as frs;
import 'package:flutter_rust_sip/sip_service.dart';
import 'package:flutter_rust_sip_example/call_status_card.dart';
import 'package:flutter_rust_sip_example/caller_widget.dart';

class SIPServiceWidget extends StatefulWidget {
  const SIPServiceWidget({
    required this.service,
    super.key,
  });

  final SIPService service;

  @override
  State<SIPServiceWidget> createState() => _SIPServiceWidgetState();
}

class _SIPServiceWidgetState extends State<SIPServiceWidget> {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CallerWidget(
          service: widget.service,
        ),
        Flexible(
          child: Wrap(
            children: activeCalls.entries
                .map((e) => CallStatusCard(
                      callInfo: e.value,
                      service: widget.service,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}