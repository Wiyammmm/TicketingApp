import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'service_platform_interface.dart';

/// An implementation of [ServicePlatform] that uses method channels.
class MethodChannelService extends ServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('service');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
