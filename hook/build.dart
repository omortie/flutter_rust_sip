import 'dart:io' show Platform, File;

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

const _pkgConfigSysrootx8664EnvVar =
    'PKG_CONFIG_SYSROOT_DIR_x86_64_linux_android';
const _pkgConfigSysrootAarch64EnvVar =
    'PKG_CONFIG_SYSROOT_DIR_aarch64_linux_android';
const _androidNDKHomeEnvVar = 'ANDROID_NDK_HOME';

class Env {
  Map<String, String> _env = {};

  static final Env instance = Env._();

  Env._() {
    // read cwd .env
    _env = Platform.environment.map((key, value) => MapEntry(key, value));
    // find $HOME/frtp_build.env file
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    final file = File('$home/cross_build.env');
    // coverage:ignore-start
    if (file.existsSync()) {
      final lines = file.readAsLinesSync();
      for (final line in lines) {
        int index = line.indexOf("=");
        if (index != -1) {
          _env[line.substring(0, index).trim()] = line
              .substring(index + 1)
              .trim();
        }
      }
    }
    // coverage:ignore-end
  }
  void set(String key, String value) {
    _env[key] = value;
  }

  void setDefault<T>(String key, T value) {
    _env.putIfAbsent(key, () => value.toString());
  }

  void setBool(String key, bool value) {
    set(key, value.toString());
  }

  String getString(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final found = _env[key];
    if (found == null) {
      return defaultValue;
    }
    return found.toLowerCase() == 'true';
  }
}

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