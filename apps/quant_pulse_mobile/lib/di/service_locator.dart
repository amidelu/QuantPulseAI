import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt sl = GetIt.instance;

enum AppEnvironment { dev, staging, prod }

/// Injectable 3.0.0 configuration.
/// As we add engine/feature @MicroPackageInit modules in Phases 2-4,
/// they are registered in `externalPackageModulesBefore`.
@InjectableInit(
  preferRelativeImports: true,
  externalPackageModulesBefore: [],
)

Future<void> configureDependencies({
  AppEnvironment env = .dev, // Dart 3.10+ dot-shorthand syntax
}) async {
  // GetIt 9.1+ DevTools extension support for inspecting DI graph in debug mode
  sl.debugEventsEnabled = kDebugMode;

  // Will invoke sl.init(environment: env.name) once generated
}
