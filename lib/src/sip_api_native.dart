import '../rust/api/simple.dart' as rust_api;
import '../rust/core/dart_types.dart';
import '../rust/core/types.dart';
import '../rust/frb_generated.dart' as bridge;
import 'sip_api_interface.dart';

SipApi createSipApi() => NativeSipApi();

class NativeSipApi implements SipApi {
  Future<void>? _initialization;

  @override
  Future<void> initialize() {
    if (bridge.RustLib.instance.initialized) {
      return Future.value();
    }

    return _initialization ??= bridge.RustLib.init();
  }

  @override
  void dispose() {
    if (bridge.RustLib.instance.initialized) {
      bridge.RustLib.dispose();
      _initialization = null;
    }
  }

  @override
  Future<int> initPjsua({
    required int localPort,
    required OnIncommingCall incomingCallStrategy,
    required String stunSrv,
  }) async {
    await initialize();
    return rust_api.initPjsua(
      localPort: localPort,
      incomingCallStrategy: incomingCallStrategy,
      stunSrv: stunSrv,
    );
  }

  @override
  Future<int> accountSetup({
    required String uri,
    required String username,
    required String password,
  }) async {
    await initialize();
    return rust_api.accountSetup(
      uri: uri,
      username: username,
      password: password,
    );
  }

  @override
  Stream<CallInfo> registerCallStream() async* {
    await initialize();
    yield* rust_api.registerCallStream();
  }

  @override
  Stream<AccountInfo> registerAccountStream() async* {
    await initialize();
    yield* rust_api.registerAccountStream();
  }

  @override
  Future<void> markCallAlive({required int callId}) async {
    await initialize();
    await rust_api.markCallAlive(callId: callId);
  }

  @override
  Future<int> makeCall({
    required String phoneNumber,
    required String domain,
  }) async {
    await initialize();
    return rust_api.makeCall(phoneNumber: phoneNumber, domain: domain);
  }

  @override
  Future<void> hangupCall({required int callId}) async {
    await initialize();
    await rust_api.hangupCall(callId: callId);
  }

  @override
  Future<int> destroyPjsua() async {
    await initialize();
    return rust_api.destroyPjsua();
  }
}
