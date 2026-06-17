import '../rust/core/dart_types.dart';
import '../rust/core/types.dart';

abstract interface class SipApi {
  Future<void> initialize();

  void dispose();

  Future<int> initPjsua({
    required int localPort,
    required OnIncommingCall incomingCallStrategy,
    required String stunSrv,
  });

  Future<int> accountSetup({
    required String uri,
    required String username,
    required String password,
  });

  Stream<CallInfo> registerCallStream();

  Stream<AccountInfo> registerAccountStream();

  Future<void> markCallAlive({required int callId});

  Future<int> makeCall({required String phoneNumber, required String domain});

  Future<void> hangupCall({required int callId});

  Future<int> destroyPjsua();
}
