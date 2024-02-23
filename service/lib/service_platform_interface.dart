import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'service_method_channel.dart';

abstract class ServicePlatform extends PlatformInterface {
  /// Constructs a ServicePlatform.
  ServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static ServicePlatform _instance = MethodChannelService();

  /// The default instance of [ServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelService].
  static ServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ServicePlatform] when
  /// they register themselves.
  static set instance(ServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
