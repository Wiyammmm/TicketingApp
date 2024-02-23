import 'package:flutter_test/flutter_test.dart';
import 'package:service/service.dart';
import 'package:service/service_platform_interface.dart';
import 'package:service/service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockServicePlatform
    with MockPlatformInterfaceMixin
    implements ServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ServicePlatform initialPlatform = ServicePlatform.instance;

  test('$MethodChannelService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelService>());
  });

  test('getPlatformVersion', () async {
    Service servicePlugin = Service();
    MockServicePlatform fakePlatform = MockServicePlatform();
    ServicePlatform.instance = fakePlatform;

    expect(await servicePlugin.getPlatformVersion(), '42');
  });
}
