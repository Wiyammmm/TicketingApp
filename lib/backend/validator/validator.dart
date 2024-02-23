class ServiceValidator {
  Future<bool?> isDispatchValid(String vehicleNo, String bound, String route,
      bool isDriverLogin, bool isDispatcherLogin, bool isConductorLogin) async {
    if (vehicleNo != '' &&
        bound != '' &&
        route != '' &&
        isDriverLogin != false &&
        isDispatcherLogin != false &&
        isConductorLogin != false) {
      return true;
    } else {
      return false;
    }
  }
}
