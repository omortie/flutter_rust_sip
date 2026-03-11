import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

void main(List<String> args) async {
  final envVars = <String, String>{
    "PKG_CONFIG_SYSROOT_DIR_x86_64_linux_android":
        "/home/mortie/Android/Sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/sysroot",
  };
  
  await build(args, (input, output) async {
    await RustBuilder(
      assetName: 'rust/frb_generated.io.dart',
      cratePath: 'rust',
      extraCargoEnvironmentVariables: envVars,
      enableDefaultFeatures: true,
    ).run(
      input: input,
      output: output,
    );
  });
}