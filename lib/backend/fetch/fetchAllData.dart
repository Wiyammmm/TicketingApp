import 'dart:io';

import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

class fetchServices {
  HttpClient client = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  final _myBox = Hive.box('myBox');
  httprequestService httprequestServices = httprequestService();
  // final routeList = [
  //   {
  //     '_id': '1',
  //     'origin': 'DISTRICT',
  //     'destination': 'STAR MALL',
  //     'bound': 'NORTH',
  //     'code': 'DISTAR',
  //   },
  //   {
  //     '_id': '2',
  //     'origin': 'LRT',
  //     'destination': 'LUCENA',
  //     'bound': 'SOUTH',
  //     'code': 'CLT',
  //   },
  // ];
  // final filipayCardList = [
  //   {
  //     '_id': '1',
  //     'cardID': '043514BAF36D80',
  //     'balance': 125,
  //     'cardType': 'regular'
  //   },
  //   {
  //     '_id': '2',
  //     'cardID': '045276C2F36D80',
  //     'balance': 100,
  //     'cardType': 'discounted'
  //   },
  // ];
  // final masterCardList = [
  //   {
  //     '_id': '1',
  //     'cardID': '2B3D4DD9',
  //     'balance': 10000,
  //     'cardType': 'mastercard'
  //   },
  //   // temporary
  //   {
  //     '_id': '1',
  //     'cardID': '1F0990CA',
  //     'balance': 10000,
  //     'cardType': 'mastercard'
  //   },
  // ];

  // final coopData = [
  //   {
  //     'coopName': 'DEL MONTE LAND TRANSPORT\nBUS COMPANY, INC. (LUCENA)',
  //     'pricePerKM': 15,
  //   }
  // ];

  // final vehicleList = [
  //   {
  //     '_id': '1',
  //     'vehicleNo': '100',
  //   },
  //   {
  //     '_id': '2',
  //     'vehicleNo': '101',
  //   },
  //   {
  //     '_id': '3',
  //     'vehicleNo': '102',
  //   },
  //   {
  //     '_id': '4',
  //     'vehicleNo': '103',
  //   },
  //   {
  //     '_id': '5',
  //     'vehicleNo': '104',
  //   }
  // ];

  // final cardList = [
  //   {'cardID': 'FC95D656', 'empNo': 8526},
  //   {'cardID': '8B8253D9', 'empNo': 7496},
  //   {'cardID': '5B674BD9', 'empNo': 7550},
  //   {'cardID': '04235CAA2F6F80', 'empNo': 7497},
  //   {'cardID': 'CB1A4CD9', 'empNo': 7325},
  //   {'cardID': '049450BAF36D80', 'empNo': 1427},
  //   // temporary
  //   {'cardID': 'DB5B43D9', 'empNo': 7550},
  //   {'cardID': '9BCA4CD9', 'empNo': 8526},
  //   {'cardID': '0582BCB4864200', 'empNo': 7496},
  //   {'cardID': '1F0920AF', 'empNo': 1427},
  // ];

  // final employeeList = [
  //   {
  //     "lastName": "BOLA",
  //     "firstName": "ANTHONY",
  //     "middleName": "BRITANICO",
  //     "nameSuffix": "",
  //     "empNo": 1427,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "ANTHONY B. BOLA ",
  //     "designation": "Temporary GPS Section Staff Cashier",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "Cashier",
  //     "JTI_RFID_RequestDate": ""
  //   },
  //   {
  //     "_id": "1",
  //     "lastName": "ABABAO",
  //     "firstName": "JOVY",
  //     "middleName": "FOLLERO",
  //     "nameSuffix": "",
  //     "empNo": 8526,
  //     "empStatus": "AWOL",
  //     "empType": "Probationary",
  //     "idName": "JOVY F. ABABAO",
  //     "designation": "Bus Driver",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/2FF5B370836975D1FBBB1568620176B46990F65973568B99085F0B6A2D1C260F.png?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/68DFF7E01D9FFD49BACC5F37F9F7E8B05EEE49B61C94B4C1019D659E25E2DB25.jpg?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "Bus Driver / Conductor",
  //     "JTI_RFID_RequestDate": "12/15/2022"
  //   },
  //   {
  //     "_id": "2",
  //     "lastName": "ABAN",
  //     "firstName": "CHRISTIAN GERALD",
  //     "middleName": "ADIO",
  //     "nameSuffix": "",
  //     "empNo": 7496,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "CHRISTIAN GERALD A. ABAN ",
  //     "designation": "Bus Conductor",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/E36D5ACEB471948EED2FA912347B002FB67B97BE78B6C746CE70894BE16CFFEA.jpg?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/4896AD46301B2365E7303FEAC2BECE1590D9E09B333CFF4E639FD2E614B66D19.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "TripKo Mastercard",
  //     "JTI_RFID_RequestDate": "03/11/2023"
  //   },
  //   {
  //     "_id": "3",
  //     "lastName": "ALABAN",
  //     "firstName": "RITCHEI",
  //     "middleName": "HAGONOS",
  //     "nameSuffix": "",
  //     "empNo": 7550,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "RITCHEI H. ALABAN ",
  //     "designation": "Dispatcher",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/C5B6DD000D7DE400D7C68FE128D7002B9F936FD514486D85460D7493E48F0878.jpg?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/86C369E6F13497C1A9990D3B41D01E52259E98DBE421F95207A2A62D1D1D510B.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "Dispatcher / Cashier",
  //     "JTI_RFID_RequestDate": "10/11/2021"
  //   },
  //   {
  //     "_id": "4",
  //     "lastName": "ABANTO",
  //     "firstName": "CRISTOPHER",
  //     "middleName": "LIZANO",
  //     "nameSuffix": "",
  //     "empNo": 7497,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "CRISTOPHER L. ABANTO ",
  //     "designation": "Bus Conductor",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/449FC907E5E1C9DAF900A40C085BB462B9750A2AB9846DD66545CEB4EFA5470C.jpg?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/99A8C701A413E53ADD0677BEAD7D5C5890A882CD945AF1C235BB86255F5FB9A4.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "TripKo Mastercard",
  //     "JTI_RFID_RequestDate": "03/11/2023"
  //   },
  //   {
  //     "lastName": "BOLA",
  //     "firstName": "ANTHONY",
  //     "middleName": "BRITANICO",
  //     "nameSuffix": "",
  //     "empNo": 1427,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "ANTHONY B. BOLA ",
  //     "designation": "Temporary GPS Section Staff Cashier",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "Cashier",
  //     "JTI_RFID_RequestDate": ""
  //   },
  //   {
  //     "lastName": "ACIBAR",
  //     "firstName": "DANIEL",
  //     "middleName": "M.",
  //     "nameSuffix": "",
  //     "empNo": 7325,
  //     "empStatus": "Active/Recalled",
  //     "empType": "Regular",
  //     "idName": "DANIEL M. ACIBAR ",
  //     "designation": "Inspector",
  //     "idPicture":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/E465AE96FC77D0FA19C8B5E7A7131244B62BA530D661FBF28C2D7C3DB02DE72A.jpg?RCType=EmbeddedRCFileProcessor",
  //     "idSignature":
  //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/7C1325D72DA98845A734BD8F0576136436A59152746E6C2E790AFC8E4DC44BAC.png?RCType=EmbeddedRCFileProcessor",
  //     "JTI_RFID": "YES",
  //     "accessPrivileges": "Inspector",
  //     "JTI_RFID_RequestDate": ""
  //   }
  // ];

// total fetcher

  double totalBaggageperTrip() {
    final torTicket = _myBox.get('torTicket');
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    String control_no = torTrip[session['currentTripIndex']]['control_no'];
    double sumOfBaggage = torTicket
        .where((fare) => fare['control_no'] == control_no)
        .map<double>((fare) => (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, baggage) => prev + baggage);

    return sumOfBaggage;
  }

// counter fetcher
  int baggageCount() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no)
          .length;
      return totalBaggageCount;
    } catch (e) {
      return 0;
    }
  }

  int cardSalesCount() {
    final torTicket = _myBox.get('torTicket');
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    String control_no = torTrip[session['currentTripIndex']]['control_no'];
    // int totalBaggageCount = torTicket
    //     .where((item) =>
    //         item['cardType'] != 'mastercard' &&
    //         item['control_no'] == control_no)
    //     .length;
    int sumOfPax = 0;
    try {
      sumOfPax = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              ticket['cardType'] != "mastercard" &&
              ticket['cardType'] != "cash")
          .fold(0, (sum, ticket) => sum + (ticket['pax'] ?? 1));
    } catch (e) {
      print("cardSalesCount: $e");
    }

    return sumOfPax;
  }

  int baggageOnlyCount() {
    final torTicket = _myBox.get('torTicket');
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    String control_no = torTrip[session['currentTripIndex']]['control_no'];
    int totalBaggageCount = torTicket
        .where((item) =>
            (item['baggage'] is num && item['baggage'] > 0) &&
            item['control_no'] == control_no &&
            (item['fare'] is num && item['fare'] == 0))
        .length;
    return totalBaggageCount;
  }

  int baggageWithPassengerCount() {
    final torTicket = _myBox.get('torTicket');
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    String control_no = torTrip[session['currentTripIndex']]['control_no'];
    int totalBaggageCount = torTicket
        .where((item) =>
            (item['baggage'] is num && item['baggage'] > 0) &&
            item['control_no'] == control_no &&
            (item['fare'] is num && item['fare'] > 0))
        .length;
    return totalBaggageCount;
  }

  int allBaggageCount() {
    final torTicket = _myBox.get('torTicket');

    try {
      int allBaggageCount = 0;
      allBaggageCount = torTicket
          .where((item) => (item['baggage'] is num && item['baggage'] > 0))
          .length;
      return allBaggageCount;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  int discountedCount() {
    final torTicket = _myBox.get('torTicket');

    int sumOfPax = 0;
    List<int> discountedPaxList = [];
    try {
      discountedPaxList = torTicket
          .where((passenger) => passenger['discount'] > 0)
          .map((passenger) => passenger['pax'] as int)
          .toList();

      sumOfPax = discountedPaxList.fold(0, (sum, pax) => sum + pax);
    } catch (e) {
      print(e);
      print("discountedPaxList: $discountedPaxList");
    }

    return sumOfPax;
  }

  int regularCount() {
    final torTicket = _myBox.get('torTicket');
    int sumOfPax = 0;
    try {
      sumOfPax = torTicket
          .where((ticket) => ticket['discount'] == 0)
          .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);
    } catch (e) {
      print("regularCount: $e");
    }

    // return torTicket.where((item) => (item['discount'] ?? 0) == 0).length;
    return sumOfPax;
  }

  double totalpassengerFareAmount() {
    final torTicket = _myBox.get('torTicket');
    double totalPassengerAmount = 0.0;

    for (Map<String, dynamic> item in torTicket) {
      if (item['fare'] is double) {
        totalPassengerAmount += (item['fare'] * item['pax']);
      }
    }

    return totalPassengerAmount;
  }

  double totalpassengerFareAmountTrip() {
    double totalPassengerAmount = 0.0;

    final torTicket = _myBox.get('torTicket');
    String control_no = getCurrentControlNumber();

    for (Map<String, dynamic> item in torTicket) {
      if (item['control_no'].toString() == control_no) {
        totalPassengerAmount +=
            (item['fare'] * item['pax']) + item['additionalFare'];
      }
    }

    return totalPassengerAmount;
  }

  String getCurrentControlNumber() {
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    String control_no = "";
    if (torTrip.isNotEmpty) {
      try {
        control_no = torTrip[session['currentTripIndex']]['control_no'];
      } catch (e) {
        control_no = torTrip[session['currentTripIndex'] - 1]['control_no'];
      }
    }

    return control_no;
  }

  double totalAddFare() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();

    double totalAmount = fareList
        .where((fare) => fare['control_no'] == controlNumberToFilter)
        .fold(
            0.0,
            (prev, fare) =>
                prev +
                (fare['additionalFare'] ?? 0.0) *
                    (fare['pax'] ?? 1).toDouble());

    return totalAmount;
  }

  double totalTripCashReceived() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();
    String cardTypeToFilter = 'mastercard';

    double totalAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            (fare['cardType'] == cardTypeToFilter ||
                fare['cardType'] == "cash"))
        .map<num>((fare) =>
            ((fare['fare'] as num).toDouble() * fare['pax']) +
            (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    double totaladdFareAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            (fare['additionalFareCardType'] == cardTypeToFilter ||
                fare['additionalFareCardType'] == "cash"))
        .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);
    return totalAmount + totaladdFareAmount;
  }

  double grandTotalCashReceived() {
    final fareList = _myBox.get('torTicket');
    String cardTypeToFilter = 'mastercard';
    double grantotal = 0;

    double totalAmount = fareList
        .where((fare) => (fare['cardType'] == cardTypeToFilter ||
            fare['cardType'] == "cash"))
        .map<num>((fare) => (fare['subtotal'] as num))
        .fold(0.0, (prev, amount) => prev + amount);

    double totaladdFareAmount = fareList
        .where((fare) => (fare['additionalFareCardType'] == cardTypeToFilter ||
            fare['additionalFareCardType'] == "cash"))
        .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);
    grantotal = totalAmount + totaladdFareAmount;
    return grantotal;
  }

  double totalTripGrandTotal() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();

    double totalAmount = fareList
        .where((fare) => fare['control_no'] == controlNumberToFilter)
        .map<num>((fare) =>
            ((fare['fare'] as num).toDouble() * fare['pax']) +
            (fare['baggage'] as num).toDouble() +
            (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  double totalTripCardSales() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();

    double totalAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            (fare['cardType'] != "mastercard" && fare['cardType'] != "cash"))
        .map<num>((fare) =>
            ((fare['fare'] as num).toDouble() * fare['pax']) +
            (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    double totaladdFareAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            fare['additionalFareCardType'] != "mastercard" &&
            fare['additionalFareCardType'] != "cash")
        .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);
    return totalAmount + totaladdFareAmount;
  }

  double grandTotalCardSales() {
    final fareList = _myBox.get('torTicket');
    double grandtotal = 0;

    double totalAmount = fareList
        .where((fare) =>
            (fare['cardType'] != "mastercard" && fare['cardType'] != "cash"))
        .map<num>((fare) =>
            ((fare['fare'] as num).toDouble() * fare['pax']) +
            (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    double totaladdFareAmount = fareList
        .where((fare) => (fare['additionalFareCardType'] != "mastercard"))
        .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);
    grandtotal = totalAmount + totaladdFareAmount;
    return grandtotal;
  }

  double totalTripFare() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();
    double totalAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter && fare['fare'] > 0)
        .map<num>((fare) =>
            ((fare['fare'] as num).toDouble() * fare['pax']) +
            (fare['additionalFare'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  double totalTripBaggageOnly() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();
    // String cardTypeToFilter = 'mastercard';

    double totalAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            // fare['cardType'] == cardTypeToFilter &&
            fare['baggage'] > 0 &&
            fare['fare'] == 0)
        .map<num>((fare) => (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  double totalTripBaggagewithPassenger() {
    final fareList = _myBox.get('torTicket');

    String controlNumberToFilter = getCurrentControlNumber();
    // String cardTypeToFilter = 'mastercard';

    double totalAmount = fareList
        .where((fare) =>
            fare['control_no'] == controlNumberToFilter &&
            // fare['cardType'] == cardTypeToFilter &&
            fare['baggage'] > 0 &&
            fare['fare'] > 0)
        .map<num>((fare) => (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  double totalBaggagewithPassenger() {
    final fareList = _myBox.get('torTicket');
    // String cardTypeToFilter = 'mastercard';

    double totalAmount = fareList
        .where((fare) =>
            // fare['cardType'] == cardTypeToFilter &&
            fare['baggage'] > 0 && fare['fare'] > 0)
        .map<num>((fare) => (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  double totalBaggageOnly() {
    final fareList = _myBox.get('torTicket');
    // String cardTypeToFilter = 'mastercard';

    double totalAmount = fareList
        .where((fare) =>
            // fare['cardType'] == cardTypeToFilter &&
            fare['baggage'] > 0 && fare['fare'] == 0)
        .map<num>((fare) => (fare['baggage'] as num).toDouble())
        .fold(0.0, (prev, amount) => prev + amount);

    return totalAmount;
  }

  // end counter fetcher

  // name fetcher
  String getEmpName(String empNo) {
    try {
      final employeeList = _myBox.get('employeeList');
      print('employeeList: $employeeList');
      print('empNo: $empNo');
      final driverData = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo,
      );
      String mname = driverData['middleName'] as String;

      String mi = '';
      if (mname != '') {
        mi = mname.substring(0, 1);
      }
      String driverName =
          '${driverData['firstName']} $mi. ${driverData['lastName']}';
      return driverName;
    } catch (e) {
      print("getEmpName error: $e");
      return '';
    }
  }

  String driverName() {
    final employeeList = _myBox.get('employeeList');
    final torDispatch = _myBox.get('torDispatch');
    final driverData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() == torDispatch['driverEmpNo'].toString(),
    );
    String mname = driverData['middleName'] as String;

    String mi = '';
    if (mname != '') {
      mi = mname.substring(0, 1);
    }
    String driverName =
        '${driverData['firstName']} $mi. ${driverData['lastName']}';

    return driverName;
  }

  String conductorName() {
    final employeeList = _myBox.get('employeeList');
    final torDispatch = _myBox.get('torDispatch');
    final conductorData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() ==
          torDispatch['conductorEmpNo'].toString(),
    );
    String mname = conductorData['middleName'] as String;

    String mi = '';
    if (mname != '') {
      mi = mname.substring(0, 1);
    }
    String conductorName =
        '${conductorData['firstName']} $mi. ${conductorData['lastName']}';

    return conductorName;
  }
  // end name fetcher

  // list fetcher

  List<Map<String, dynamic>> fetchEmployeeList() {
    final employeeList = _myBox.get('employeeList');
    return employeeList;
  }

  List<Map<String, dynamic>> fetchCardList() {
    final cardList = _myBox.get('cardList');
    return cardList;
  }

  List<Map<String, dynamic>> fetchVehicleList() {
    final vehicleList = _myBox.get('vehicleList');
    return vehicleList;
  }

  List<Map<String, dynamic>> fetchExpensesList() {
    final expenses = _myBox.get('expenses');
    return expenses;
  }

  List<Map<String, dynamic>> fetchVehicleListDB() {
    List<Map<String, dynamic>> vehicleList = [];
    try {
      vehicleList = _myBox.get('vehicleListDB');
    } catch (e) {
      print(e);
    }

    return vehicleList;
  }

  String getCurrentVehicleNo() {
    final torTrip = _myBox.get('torTrip');
    final sessionBox = _myBox.get('SESSION');
    final coopData = _myBox.get('coopData');
    String vehicleNo = coopData['coopType'] == "Jeepney"
        ? "${torTrip[sessionBox['currentTripIndex']]['bus_no']}:${torTrip[sessionBox['currentTripIndex']]['plate_number']} "
        : "${torTrip[sessionBox['currentTripIndex']]['bus_no']}";
    return vehicleNo;
  }

  List<dynamic> fetchTerminalList() {
    final routeList = _myBox.get('routeList');
    List<dynamic> terminals = routeList
        .expand((terminal) => [terminal['origin'], terminal['destination']])
        .toList();

    return terminals;
  }

  Map<String, dynamic> fetchCoopData() {
    final coopData = _myBox.get('coopData');
    return coopData;
  }

  List<Map<String, dynamic>> fetchFilipayCardList() {
    final filipayCardList = _myBox.get('filipayCardList');
    return filipayCardList;
  }

  List<Map<String, dynamic>> fetchMasterCardList() {
    final masterCardList = _myBox.get('masterCardList');
    return masterCardList;
  }

  List<Map<String, dynamic>> fetchRouteList() {
    final routeList = _myBox.get('routeList');
    return routeList;
  }

  List<Map<String, dynamic>> fetchStationList() {
    final stationList = _myBox.get('stationList');
    return stationList;
  }

// ====================== for filipay card list ================
  List<Map<String, dynamic>> processRiderData(
      List<Map<String, dynamic>> riderWalletData,
      List<Map<String, dynamic>> riderData) {
    List<Map<String, dynamic>> result = [];

    for (var walletEntry in riderWalletData) {
      // Find corresponding rider data or use a default empty map if not found
      var riderEntry = riderData.firstWhere(
        (rider) => rider['_id'] == walletEntry['riderId'],
        orElse: () => <String, Object>{},
      );

      // Check if riderEntry is not empty before extracting information
      if (riderEntry.isNotEmpty) {
        // Extract relevant information and create a new entry in the result
        var entry = {
          '_id': riderEntry['_id'],
          'cardID': riderEntry['cardId'],
          'balance': walletEntry['balance'],
          'cardType': determineCardType(riderEntry['sNo']),
        };

        result.add(entry);
      }
    }

    return result;
  }

  String determineCardType(String cardId) {
    // You can implement your logic to determine card type based on cardId
    // For example, you can check if the cardId starts with a specific prefix
    if (cardId.startsWith('SNR')) {
      return 'regular';
    } else {
      return 'discounted';
    }
  }

// ====================== end for filipay card list ================
  Future<bool> fetchdata() async {
    final session = _myBox.get('SESSION');
    // final torTrip = _myBox.get('torTrip');
    // if (torTrip.isEmpty) {
    try {
      bool isDeviceValid = await httprequestServices.isDeviceValid();
      if (!isDeviceValid) {
        print('error invalid device');
        return false;
      }

      bool isGetCoopData =
          await httprequestServices.getCoopData(session['coopId']);
      if (!isGetCoopData) {
        print('error getting coopdata');
        return false;
      }
      // _myBox.put('coopData', [
      //   {
      //     '_id': '1',
      //     'coopName': 'DEL MONTE LAND TRANSPORT\nBUS COMPANY, INC. (LUCENA)',
      //     'minimum_fare': 15,
      //     'first_km': 4
      //   }
      // ]);

      bool isgetFilipayCardList =
          await httprequestServices.getFilipayCardList();
      if (!isgetFilipayCardList) {
        print('cant get filipay card list');
        return false;
      }
      // _myBox.put('filipayCardList', [
      //   {
      //     '_id': '1',
      //     'cardID': '043514BAF36D80',
      //     'balance': 125,
      //     'cardType': 'regular'
      //   },
      //   {
      //     '_id': '2',
      //     'cardID': '045276C2F36D80',
      //     'balance': 100,
      //     'cardType': 'discounted'
      //   },
      //   {
      //     '_id': '3',
      //     'cardID': '6BBB4ED9',
      //     'balance': 500,
      //     'cardType': 'regular'
      //   },
      //   {
      //     '_id': '4',
      //     'cardID': '6B284CD9',
      //     'balance': 500,
      //     'cardType': 'discounted'
      //   },
      // ]);
      // }
      // final riderWalletData = _myBox.get('riderWallet');
      // final riderData = _myBox.get('rider');
      // List<Map<String, dynamic>> filipayCardList =
      //     processRiderData(riderWalletData, riderData);
      // print('filipayCardList: $filipayCardList');
      // _myBox.put('filipayCardList', filipayCardList
      //     // [
      //     //   {
      //     //     '_id': '1',
      //     //     'cardID': '043514BAF36D80',
      //     //     'balance': 125,
      //     //     'cardType': 'regular'
      //     //   },
      //     //   {
      //     //     '_id': '2',
      //     //     'cardID': '045276C2F36D80',
      //     //     'balance': 100,
      //     //     'cardType': 'discounted'
      //     //   },
      //     // ]
      //     );

      if (isGetCoopData) {
        bool isGetMasterCard = await httprequestServices.getMasterCardData();
        if (!isGetMasterCard) {
          print('cant get mastercard');
          return false;
        }
      }
      // List<Map<String, dynamic>> mastercardlist = [
      //   {
      //     '_id': '1',
      //     'cardID': '2B3D4DD9',
      //     'balance': 10000,
      //     'cardType': 'mastercard',
      //     'empNo': 8526,
      //   },
      //   // temporary
      //   {
      //     '_id': '2',
      //     'cardID': '1F0990CA',
      //     'balance': 10000,
      //     'cardType': 'mastercard',
      //     'empNo': 7496
      //   },
      //   {
      //     '_id': '3',
      //     'cardID': 'DB9B76D9',
      //     'balance': 10000,
      //     'cardType': 'mastercard',
      //     'empNo': 7550
      //   },
      // ];
      // _myBox.put('masterCardList', mastercardlist);

      bool isGetrouteList =
          await httprequestServices.getRouteList(session['coopId']);
      if (!isGetrouteList) {
        print('cant get routeList');
        return false;
      }

      // _myBox.put('routeList', [
      //   {
      //     '_id': '1',
      //     'origin': 'DISTRICT',
      //     'destination': 'STAR MALL',
      //     'bound': 'NORTH',
      //     'code': 'DISTAR',
      //   },
      //   {
      //     '_id': '2',
      //     'origin': 'LRT',
      //     'destination': 'LUCENA',
      //     'bound': 'SOUTH',
      //     'code': 'CLT',
      //   },
      // ]);

      bool isGetstationList =
          await httprequestServices.getStationList(session['coopId']);
      if (!isGetstationList) {
        print('cant get stationList');
        return false;
      }
      // _myBox.put('stationList', [
      //   {
      //     '_id': '1',
      //     'stationName': 'DISCTRICT',
      //     'km': 0,
      //     'viceVersaKM': 18,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '2',
      //     'stationName': 'MOLINO',
      //     'km': 2,
      //     'viceVersaKM': 16,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '3',
      //     'stationName': 'SOMO',
      //     'km': 4,
      //     'viceVersaKM': 14,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '4',
      //     'stationName': 'TOYOTA',
      //     'km': 6,
      //     'viceVersaKM': 12,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '5',
      //     'stationName': 'MOLITO',
      //     'km': 10,
      //     'viceVersaKM': 10,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '6',
      //     'stationName': 'ATC',
      //     'km': 12,
      //     'viceVersaKM': 6,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '7',
      //     'stationName': 'NORTH GATE',
      //     'km': 14,
      //     'viceVersaKM': 4,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '8',
      //     'stationName': 'SOUTH STATION',
      //     'km': 16,
      //     'viceVersaKM': 2,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '9',
      //     'stationName': 'STAR MALL',
      //     'km': 18,
      //     'viceVersaKM': 0,
      //     'routeID': '1',
      //   },
      //   {
      //     '_id': '10',
      //     'stationName': 'LRT Buendia',
      //     'km': 0,
      //     'viceVersaKM': 130,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '11',
      //     'stationName': 'EDSA-Taft Station',
      //     'km': 1,
      //     'viceVersaKM': 71,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '12',
      //     'stationName': 'Buendia Ave & Pasong Tamo',
      //     'km': 3,
      //     'viceVersaKM': 55,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '13',
      //     'stationName': 'ALABANG',
      //     'km': 13,
      //     'viceVersaKM': 41,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '14',
      //     'stationName': 'SAN PEDRO',
      //     'km': 19,
      //     'viceVersaKM': 28,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '15',
      //     'stationName': 'BINAN',
      //     'km': 28,
      //     'viceVersaKM': 19,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '16',
      //     'stationName': 'CALAMBA',
      //     'km': 41,
      //     'viceVersaKM': 13,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '17',
      //     'stationName': 'LOS BANOS',
      //     'km': 55,
      //     'viceVersaKM': 3,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '18',
      //     'stationName': 'PAGSANJAN',
      //     'km': 71,
      //     'viceVersaKM': 1,
      //     'routeID': '2',
      //   },
      //   {
      //     '_id': '19',
      //     'stationName': 'LUCENA CITY TERMINAL',
      //     'km': 130,
      //     'viceVersaKM': 0,
      //     'routeID': '2',
      //   }
      // ]);
      bool isGetvehicleList =
          await httprequestServices.getVehicleList(session['coopId']);
      if (!isGetvehicleList) {
        print('cant get vehicleList');
        return false;
      }

      List<Map<String, dynamic>> vehicleList = [];
      final vehicleListDB = _myBox.get('vehicleListDB');
      for (int i = 0; i < 10000; i++) {
        String plate_number = "";
        if (vehicleListDB.isNotEmpty) {
          // print('vehicleListDB: $vehicleListDB');
          if (vehicleListDB.length > i) {
            if (vehicleListDB[i]['vehicle_no'].toString() == "${i + 1}") {
              plate_number = "${vehicleListDB[i]['plate_no']}";
            }
          }
        }
        vehicleList.add({
          "_id": "$i",
          'vehicle_no': "${i + 1}",
          'plate_number': "$plate_number"
        });
      }
      _myBox.put('vehicleList', vehicleList);

      bool iscardList =
          await httprequestServices.getcardList(session['coopId']);
      if (!iscardList) {
        print('cant get iscardList');
        return false;
      }

      // _myBox.put('cardList', [
      //   {'cardID': 'FC95D656', 'empNo': 8526},
      //   {'cardID': '8B8253D9', 'empNo': 7496},
      //   {'cardID': '5B674BD9', 'empNo': 7550},
      //   {'cardID': '04235CAA2F6F80', 'empNo': 7497},
      //   {'cardID': 'CB1A4CD9', 'empNo': 7325},
      //   {'cardID': '049450BAF36D80', 'empNo': 1427},
      //   // temporary
      //   {'cardID': 'DB5B43D9', 'empNo': 7550},
      //   {'cardID': '9BCA4CD9', 'empNo': 8526},
      //   {'cardID': '0582BCB4864200', 'empNo': 7496},
      //   {'cardID': '1F0920AF', 'empNo': 1427},

      //   // new
      //   {'cardID': 'B5866EB3', 'empNo': 9133},
      //   {'cardID': 'A1994629', 'empNo': 8041},
      //   {'cardID': 'AB5244D9', 'empNo': 1212},
      //   {'cardID': 'AB4D50D9', 'empNo': 1213},
      //   {'cardID': 'CB8849D9', 'empNo': 0124},
      //   {'cardID': 'FBF341D9', 'empNo': 0001},
      //   {'cardID': '2B3052D9', 'empNo': 0012},
      //   {'cardID': 'FB6342D9', 'empNo': 0123},
      // ]);
      bool isgetemployeeList =
          await httprequestServices.getemployeeList(session['coopId']);
      if (!isgetemployeeList) {
        print('cant get isgetemployeeList');
        return false;
      }
      // _myBox.put('employeeList', [
      //   {
      //     "lastName": "INSPECTOR",
      //     "firstName": "",
      //     "middleName": "TEST",
      //     "nameSuffix": "",
      //     "empNo": 0001,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "INSPECTOR TEST",
      //     "designation": "Inspector",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Inspector",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "CASHIER",
      //     "firstName": "",
      //     "middleName": "TEST",
      //     "nameSuffix": "",
      //     "empNo": 0012,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "CASHIER TEST",
      //     "designation": "Cashier",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Cashier",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "CONDUCTOR",
      //     "firstName": "",
      //     "middleName": "TEST 2",
      //     "nameSuffix": "",
      //     "empNo": 0123,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "CONDUCTOR TEST 2",
      //     "designation": "Conductor",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Conductor",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "DRIVER",
      //     "firstName": "",
      //     "middleName": "DRIVER 2",
      //     "nameSuffix": "",
      //     "empNo": 0124,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "DRIVER TEST 2",
      //     "designation": "Driver",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Driver",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   // OLD
      //   {
      //     "lastName": "BOLA",
      //     "firstName": "ANTHONY",
      //     "middleName": "BRITANICO",
      //     "nameSuffix": "",
      //     "empNo": 1427,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "ANTHONY B. BOLA ",
      //     "designation": "Temporary GPS Section Staff Cashier",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Cashier",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "SAN PEDRO",
      //     "firstName": "ARDIE",
      //     "middleName": "L",
      //     "nameSuffix": "",
      //     "empNo": 9133,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "ARDIE L. SAN PEDRO ",
      //     "designation": "Bus Conductor",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Conductor",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "GARCIA",
      //     "firstName": "GEORGE",
      //     "middleName": "M",
      //     "nameSuffix": "",
      //     "empNo": 8041,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "GEORGE M. GARCIA",
      //     "designation": "Bus Driver",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Driver",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "Test",
      //     "firstName": "Dispatcher",
      //     "middleName": "",
      //     "nameSuffix": "",
      //     "empNo": 1212,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "Conductor Test",
      //     "designation": "Bus Dispatcher",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Dispatcher",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "Test",
      //     "firstName": "Dispatcher 2",
      //     "middleName": "",
      //     "nameSuffix": "",
      //     "empNo": 1213,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "Conductor 2 Test",
      //     "designation": "Bus Dispatcher",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Dispatcher",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "_id": "1",
      //     "lastName": "ABABAO",
      //     "firstName": "JOVY",
      //     "middleName": "FOLLERO",
      //     "nameSuffix": "",
      //     "empNo": 8526,
      //     "empStatus": "AWOL",
      //     "empType": "Probationary",
      //     "idName": "JOVY F. ABABAO",
      //     "designation": "Bus Driver",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/2FF5B370836975D1FBBB1568620176B46990F65973568B99085F0B6A2D1C260F.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/68DFF7E01D9FFD49BACC5F37F9F7E8B05EEE49B61C94B4C1019D659E25E2DB25.jpg?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Bus Driver / Conductor",
      //     "JTI_RFID_RequestDate": "12/15/2022"
      //   },
      //   {
      //     "_id": "2",
      //     "lastName": "ABAN",
      //     "firstName": "CHRISTIAN GERALD",
      //     "middleName": "ADIO",
      //     "nameSuffix": "",
      //     "empNo": 7496,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "CHRISTIAN GERALD A. ABAN ",
      //     "designation": "Bus Conductor",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/E36D5ACEB471948EED2FA912347B002FB67B97BE78B6C746CE70894BE16CFFEA.jpg?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/4896AD46301B2365E7303FEAC2BECE1590D9E09B333CFF4E639FD2E614B66D19.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "TripKo Mastercard",
      //     "JTI_RFID_RequestDate": "03/11/2023"
      //   },
      //   {
      //     "_id": "3",
      //     "lastName": "ALABAN",
      //     "firstName": "RITCHEI",
      //     "middleName": "HAGONOS",
      //     "nameSuffix": "",
      //     "empNo": 7550,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "RITCHEI H. ALABAN ",
      //     "designation": "Dispatcher",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/C5B6DD000D7DE400D7C68FE128D7002B9F936FD514486D85460D7493E48F0878.jpg?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/86C369E6F13497C1A9990D3B41D01E52259E98DBE421F95207A2A62D1D1D510B.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Dispatcher / Cashier",
      //     "JTI_RFID_RequestDate": "10/11/2021"
      //   },
      //   {
      //     "_id": "4",
      //     "lastName": "ABANTO",
      //     "firstName": "CRISTOPHER",
      //     "middleName": "LIZANO",
      //     "nameSuffix": "",
      //     "empNo": 7497,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "CRISTOPHER L. ABANTO ",
      //     "designation": "Bus Conductor",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/449FC907E5E1C9DAF900A40C085BB462B9750A2AB9846DD66545CEB4EFA5470C.jpg?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/99A8C701A413E53ADD0677BEAD7D5C5890A882CD945AF1C235BB86255F5FB9A4.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "TripKo Mastercard",
      //     "JTI_RFID_RequestDate": "03/11/2023"
      //   },
      //   {
      //     "lastName": "BOLA",
      //     "firstName": "ANTHONY",
      //     "middleName": "BRITANICO",
      //     "nameSuffix": "",
      //     "empNo": 1427,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "ANTHONY B. BOLA ",
      //     "designation": "Temporary GPS Section Staff Cashier",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Cashier",
      //     "JTI_RFID_RequestDate": ""
      //   },
      //   {
      //     "lastName": "ACIBAR",
      //     "firstName": "DANIEL",
      //     "middleName": "M.",
      //     "nameSuffix": "",
      //     "empNo": 7325,
      //     "empStatus": "Active/Recalled",
      //     "empType": "Regular",
      //     "idName": "DANIEL M. ACIBAR ",
      //     "designation": "Inspector",
      //     "idPicture":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/E465AE96FC77D0FA19C8B5E7A7131244B62BA530D661FBF28C2D7C3DB02DE72A.jpg?RCType=EmbeddedRCFileProcessor",
      //     "idSignature":
      //         "https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/7C1325D72DA98845A734BD8F0576136436A59152746E6C2E790AFC8E4DC44BAC.png?RCType=EmbeddedRCFileProcessor",
      //     "JTI_RFID": "YES",
      //     "accessPrivileges": "Inspector",
      //     "JTI_RFID_RequestDate": ""
      //   }
      // ]);
      return true;
    } catch (e) {
      print('fetch error: $e');
      return false;
    }
    // } else {
    //   return true;
    // }
  }

  List<Map<String, dynamic>> fetchPrepaidTicket() {
    try {
      final prepaidTicket = _myBox.get('prepaidTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all prepaidTicket: $prepaidTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentprepaidTicket = prepaidTicket
          .where((item) => item['control_no'] == control_no)
          .toList();
      print('success currentprepaidTicket: $currentprepaidTicket');
      return currentprepaidTicket;
    } catch (e) {
      print('currentprepaidTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchPrepaidBaggage() {
    try {
      final prepaidBaggage = _myBox.get('prepaidBaggage');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all prepaidBaggage: $prepaidBaggage');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentprepaidBaggage = prepaidBaggage
          .where((item) => item['control_no'] == control_no)
          .toList();
      print('success currentprepaidBaggage: $currentprepaidBaggage');
      return currentprepaidBaggage;
    } catch (e) {
      print('currentprepaidBaggage error: $e');
      return [];
    }
  }

  int fetchAllPassengerCount() {
    int allPassenger = 0;
    try {
      final prepaidTicket = _myBox.get('prepaidTicket');
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket = torTicket
          .where((item) => item['control_no'] == control_no && item['fare'] > 0)
          .toList();
      int sumOfPax = 0;
      try {
        sumOfPax = torTicket
            .where((ticket) =>
                ticket['control_no'] == control_no && (ticket['fare'] ?? 0) > 0)
            .fold(0, (sum, ticket) => sum + (ticket['pax'] ?? 1));
      } catch (e) {
        print("fetchAllPassengerCount: $e");
      }

      List<Map<String, dynamic>> currentprepaidTicket = prepaidTicket
          .where((item) => item['control_no'] == control_no)
          .toList();
      int sumTotalPassenger = currentprepaidTicket.fold(
        0,
        (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
      );
      allPassenger = sumOfPax + sumTotalPassenger;

      return allPassenger;
    } catch (e) {
      return allPassenger;
    }
  }

  List<Map<String, dynamic>> fetchTorTicket() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket = torTicket
          .where((item) => item['control_no'] == control_no
              // && item['fare'] > 0
              )
          .toList();
      print('success fetchTorTicket: $currentTorTicket');
      return currentTorTicket;
    } catch (e) {
      print('fetchTorTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchAllTorTicketTrip() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket =
          torTicket.where((item) => item['control_no'] == control_no).toList();
      print('success fetchTorTicket: $currentTorTicket');
      return currentTorTicket;
    } catch (e) {
      print('fetchTorTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchAllTorInspectionTrip() {
    try {
      final torTicket = _myBox.get('torInspection');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTtorInspection =
          torTicket.where((item) => item['control_no'] == control_no).toList();
      print('success torInspection: $currentTtorInspection');
      print('all torInspection: $torTicket');
      return currentTtorInspection;
    } catch (e) {
      print('torInspection error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchallPerTripTicket() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket =
          torTicket.where((item) => item['control_no'] == control_no).toList();
      print('success fetchTorTicket: $currentTorTicket');
      return currentTorTicket;
    } catch (e) {
      print('fetchTorTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchTorBaggage() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket = torTicket
          .where(
              (item) => item['control_no'] == control_no && item['baggage'] > 0)
          .toList();
      print('success fetchTorTicket: $currentTorTicket');
      return currentTorTicket;
    } catch (e) {
      print('fetchTorTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> fetchStopsTicket() {
    try {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      print('all torTicket: $torTicket');

      String control_no = torTrip[session['currentTripIndex']]['control_no'];
      // print('torNo: $torNo');
      List<Map<String, dynamic>> currentTorTicket =
          torTicket.where((item) => item['control_no'] == control_no).toList();
      print('success fetchTorTicket: $currentTorTicket');
      return currentTorTicket;
    } catch (e) {
      print('fetchTorTicket error: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> filteredStation() {
    final stations = fetchStationList();
    final SESSION = _myBox.get('SESSION');
    String routeid = SESSION['routeID'];

    List<Map<String, dynamic>> filteredStations = stations
        .where((station) => station['routeId'].toString() == routeid)
        .toList();

    filteredStations.sort((a, b) {
      int rowNoA = a['rowNo'] ?? 0;
      int rowNoB = b['rowNo'] ?? 0;
      return rowNoA.compareTo(rowNoB);
    });
    // Sort the filtered stations based on the 'createdAt' field
    // filteredStations.sort((a, b) {
    //   String createdAtA = a['createdAt'] ?? '';
    //   String createdAtB = b['createdAt'] ?? '';
    //   // Convert createdAt strings to DateTime for comparison
    //   DateTime dateTimeA = DateTime.tryParse(createdAtA) ?? DateTime(0);
    //   DateTime dateTimeB = DateTime.tryParse(createdAtB) ?? DateTime(0);
    //   return dateTimeA.compareTo(dateTimeB);
    // });
    return filteredStations;
  }

  int onBoardPassenger() {
    final torTicket = _myBox.get('torTicket');
    final SESSION = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    final filteredStations = filteredStation();
    int currentStation = int.parse(
        filteredStations[SESSION['currentStationIndex']]['rowNo'].toString());
    print('onBoardPassenger currentStation: $currentStation');

    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    try {
      // int onboardPassenger = 0;

      // onboardPassenger = torTicket.where((item) {
      //   print('onBoardPassenger ticket: $item');
      //   final torNoInTicket = item['control_no'];
      //   final fare = item['fare'] ?? 0;
      //   int stationNo = int.parse(item['rowNo'].toString());
      //   return stationNo > currentStation &&
      //       torNoInTicket == control_no &&
      //       fare > 0;
      // }).length;

      int sumOfPax = torTicket.where((ticket) {
        int stationNo = int.parse(ticket['rowNo'].toString());
        return ticket['control_no'] == control_no &&
            ticket['reverseNum'] == SESSION['reverseNum'] &&
            (ticket['fare'] ?? 0.0) > 0 &&
            stationNo > currentStation;
      }).fold(0, (sum, ticket) => sum + (ticket['pax'] ?? 1));

      return sumOfPax;
    } catch (e) {
      print(e);
      print("onboardPassenger error: $e");
      return 0;
    }
  }

  int inspectorOnBoardPassenger(double currentKM) {
    final torTicket = _myBox.get('torTicket');

    final SESSION = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    final filteredStations = filteredStation();

    bool isReverseOBP = false;

    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    print('kmrun control_no: $control_no');
    try {
      int onboardPassenger = 0;
      print('kmRun currentKM:  $currentKM');
      onboardPassenger = torTicket.fold(0, (sum, item) {
        print('kmrun from: ${item['from_km']}');
        print('kmrun to: ${item['to_km']}');
        double Negative = double.parse(item['from_km'].toString()) -
            double.parse(item['to_km'].toString());
        print('kmRun isNegative: $Negative');

        double kmRun = double.parse(item['to_km'].toString());
        if (Negative < 0) {
          print('kmrun lessthan to');
          isReverseOBP = true;
          kmRun = kmRun.abs();
        } else {
          isReverseOBP = false;
        }
        print('kmRun isReverseOBP 1: $isReverseOBP');
        print('kmRun: $kmRun');

        final torNoInTicket = item['control_no'];
        print('kmrun torNoInTicket: $torNoInTicket');
        final fare = item['fare'] ?? 0;
        final reverseNum = item['reverseNum'];
        final pax = item['pax'] ?? 1;
        print('kmrun fare: $fare');
        if (kmRun == null || torNoInTicket == null) {
          return sum; // Skip invalid entries
        }

        if (kmRun == null) {
          return sum; // Skip entries with non-integer "km_run" values
        }

        print('kmRun firstkm: ${filteredStations[0]['km']}');
        if (!isReverseOBP) {
          // if (kmRun == int.parse(filteredStations[0]['km'].toString())) {
          //   return sum +
          //       (kmRun <= currentKM &&
          //               torNoInTicket == control_no &&
          //               reverseNum == SESSION['reverseNum'] &&
          //               fare > 0
          //           ? pax
          //           : 0);
          // } else {
          return sum +
              (kmRun < currentKM &&
                      torNoInTicket == control_no &&
                      reverseNum == SESSION['reverseNum'] &&
                      fare > 0
                  ? pax
                  : 0);
          // }
        } else {
          // if (kmRun == 0) {
          //   return sum +
          //       (kmRun >= currentKM && torNoInTicket == control_no && fare > 0
          //           ? pax
          //           : 0);
          // } else {
          return sum +
              (kmRun > currentKM &&
                      torNoInTicket == control_no &&
                      reverseNum == SESSION['reverseNum'] &&
                      fare > 0
                  ? pax
                  : 0);
          // }
        }
      });
      print('kmrun onboardPassenger: $onboardPassenger');
      return onboardPassenger;
    } catch (e) {
      print(e);
      print("km run onboardPassenger error: $e");
      return 0;
    }
  }

  int onBoardBaggage() {
    final torTicket = _myBox.get('torTicket');
    final SESSION = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    final filteredStations = filteredStation();
    int currentStation = int.parse(
        filteredStations[SESSION['currentStationIndex']]['rowNo'].toString());
    print('onboardBaggage currentStation: $currentStation');

    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    try {
      int onboardBaggage = 0;

      onboardBaggage = torTicket.where((item) {
        print('onboardBaggage ticket: $item');
        final torNoInTicket = item['control_no'];
        final baggage = item['baggage'] ?? 0;
        final reverseNum = item['reverseNum'];
        int stationNo = int.parse(item['rowNo'].toString());
        return stationNo > currentStation &&
            torNoInTicket == control_no &&
            reverseNum == SESSION['reverseNum'] &&
            baggage > 0;
      }).length;

      return onboardBaggage;
    } catch (e) {
      print(e);
      print("1 onboardBaggage error: $e");
      return 0;
    }
  }

  int onBoardBaggageOnly() {
    final torTicket = _myBox.get('torTicket');
    final SESSION = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');

    final filteredStations = filteredStation();
    int currentStation = int.parse(
        filteredStations[SESSION['currentStationIndex']]['rowNo'].toString());
    print('onboardBaggage currentStation: $currentStation');

    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    try {
      int onboardBaggageOnly = 0;

      onboardBaggageOnly = torTicket.where((item) {
        print('onboardBaggage ticket: $item');
        final torNoInTicket = item['control_no'];
        final baggage = item['baggage'] ?? 0;
        final fare = item['fare'] ?? 0;
        final reverseNum = item['reverseNum'];
        int stationNo = int.parse(item['rowNo'].toString());
        return stationNo > currentStation &&
            torNoInTicket == control_no &&
            reverseNum == SESSION['reverseNum'] &&
            baggage > 0 &&
            fare == 0;
      }).length;

      return onboardBaggageOnly;
    } catch (e) {
      print(e);
      print("2 onboardBaggage error: $e");
      return 0;
    }
  }

  int inspectorOnBoardBaggageOnly(double currentKM) {
    final torTicket = _myBox.get('torTicket');
    final torTrip = _myBox.get('torTrip');
    final SESSION = _myBox.get('SESSION');
    final filteredStations = filteredStation();
    // int currentKM = stations[SESSION['currentStationIndex']]['km'];
    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    bool isReverse = false;
    try {
      int onboardBaggage = 0;
      onboardBaggage = torTicket.where((item) {
        print('onboard baggage only fare: ${item}');

        double isNegative = double.parse(item['from_km'].toString()) -
            double.parse(item['to_km'].toString());
        double kmRun = double.parse(item['to_km'].toString());
        if (isNegative < 0) {
          isReverse = true;
          kmRun = kmRun.abs();
        } else {
          isReverse = false;
        }
        final torNoInTicket = item['control_no'];
        final baggage = item['baggage'] ?? 0;
        final fare = item['fare'] ?? 0;
        final reverseNum = item['reverseNum'];
        if (kmRun == null || torNoInTicket == null) {
          return false; // Handle missing "km_run" or "tor_no" data
        }

        if (kmRun == null) {
          return false; // Handle non-integer "km_run" values
        }
        if (!isReverse) {
          if (kmRun == double.parse(filteredStations[0]['km'].toString())) {
            return kmRun <= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare == 0;
          } else {
            return kmRun < currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare == 0;
          }
        } else {
          if (kmRun == 0) {
            return kmRun >= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare == 0;
          } else {
            return kmRun > currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare == 0;
          }
        }
      }).length;
      return onboardBaggage;
    } catch (e) {
      print("3 onBoardBaggage error: $e");
      return 0;
    }
  }

  int onBoardBaggageWithPassenger() {
    final torTicket = _myBox.get('torTicket');
    final torTrip = _myBox.get('torTrip');
    final SESSION = _myBox.get('SESSION');
    final filteredStations = filteredStation();
    double currentKM = double.parse(
        filteredStations[SESSION['currentStationIndex']]['km'].toString());
    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    bool isReverse = false;
    try {
      int onboardBaggage = 0;
      onboardBaggage = torTicket.where((item) {
        double isNegative = double.parse(item['from_km'].toString()) -
            double.parse(item['to_km'].toString());
        double kmRun = double.parse(item['to_km'].toString());
        if (isNegative < 0) {
          isReverse = true;
          kmRun = kmRun.abs();
        } else {
          isReverse = false;
        }
        final torNoInTicket = item['control_no'];
        final baggage = item['baggage'] ?? 0;
        final fare = item['fare'] ?? 0;
        final reverseNum = item['reverseNum'];
        if (kmRun == null || torNoInTicket == null) {
          return false; // Handle missing "km_run" or "tor_no" data
        }

        if (kmRun == null) {
          return false; // Handle non-integer "km_run" values
        }
        if (!isReverse) {
          if (kmRun == double.parse(filteredStations[0]['km'].toString())) {
            return kmRun <= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          } else {
            return kmRun < currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          }
        } else {
          if (kmRun == 0) {
            return kmRun >= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          } else {
            return kmRun > currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          }
        }
      }).length;
      return onboardBaggage;
    } catch (e) {
      print("4 onBoardBaggage error: $e");
      return 0;
    }
  }

  int inspectorOnBoardBaggageWithPassenger(double currentKM) {
    final torTicket = _myBox.get('torTicket');
    final torTrip = _myBox.get('torTrip');
    final SESSION = _myBox.get('SESSION');
    final filteredStations = filteredStation();
    // int currentKM = filteredStations[SESSION['currentStationIndex']]['km'];
    String control_no = torTrip[SESSION['currentTripIndex']]['control_no'];
    bool isReverse = false;
    try {
      int onboardBaggage = 0;
      onboardBaggage = torTicket.where((item) {
        double isNegative = double.parse(item['from_km'].toString()) -
            double.parse(item['to_km'].toString());
        double kmRun = double.parse(item['to_km'].toString());
        if (isNegative < 0) {
          isReverse = true;
          kmRun = kmRun.abs();
        } else {
          isReverse = false;
        }
        final torNoInTicket = item['control_no'];
        final baggage = item['baggage'] ?? 0;
        final fare = item['fare'] ?? 0;
        final reverseNum = item['reverseNum'];
        if (kmRun == null || torNoInTicket == null) {
          return false; // Handle missing "km_run" or "tor_no" data
        }

        if (kmRun == null) {
          return false; // Handle non-integer "km_run" values
        }
        if (!isReverse) {
          if (kmRun == double.parse(filteredStations[0]['km'].toString())) {
            return kmRun <= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          } else {
            return kmRun < currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          }
        } else {
          if (kmRun == 0) {
            return kmRun >= currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          } else {
            return kmRun > currentKM &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'] &&
                baggage > 0 &&
                fare > 0;
          }
        }
      }).length;
      return onboardBaggage;
    } catch (e) {
      print("5 onBoardBaggage error: $e");
      return 0;
    }
  }

  List<Map<String, dynamic>> getFilteredStations(
      List<Map<String, dynamic>> stationList) {
    final SESSION = _myBox.get('SESSION');
    String routeid = SESSION['routeID'];
    return stationList
        .where((station) => station['routeID'] == routeid)
        .toList();
  }

  Future<Map<String, dynamic>> fetchBalance(
      String cardID, String cardType, String coopId) async {
    // Replace 'YOUR_BEARER_TOKEN' with your actual Bearer token
    String bearerToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiZnVuY3Rpb24gbm93KCkgeyBbbmF0aXZlIGNvZGVdIH0iLCJpYXQiOjE2OTcwOTcyNjl9.tT7GdpjGqGRRuP83ts2Ok2arhVu8sAyFKWjd8M7do9k';

    // Replace 'https://api.example.com/data' with the actual API endpoint URL
    String apiUrl =
        'http://172.232.77.205:3000/api/v1/filipay/riderwallet/balance/$cardID/$cardType/$coopId';

    try {
      //    final client = http.Client();
      // // Set up the security context to trust custom root certificates
      // final securityContext = SecurityContext.defaultContext;
      // securityContext.setTrustedCertificates('path_to_your_certificates.pem');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        print('Data: $data');
        return data;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {'error': 'Failed to fetch data'};
      }
    } catch (error) {
      // Handle network or other errors

      print('Error: $error');
      return {'error': 'Failed to fetch data'};
    }
  }

  String getRemarks() {
    String remarks = '';
    try {
      final torTrip = _myBox.get('torTrip');
      String firstDispatchTime = torTrip[0]['departed_time'];
      String lastDispatchTime = torTrip[torTrip.length - 1]['departed_time'];

      DateTime datefirstDispatchTime = DateTime.parse(firstDispatchTime);
      DateTime datelastDispatchTime = DateTime.parse(lastDispatchTime);

      // Get the current date
      // DateTime currentDate = DateTime.now();

      // Compare the dates (ignoring time)
      // bool isSameDate = dateFromString.year == currentDate.year &&
      //     dateFromString.month == currentDate.month &&
      //     dateFromString.day == currentDate.day;

      bool isSameDate =
          datefirstDispatchTime.year == datelastDispatchTime.year &&
              datefirstDispatchTime.month == datelastDispatchTime.month &&
              datefirstDispatchTime.day == datelastDispatchTime.day;
      if (isSameDate) {
        print('The given date is the same as the current date.');
        remarks = 'Same Day';
      } else {
        print('The given date is different from the current date.');
        remarks = "Adjustment";
      }
      return remarks;
    } catch (e) {
      print(e);
      return remarks;
    }
  }

  bool getIsNumeric() {
    final sessionBox = _myBox.get('SESSION');

    String routeid = sessionBox['routeID'];
    final routeList = fetchRouteList();

    var selectedRoute =
        routeList.where((route) => route['_id'].toString() == routeid).toList();

    return selectedRoute != null
        ? selectedRoute[0]['isNumeric'] as bool? ?? false
        : false;
  }

  double roundToNearestQuarter(double number, minimumFare) {
    const interval = 0.25;
    final remainder = number % interval;
    print('roundToNearestQuarter remainder: $remainder');
    double roundedValue;
    double price = 0.0;

    if (remainder <= interval / 2) {
      roundedValue = number - remainder;
    } else {
      roundedValue = number + (interval - remainder);
    }
    price = double.parse(roundedValue.toStringAsFixed(2));
    print('roundToNearestQuarter price: $price');
    return price;
  }

  String getInspectorCurrentStation(
      List<Map<String, dynamic>> stations, double targetKm) {
    try {
      Map<String, dynamic>? nearestStation = stations.reduce((a, b) {
        double aDiff =
            (a['km'] is int ? (a['km'] as int).toDouble() : a['km']) - targetKm;
        double bDiff =
            (b['km'] is int ? (b['km'] as int).toDouble() : b['km']) - targetKm;

        return (aDiff.abs() < bDiff.abs()) ? a : b;
      });
      String nearestStationName = "";
      if (nearestStation != null) {
        nearestStationName = nearestStation['stationName'] as String;
      } else {
        print('No stations available');
      }

      return nearestStationName;
    } catch (e) {
      print('getInspectorCurrentStation error: $e');
      return "";
    }
  }

  String extractTagId(NfcTag tag) {
    // Try to extract the tag ID from different sections of the tag data
    String tagId = _bytesToHex(tag.data['nfca']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcb']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcf']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcv']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['mifareclassic']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['mifareultralight']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['ndefformatable']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['isodep']?['identifier'] ?? []) ??
        ''; // Default to an empty string if none found

    return tagId.toUpperCase();
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }
}
