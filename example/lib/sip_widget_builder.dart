import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip_example/call_widget.dart';
import 'package:flutter_rust_sip_example/di.dart';

class SIPWidgetBuilder extends ConsumerWidget {
  const SIPWidgetBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(sipServiceProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: service.when(data: (service) {
              return Column(
                children: [
                  const Text('SIP Service Initialized'),
                  if (service.registered)
                    SIPServiceWidget(service: service)
                  else
                    const Text('SIP Service not registered yet'),
                ],
              );
          }, error: (error, _) {
            return Text('Error initializing SIP Service: $error');
            },
            loading: () =>
                const CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
