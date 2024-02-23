import 'dart:math';

import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:hive/hive.dart';

class GeneratorServices {
  final _myBox = Hive.box('myBox');
  fetchServices fetchservices = fetchServices();
  String generateTorNo() {
    Random random = Random();
    int randomFourDigitNumber = random.nextInt(9000) + 1000;

    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    String millisecondsString = millisecondsSinceEpoch.toString();
    String lastThreeDigits =
        millisecondsString.substring(millisecondsString.length - 3);
    String year = DateTime.now()
        .year
        .toString()
        .substring(2); // Last two digits of the year
    String month =
        DateTime.now().month.toString().padLeft(2, '0'); // Zero-padded month
    String day =
        DateTime.now().day.toString().padLeft(2, '0'); // Zero-padded day
    String hour =
        DateTime.now().hour.toString().padLeft(2, '0'); // Zero-padded hour
    String minute =
        DateTime.now().minute.toString().padLeft(2, '0'); // Zero-padded minute
    String second =
        DateTime.now().second.toString().padLeft(3, '0'); // Zero-padded second

    return '$year$month$day-$hour$minute';
  }

  Future<String> generateTicketNo() async {
    // final now = DateTime.now();
    // final lastDigitOfYear = now.year % 10;
    // final lastDigitOfMonth = now.month % 10;
    // final lastDigitOfDay = now.day % 10;

    // final timestamp = now.millisecondsSinceEpoch;
    // final random = Random().nextInt(10000); // Generates a random 4-digit number

    // final uniqueIdentifier =
    //     '$lastDigitOfYear$lastDigitOfMonth$lastDigitOfDay$timestamp$random';
    final ticketList = _myBox.get('torTicket');
    final torTrip = _myBox.get('torTrip');
    final session = _myBox.get('SESSION');

    String control_no = torTrip[session['currentTripIndex']]['control_no'];
    DateTime now = DateTime.now();
    String formattedMonth = now.month.toString().padLeft(2, '0');
    String formattedDay = now.day.toString().padLeft(2, '0');
    String formattedYear = now.year
        .toString()
        .substring(2)
        .padLeft(2, '0'); // Extract last two digits and pad to 2 digits
    int hours = now.hour;
    int minutes = now.minute;
    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String currentDate =
        "$formattedMonth$formattedDay$formattedYear$formattedHours$formattedMinutes";
    // Get the bus number (1299 in this case, you can replace it with the actual bus number logic)
    String busNumber = torTrip[session['currentTripIndex']]['bus_no'];

    // Get the count of entries in the list where fare > 0
    int fareGreaterThanZeroCount = ticketList
        .where((ticket) => ticket['control_no'] == "$control_no")
        .length;
    print('fareGreaterThanZeroCount: $fareGreaterThanZeroCount');

    // Format the count with leading zeros to get the desired length
    String formattedCount =
        (fareGreaterThanZeroCount + 1).toString().padLeft(4, '0');

    // Combine all parts to generate the ticket number
    String ticketNumber = "$currentDate-$busNumber-$formattedCount";

    return ticketNumber;
    // return uniqueIdentifier;
  }

  Future<String> generateControlNo() async {
    // Get current timestamp
    String timestamp = DateTime.now().microsecondsSinceEpoch.toString();

    // Generate a random number
    String random = Random().nextInt(999999).toString().padLeft(6, '0');

    // Combine factors to create a unique identifier
    String uniqueId = timestamp + random;

    return uniqueId;
  }

  String generateUuid() {
    final String hexDigits = '0123456789abcdefghijklmnopqrstuvwxyz';
    Random random = Random.secure();

    String s(int length) {
      return Iterable<int>.generate(length)
          .map((_) => random.nextInt(16))
          .map((n) => hexDigits[n])
          .join('');
    }

    return '${s(8)}-${s(4)}-4${s(3)}-a${s(3)}-${s(12)}';
  }

  String referenceNumber() {
    final String hexDigits = '0123456789abcdefghijklmnopqrstuvwxyz';
    Random random = Random.secure();

    String s(int length) {
      return Iterable<int>.generate(length)
          .map((_) => random.nextInt(16))
          .map((n) => hexDigits[n])
          .join('');
    }

    return '${s(4)}-${s(3)}-4${s(3)}-a${s(3)}-${s(3)}';
  }
}
