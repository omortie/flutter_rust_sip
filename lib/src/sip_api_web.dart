import '../rust/core/dart_types.dart';
import '../rust/core/types.dart';
import 'sip_api_interface.dart';

SipApi createSipApi() => WebSipApi();

class WebSipApi implements SipApi {
  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}

  @override
  Future<int> initPjsua({
    required int localPort,
    required OnIncommingCall incomingCallStrategy,
    required String stunSrv,
  }) async => 0;

  @override
  Future<int> accountSetup({
    required String uri,
    required String username,
    required String password,
  }) async => 0;

  @override
  Stream<CallInfo> registerCallStream() => const Stream.empty();

  @override
  Stream<AccountInfo> registerAccountStream() => const Stream.empty();

  @override
  Future<void> markCallAlive({required int callId}) async {}

  @override
  Future<int> makeCall({required String phoneNumber, required String domain}) async => 0;

  @override
  Future<void> hangupCall({required int callId}) async {}

  @override
  Future<int> destroyPjsua() async => 0;
}
