library;

import 'rust/frb_generated.dart' as rlib_gen;
import 'rust/api/simple.dart' as rlib;
import 'rust/core/types.dart' show OnIncommingCall, TransportMode;

export 'rust/frb_generated.dart' show RustLib;
export 'rust/core/dart_types.dart' show CallInfo, CallState;
export 'rust/core/types.dart'
    show TransportMode, OnIncommingCall;

Future<void> init({
  required int localPort,
  required TransportMode transportMode,
  required OnIncommingCall incomingCallStrategy,
  required String stunSrv,
  required String uri,
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
