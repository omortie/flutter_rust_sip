import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip/rust/core/types.dart' show OnIncommingCall;
import 'package:flutter_rust_sip/sip_service.dart';

final sipServiceProvider =
    FutureProvider<SIPService>((ref) {
    return SIPService.init(localPort: 5061, incomingCallStrategy: OnIncommingCall.autoAnswer);
}, retry: (_, __) => const Duration(minutes: 5), isAutoDispose: false);
