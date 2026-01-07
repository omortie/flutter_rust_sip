import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip/rust/core/types.dart' show OnIncommingCall;
import 'package:flutter_rust_sip/sip_service.dart';

final sipServiceProvider =
    FutureProvider<SIPService>((ref) {
  final service = SIPService.init(
      localPort: 5061, incomingCallStrategy: OnIncommingCall.autoAnswer);

  return service;
}, retry: (_, __) => null, isAutoDispose: false);

class SIPServiceRegistrationStatusNotifier extends AsyncNotifier<int> {
  StreamSubscription? _subscription;

  @override
  Future<int> build() async {
    final sipService = await ref.read(sipServiceProvider.future);
    _subscription = sipService.accountStream.listen(
      (accountInfo) => state = AsyncData(accountInfo.statusCode),
      onError: (error, stackTrace) => state = AsyncError(error, stackTrace),
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return -1;
  }
}

final sipServiceRegistrationProvider =
    AsyncNotifierProvider<SIPServiceRegistrationStatusNotifier, int>(
        SIPServiceRegistrationStatusNotifier.new);
