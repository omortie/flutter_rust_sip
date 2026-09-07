import 'src/sip_api_interface.dart';
import 'src/sip_api_native.dart'
    if (dart.library.js_interop) 'src/sip_api_web.dart'
    as platform;

export 'src/sip_api_interface.dart';

final SipApi sipApi = platform.createSipApi();
