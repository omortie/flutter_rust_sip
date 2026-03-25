import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

import 'env_utilizer.dart' show Env;

const _pkgConfigSysrootx8664EnvVar =
    'PKG_CONFIG_SYSROOT_DIR_x86_64_linux_android';
const _pkgConfigSysrootAarch64EnvVar =
    'PKG_CONFIG_SYSROOT_DIR_aarch64_linux_android';
const _androidNDKHomeEnvVar = 'ANDROID_NDK_HOME';

void main(List<String> args) async {
    // we need to read an standard env file in a known-well path `$HOME/cross_build.env` to get the env vars for building, 
  //since the hook is filtering environment variables and there is a known issue about this: https://github.com/dart-lang/native/issues/2623
  final envFile = Env.instance;

  final ndkHome = envFile.getString(_androidNDKHomeEnvVar);
  final ndkPrebuiltRoot = '$ndkHome/toolchains/llvm/prebuilt/linux-x86_64';
  final pkgConfigSysrootDir = '$ndkPrebuiltRoot/sysroot';
  
  await build(args, (input, output) async {
    await RustBuilder(
      assetName: 'flutter_rust_sip',
      cratePath: 'rust',
      extraCargoEnvironmentVariables: {
        _pkgConfigSysrootx8664EnvVar: pkgConfigSysrootDir,
        _pkgConfigSysrootAarch64EnvVar: pkgConfigSysrootDir,
      },
    ).run(
      input: input,
      output: output,
    );
  });
}