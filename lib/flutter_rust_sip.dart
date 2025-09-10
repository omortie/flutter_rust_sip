library;

import 'rust/frb_generated.dart' as rlib_gen;
import 'rust/api/simple.dart' as rlib;
import 'rust/core/types.dart' show OnIncommingCall, TransportMode;

export 'rust/frb_generated.dart' show RustLib;
export 'rust/core/dart_types.dart' show CallInfo, CallState;
export 'rust/core/types.dart'
    show TransportMode, OnIncommingCall;

Future<void> init({
  int localPort = 5060,
  TransportMode transportMode = TransportMode.udp,
  OnIncommingCall incomingCallStrategy = OnIncommingCall.autoAnswer,
  String stunSrv = "stun.l.google.com:19302",
  String uri = "127.0.0.1",
}) async {
  await rlib_gen.RustLib.init();
  await rlib.initPjsua(
    localPort: localPort,
    transportMode: transportMode,
    incomingCallStrategy: incomingCallStrategy,
    stunSrv: stunSrv,
    uri: uri,
  );
}
