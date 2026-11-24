import 'package:flutter_rust_sip/rust/api/simple.dart' as sip;
import 'package:flutter_rust_sip/rust/core/types.dart';
import 'package:flutter_rust_sip/rust/frb_generated.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // Use the native asset hook and leave version/content-hash checks enabled.
    await RustLib.init();
  });

  tearDownAll(RustLib.dispose);

  test('initializes the namespaced native bridge', () {
    expect(RustLib.instance.initialized, isTrue);
    expect(RustLib.instance.nativeSymbolPrefix, 'flutter_rust_sip_');
    expect(RustLib.instance.codegenVersion, '2.14.0-beta.2');
  });

  test('serializes invalid gain errors through the native bridge', () async {
    await expectLater(
      sip.setMicrophoneGain(gain: -1),
      throwsA(
        const PJSUAError.inputValueError(
          'Microphone gain must be finite and between 0 and 4',
        ),
      ),
    );
  });

  test('serializes audio lifecycle errors through the native bridge', () async {
    await expectLater(
      sip.getMicrophoneGain(),
      throwsA(const PJSUAError.initializationError('PJSUA is not running')),
    );
    await expectLater(
      sip.getMicrophoneLevel(),
      throwsA(const PJSUAError.initializationError('PJSUA is not running')),
    );
  });
}
