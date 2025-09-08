library;

import 'rust/frb_generated.dart' as rlib_gen;
import 'rust/api/simple.dart' as rlib;
import 'rust/core/types.dart' show OnIncommingCall, TransportMode;

export 'rust/api/simple.dart' show hangupCall;
export 'rust/frb_generated.dart' show RustLib;
export 'rust/core/dart_types.dart' show CallInfo, CallState;
export 'rust/core/types.dart'
    show TelephonyError, TransportMode, OnIncommingCall;

Future<void> init() async {
  await rlib_gen.RustLib.init();
  await rlib.initTelephony(
    localPort: 5061,
    transportMode: TransportMode.udp,
    incomingCallStrategy: OnIncommingCall.autoAnswer,
    stunSrv: "stun.l.google.com",
  );
}
