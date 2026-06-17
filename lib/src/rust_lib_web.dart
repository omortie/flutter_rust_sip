import '../rust/frb_generated.dart' show RustLibApi;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show BaseHandler, ExternalLibrary;

abstract final class RustLib {
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
    bool forceSameCodegenVersion = true,
  }) async {}

  static void initMock({required RustLibApi api}) {}

  static void dispose() {}
}
