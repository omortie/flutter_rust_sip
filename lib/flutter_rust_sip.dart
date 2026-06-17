library;

import 'rust/core/dart_types.dart';
import 'rust/core/types.dart' show OnIncommingCall;
import 'sip_api.dart';

export 'rust/core/dart_types.dart';
export 'rust/core/types.dart' show OnIncommingCall;
export 'rust_lib.dart' show RustLib;
export 'sip_api.dart';

Future<void> initialize() => sipApi.initialize();

Future<int> init({
  int localPort = 5060,
  OnIncommingCall incomingCallStrategy = OnIncommingCall.autoAnswer,
  String stunSrv = "stun:stun.l.google.com:19302",
}) => sipApi.initPjsua(
  localPort: localPort,
  incomingCallStrategy: incomingCallStrategy,
  stunSrv: stunSrv,
);

Future<int> accountSetup({
  required String uri,
  required String username,
  required String password,
}) => sipApi.accountSetup(uri: uri, username: username, password: password);

Stream<CallInfo> registerCallStream() => sipApi.registerCallStream();

Stream<AccountInfo> registerAccountStream() => sipApi.registerAccountStream();

Future<void> markCallAlive({required int callId}) =>
    sipApi.markCallAlive(callId: callId);

Future<int> makeCall({required String phoneNumber, required String domain}) =>
    sipApi.makeCall(phoneNumber: phoneNumber, domain: domain);

Future<void> hangupCall({required int callId}) =>
    sipApi.hangupCall(callId: callId);

Future<int> destroyPjsua() => sipApi.destroyPjsua();
