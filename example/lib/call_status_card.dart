import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/sip_service.dart';

extension CallInfoExtension on CallState {
  bool get isActive {
    return maybeWhen(
      calling: () => true,
      connecting: () => true,
      confirmed: () => true,
      orElse: () => false,
    );
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
                    callInfo.state.isActive ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
