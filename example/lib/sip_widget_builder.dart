import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip_example/caller_widget.dart';
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
                  CallerWidget(service: service)
                else
                  const LoginWidget(),
              ],
            );
          }, error: (error, _) {
            return Text('Error initializing SIP Service: $error');
          }, loading: () {
            return Column(
              children: [
                if (service.hasError)
                  Text('Error initializing: ${service.error}, retrying...'),
                const CircularProgressIndicator(),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Please register to make calls.');
  }
}
