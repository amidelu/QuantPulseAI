import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/bridge/device_telemetry.pigeon.dart',
    swiftOut: '../../../apps/quant_pulse_mobile/macos/Runner/DeviceTelemetry.pigeon.swift',
    kotlinOut:
    '../../../apps/quant_pulse_mobile/android/app/src/main/kotlin/com/quantpulse/app/DeviceTelemetry.pigeon.kt',
  ),
)
enum NativeThermalState { nominal, fair, serious, critical }

class DeviceHealthSnapshot {
  new({
    required this.thermalState,
    required this.availableMemoryMb,
    required this.isLowPowerMode,
  });

  final NativeThermalState thermalState;
  final int availableMemoryMb;
  final bool isLowPowerMode;
}

@HostApi()
abstract class DeviceTelemetryHostApi {
  @async
  DeviceHealthSnapshot getDeviceHealth();
}
