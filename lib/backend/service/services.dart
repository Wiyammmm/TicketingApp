import 'package:intl/intl.dart';

class timeServices {
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  Future<String> dateofTrip() async {
    DateTime datenow = DateTime.now();

    final dateofTrip = DateFormat('MM/dd/yyyy');
    return dateofTrip.format(datenow);
  }

  Future<String> departedTime() async {
    DateTime datenow = DateTime.now();
    final departedTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');

    return departedTime.format(datenow);
  }

  Future<String> departureTimestamp() async {
    DateTime datenow = DateTime.now();
    final departueTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss');
    return departueTimestamp.format(datenow);
  }

  // fast return
  String dateofTrip2() {
    DateTime datenow = DateTime.now();

    final dateofTrip = DateFormat('MM/dd/yyyy');
    return dateofTrip.format(datenow);
  }

  String departedTime2() {
    DateTime datenow = DateTime.now();
    final departedTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');

    return departedTime.format(datenow);
  }

  String departureTimestamp2() {
    DateTime datenow = DateTime.now();
    final departueTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss');
    return departueTimestamp.format(datenow);
  }
}
