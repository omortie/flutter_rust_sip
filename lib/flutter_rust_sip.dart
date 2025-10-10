library;

import 'rust/api/simple.dart' as rlib;
import 'rust/core/types.dart' show OnIncommingCall;

export 'rust/frb_generated.dart' show RustLib;
export 'rust/core/dart_types.dart' show CallInfo, CallState;
export 'rust/core/types.dart'
    show OnIncommingCall;

Future<void> init({
  int localPort = 5060,
  OnIncommingCall incomingCallStrategy = OnIncommingCall.autoAnswer,
  String stunSrv = "stun:stun.l.google.com:19302",
  String uri = "127.0.0.1",
  String username = "",
  String password = "",
}) async {
  await rlib.initPjsua(
    localPort: localPort,
    incomingCallStrategy: incomingCallStrategy,
    stunSrv: stunSrv,
    uri: uri,
    username: username,
    password: password,
  );
}
