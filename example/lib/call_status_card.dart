import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/rust/dart_types.dart';
import 'package:flutter_rust_sip/sip_service.dart';

extension CallInfoExtension on CallInfo {
  bool get isActive {
    return switch (state) {
      CallState_Calling _ => true,
      CallState_Connecting _ => true,
      CallState_Confirmed _ => true,
      _ => false,
    };
  }
}

class CallStatusCard extends StatelessWidget {
  final SIPService service;
  final CallInfo callInfo;
  final void Function(int)? onHangup;

  const CallStatusCard({super.key, required this.service, required this.callInfo, this.onHangup});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: callInfo.isActive ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              callInfo.isActive ? Icons.phone_in_talk : Icons.phone,
              color: callInfo.isActive ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Call #${callInfo.callId} (${callInfo.callUrl})',
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
                        callInfo.isActive ? Colors.green : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Hangup button
            ElevatedButton.icon(
              onPressed: callInfo.isActive
                  ? () async {
                      try {
                        service.hangup(callInfo.callId);
                        // notify parent to remove/update the call entry
                        if (onHangup != null) onHangup!(callInfo.callId);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Hangup failed: $e')),
                          );
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.call_end),
              label: const Text('Hang Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    callInfo.isActive ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
