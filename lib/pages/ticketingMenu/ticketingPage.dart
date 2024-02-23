import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';

import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class TicketingPage extends StatefulWidget {
  const TicketingPage({super.key});

  @override
  State<TicketingPage> createState() => _TicketingPageState();
}

class _TicketingPageState extends State<TicketingPage> {
  final _myBox = Hive.box('myBox');
  httprequestService httprequestServices = httprequestService();

  GeneratorServices generatorService = GeneratorServices();
  HiveService hiveService = HiveService();
  timeServices timeService = timeServices();
  DeviceInfoService deviceInfoService = DeviceInfoService();
  LoadingModal loadingModal = LoadingModal();
  fetchServices fetchservice = fetchServices();

  TextEditingController selectedStationNameController = TextEditingController();

  Map<dynamic, dynamic> sessionBox = {};
  fetchServices fetchService = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  TestPrinttt printService = TestPrinttt();
  double discount = 0.0;

  bool isMastercard = true;
  String bound = '';
  String route = '';
  String passengerType = '';
  String typeofCards = '';
  bool isFix = true;
  String selectedStationID = '';

  bool ismissingPassengerType = false;
  bool isDiscounted = false;
  String? selectedStationName;
  int rowNo = 0;
  int quantity = 1;

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  List<String> passengerTypeList = [
    "",
    "FULL FARE",
    "SENIOR",
    "STUDENT",
    "PWD",
    // "PASS",
    "BAGGAGE"
  ];
  List<Map<String, dynamic>> stationNames = [];
  String kmRun = '0';

  List<Map<String, dynamic>> routes = [];
  Map<dynamic, dynamic> selectedDestination = {};
  String routeid = '';
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> selectedRoute = [];
  List<Map<String, dynamic>> filipayCardList = [];
  Map<String, dynamic> coopData = {};
  List<Map<String, dynamic>> torTrip = [];
  Map<dynamic, dynamic> storedData = {};
  TextEditingController baggagePrice = TextEditingController(text: "0");
  TextEditingController editAmountController = TextEditingController();
  TextEditingController fromKmPostController = TextEditingController();
  TextEditingController toKmPostController = TextEditingController();

  TextEditingController passengerTypeController = TextEditingController();

  bool isNfcScanOn = false;
  double price = 0;
  double subtotal = 0.0;
  int currentStationIndex = 0;
  String routeCode = '';
  double toKM = 0;
  String stationkm = 'km';
  double minimumFare = 0;
  double pricePerKm = 0;
  double firstKM = 0;
  double discountPercent = 0;
  bool isDltb = false;
  bool isNoMasterCard = false;
  bool baggageOnly = false;
  @override
  void initState() {
    super.initState();

    storedData = _myBox.get('SESSION');

    isFix = storedData['isFix'] ?? false;
    sessionBox = _myBox.get('SESSION');

    // if (sessionBox['isViceVersa']) {
    //   stationkm = 'viceVersaKM';
    // }
    routeid = sessionBox['routeID'];
    torTrip = _myBox.get('torTrip');
    print('sessionBox: $sessionBox');

    currentStationIndex = sessionBox['currentStationIndex'];

    print('torTrip Ticket: $torTrip');
    // _showLoading();
    routes = fetchService.fetchRouteList();

    filipayCardList = fetchService.fetchFilipayCardList();
    coopData = fetchService.fetchCoopData();
    if (coopData['modeOfPayment'] == "cash") {
      isNoMasterCard = true;
    }

    if (coopData['_id'] == '655321a339c1307c069616e9') {
      isDltb = true;
    }
    print('coopData: $coopData');
    print('filipayCardList: $filipayCardList');
    selectedRoute = getRouteById(routes, routeid);
    print('selectedRoute: $selectedRoute');
    // stations = fetchService.fetchStationList();

    stations = getFilteredStations(fetchService.fetchStationList());

    // stations = fetchService.fetchStationList();
    print('ticket stations: $stations');
    if (sessionBox['isViceVersa']) {
      stations = stations.reversed.toList();
    }

    if (sessionBox['selectedDestination'].isNotEmpty) {
      bool isNegative = false;
      double kmrun = 0;
      try {
        kmrun = double.parse(stations[currentStationIndex]['km'].toString()) -
            double.parse(sessionBox['selectedDestination']['km'].toString());
        if (kmrun < 0) {
          isNegative = true;
        }
        print(
            '000zz from: ${double.parse(stations[currentStationIndex]['km'].toString())}');
        print(
            '000zz to: ${double.parse(selectedDestination['km'].toString())}');
        print('000zz kmrun : $kmrun');
      } catch (e) {
        print("000zz error: $e");
      }

      if (!isNegative) {
        if (double.parse(sessionBox['selectedDestination']['km'].toString()) >
            double.parse(stations[currentStationIndex]['km'].toString())) {
          selectedDestination = stations[currentStationIndex + 1];
          print('000zz1 less than to');
        } else {
          selectedDestination = storedData['selectedDestination'];
          print('000zz1 greater than to');
        }
      } else {
        if (double.parse(sessionBox['selectedDestination']['km'].toString()) <
            double.parse(stations[currentStationIndex]['km'].toString())) {
          selectedDestination = stations[currentStationIndex + 1];
          print('000zz2 less than to');
        } else {
          selectedDestination = storedData['selectedDestination'];
          print('000zz2 greater than to');
        }
      }

      toKmPostController.text = "${selectedDestination['km']}";
    } else {
      selectedDestination = stations[currentStationIndex + 1];
      selectedStationName = "${selectedDestination['stationName']}";
      toKmPostController.text = "${selectedDestination['km']}";
    }

    fromKmPostController.text = "${stations[currentStationIndex]['km']}";
    kmRun = formatDouble(0);
    bound = '${selectedRoute[0]['bound']}';
    routeCode = '${selectedRoute[0]['code']}';
    minimumFare = double.parse('${selectedRoute[0]['minimum_fare']}');
    pricePerKm = double.parse(selectedRoute[0]['pricePerKM'].toString());
    firstKM = double.parse(selectedRoute[0]['first_km'].toString());
    discountPercent = int.parse(selectedRoute[0]['discount'].toString()) / 100;
    print('routeCode: $routeCode');
    if (sessionBox['isViceVersa']) {
      route =
          '${selectedRoute[0]['destination']} - ${selectedRoute[0]['origin']}';
    } else {
      route =
          '${selectedRoute[0]['origin']} - ${selectedRoute[0]['destination']}';
    }

    // if (isFix) {
    if (storedData['selectedDestination'].isNotEmpty) {
      // selectedDestination = storedData['selectedDestination'];
      rowNo = int.parse(storedData['selectedDestination']['rowNo'].toString());

      double stationKM = (double.parse(
                  (selectedDestination[stationkm] ?? 0.0).toString()) -
              double.parse(
                  (stations[currentStationIndex][stationkm] ?? 0.0).toString()))
          .abs();
      double baggageprice = 0.00;
      if (baggagePrice.text != '') {
        baggageprice = double.parse(baggagePrice.text);
      }
      setState(() {
        print('currentstation km: ${stations[currentStationIndex][stationkm]}');
        selectedStationID = selectedDestination['_id'];

        // storedData['selectedDestination'] = selectedDestination;

        toKM = double.parse(toKmPostController.text);

        selectedStationName = selectedDestination['stationName'];
        print('selectedStationName: $selectedStationName');

        // price = (pricePerKM * stationKM);
        if (fetchService.getIsNumeric()) {
          price = double.parse(selectedDestination['amount'].toString());
        } else {
          if (stationKM <= firstKM) {
            // If the total distance is 4 km or less, the cost is fixed.
            price = minimumFare;
          } else {
            // If the total distance is more than 4 km, calculate the cost.
            // double initialCost =
            //     pricePerKM; // Cost for the first 4 km
            // double additionalKM = stationKM -
            //     firstkm; // Additional kilometers beyond 4 km
            // double additionalCost = (additionalKM *
            //         pricePerKM) /
            //     firstkm; // Cost for additional kilometers

            if (coopData['coopType'] != "Bus") {
              price = minimumFare + ((stationKM - firstKM) * pricePerKm);
            } else {
              price = stationKM * pricePerKm;
            }
          }
        }

        print('passenger Type: $passengerType');
        print('discount: $discount');

        if (isDiscounted) {
          discount = price * discountPercent;
        }
        if (passengerType != '') {
          subtotal = (price - discount + baggageprice) * quantity;
          if (coopData['coopType'] == "Jeepney") {
            subtotal =
                fetchService.roundToNearestQuarter(subtotal, minimumFare);
          }
          editAmountController.text = fetchservice
              .roundToNearestQuarter(subtotal, minimumFare)
              .toStringAsFixed(2);
        }

        kmRun = formatDouble(stationKM);
      });
      print('selectedDestination: $selectedDestination');
    }
    // }
    findNearestStation(stations, double.parse(toKmPostController.text));
  }

  String findNearestStation(
      List<Map<String, dynamic>> stations, double targetKm) {
    if (stations.isEmpty) {
      return ''; // Handle the case where the list is empty
    }
    setState(() {
      stationNames = [];
    });
    for (var station in stations) {
      double km = station['km']?.toDouble() ?? 0.0;

      if (km == targetKm) {
        // String stationName = station['stationName']?.toString() ?? '';

        setState(() {
          stationNames.add(station);
        });
      }
    }
    print('stationNames: $stationNames');

    setState(() {
      // stationNames = stations.map((station) {
      //   return station['stationName']?.toString() ??
      //       ''; // Convert to string, handle null
      // }).toList();
      stationNames = stations;
      selectedStationName = null;
    });
    return 'NO STATIONS'; // No stations found with the target km
  }

  double milesPrice(double fare) {
    try {
      double milesPrice = 0.0;
      String numberString = fare.toString();

      // Find the index of the decimal point
      int decimalIndex = numberString.indexOf('.');
      double pricePerMiles = pricePerKm / 100;
      // If the decimal point is found, extract the decimal part
      if (decimalIndex != -1 && decimalIndex < numberString.length - 1) {
        String decimalPart = numberString.substring(decimalIndex + 1);

        // Remove trailing zeros
        decimalPart = decimalPart.replaceAll(RegExp(r'0*$'), '');

        milesPrice = pricePerMiles * double.parse(decimalPart);
      }
      return milesPrice;
    } catch (e) {
      return 0.0;
    }
  }

  double succeedingPrice(double succeedingKM) {
    print("succeedingPrice km: ${succeedingKM.toStringAsFixed(2)}");
    int convertDecimalToInteger(double number) {
      int wholePart = number.toInt(); // Get the whole part of the number
      int decimalPart =
          ((number % 1) * 100).round(); // Convert decimal part to integer

      // Concatenate the whole and decimal parts
      int result = int.parse('$wholePart$decimalPart');
      return result;
    }

    try {
      double succeedingPrice = 0.0;
      succeedingPrice =
          convertDecimalToInteger(succeedingKM) * (pricePerKm / 100);
      return succeedingPrice;
    } catch (e) {
      return 0.0;
    }
  }

  void _verificationCard() async {
    if (!isNfcScanOn) {
      return;
    }
    try {
      final result = await backend.startNFCReader();
      if (result != null) {
        final isCardExistingResult = isCardExisting.isCardExisting(result);
        if (isCardExistingResult != null && isCardExistingResult.isNotEmpty) {
          print('isCardExistingResult: $isCardExistingResult');
          String emptype = isCardExistingResult['designation'];
          if (emptype.toLowerCase().contains("conductor") ||
              emptype.toLowerCase().contains("inspector")) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));
          }
        }
      }
    } catch (e) {}
  }

  void _startNFCReader(String typeCard) async {
    String? result;
    bool isCardIDExisting = false;
    List<Map<String, dynamic>> cardList = [];
    List<Map<String, dynamic>> cardData = [];
    String modeOfPayment = coopData['modeOfPayment'];

    if ((!isNoMasterCard &&
            (typeCard == "regular" ||
                typeCard == "discounted" ||
                typeCard == "mastercard")) ||
        isNoMasterCard && (typeCard == "regular" || typeCard == "discounted")) {
      print('with mastercard $typeCard');
      if (!isNfcScanOn) {
        return;
      }
      result = await backend.startNFCReader();
      // try {

      if (typeCard == 'discounted' || typeCard == 'regular') {
        cardList = fetchService.fetchFilipayCardList();
        // cardList =
        //     cardList.where((station) => station['cardType'] == typeCard).toList();
      } else if (typeCard == 'mastercard') {
        cardList = fetchService.fetchMasterCardList();
        cardList = cardList
            .where((station) => station['cardType'] == typeCard)
            .toList();
      } else {
        return;
      }
      isCardIDExisting = cardList
          .any((card) => card['cardID'].toString().toUpperCase() == result);
      if (isCardIDExisting) {
        print('cardList: $cardList');
        print('Card ID $result exists in the list.');

        cardData = cardList.where((card) => card['cardID'] == result).toList();
        print('cardData: $cardData');
      } else {
        print('Card ID $result dit not exists in the list.');
      }

      print('cardList: $cardList');
      modeOfPayment = "cashless";
    } else {
      modeOfPayment = "cash";
      isCardIDExisting = true;
      result = "";
    }

    if (result != null) {
      loadingModal.showProcessing(context);
      double baggage = 0.0;
      double newprice = 0.0;
      if (baggagePrice.text.trim() != '') {
        if (double.parse(baggagePrice.text) > 0) {
          baggage = double.parse(baggagePrice.text);

          if (passengerType == '') {
            setState(() {
              subtotal = baggage;
              editAmountController.text = fetchservice
                  .roundToNearestQuarter(subtotal, minimumFare)
                  .toStringAsFixed(2);
              price = 0;
            });
          }
        }
      }
      if (passengerType == "student" ||
          passengerType == "pwd" ||
          passengerType == "senior") {
        double discount = price * discountPercent;
        newprice = price - discount;
      } else {
        newprice = price;
      }

      if (isCardIDExisting) {
        double previousBalance = 0.0;
        double currentBalance = 0.0;
        bool isOffline = false;
        bool isProceed = false;

        // Map<String, dynamic> isUpdateBalance =
        //     await httprequestServices.updateOnlineCardBalance(
        //         result, subtotal, true, '${cardData[0]['cardType']}', false);

        // if (currentBalance >= 0) {
        // print('isUpdateBalance: $isUpdateBalance');
        // if (isUpdateBalance['messages']['code'] != 0) {
        //   Navigator.of(context).pop();
        // }
        // if (!isOffline) {
        //   previousBalance = double.parse(
        //       isUpdateBalance['response']['previousBalance'].toString());
        //   currentBalance = double.parse(
        //       isUpdateBalance['response']['newBalance'].toString());
        // }

        // bool isupdateCardBalance = await hiveService.updateCardBalance(
        //     cardList, result, currentBalance);
        // if (isupdateCardBalance) {
        setState(() {
          isNfcScanOn = false;
        });
        final myLocation = _myBox.get('myLocation');
        String latitude = '${myLocation?['latitude'] ?? 0.00}';
        String longitude = '${myLocation?['longitude'] ?? 0.00}';
        String timestamp = await timeService.departedTime();
        String deviceid = await deviceInfoService.getDeviceSerialNumber();
        String ticketNo = await generatorService.generateTicketNo();
        String controlNo =
            torTrip[sessionBox['currentTripIndex']]['control_no'];

        String uuid = generatorService.generateUuid();
        print("sendtocketTicket uuid: $uuid");

        // try {
        //   Position position = await Geolocator.getCurrentPosition(
        //           desiredAccuracy: LocationAccuracy.high)
        //       .timeout(const Duration(seconds: 30));
        //   latitude = '${position.latitude}';
        //   longitude = '${position.longitude}';
        // } catch (e) {
        //   latitude = '14.0001';
        //   longitude = '15.0001';
        // }.
        String charPassengerType = '';

        if (passengerType == 'regular') {
          charPassengerType = 'F';
        } else if (passengerType == 'senior') {
          charPassengerType = 'SC';
        } else if (passengerType == 'student') {
          charPassengerType = 'S';
        } else if (passengerType == 'pwd') {
          charPassengerType = 'PWD';
        } else if (baggage > 0 && newprice == 0) {
          charPassengerType = 'B';
        }
        if (coopData['coopType'] == 'Jeepney') {
          subtotal = fetchService.roundToNearestQuarter(subtotal, minimumFare);
          newprice = fetchService.roundToNearestQuarter(newprice, minimumFare);
        }
        Map<String, dynamic> isSendTorTicket =
            await httprequestServices.torTicket({
          "cardId": result,
          "amount": isDltb ? subtotal.round().toInt() : subtotal,
          "cardType":
              '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
          "isNegative": false,
          "coopId": "${coopData['_id']}",
          "modeOfPayment": "$modeOfPayment",
          "items": {
            "UUID": "$uuid",
            "device_id": "$deviceid",
            "control_no": "$controlNo",
            "tor_no": "${torTrip[sessionBox['currentTripIndex']]['tor_no']}",
            "date_of_trip":
                "${torTrip[sessionBox['currentTripIndex']]['date_of_trip']}",
            "bus_no": "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
            "route": "${torTrip[sessionBox['currentTripIndex']]['route']}",
            "route_code":
                "${torTrip[sessionBox['currentTripIndex']]['route_code']}",
            "bound": "$bound",
            "trip_no": sessionBox['currentTripIndex'] + 1,
            "ticket_no": "$ticketNo",
            "ticket_type": "$charPassengerType",
            "ticket_status": "",
            "timestamp": "$timestamp",
            "from_place": "${stations[currentStationIndex]['stationName']}",
            "to_place": "$selectedStationName",
            "from_km": stations[currentStationIndex][stationkm],
            "to_km": toKM,
            "km_run": kmRun,
            "fare": isDltb ? newprice.round() : newprice,
            "subtotal": isDltb ? subtotal.round() : subtotal,
            "discount": isDltb ? discount.round() : discount,
            "additionalFare": 0,
            "additionalFareCardType": "",
            "card_no": "$result",
            "status": "",
            "lat": latitude,
            "long": longitude,
            "created_on": "$timestamp",
            "updated_on": "$timestamp",
            "baggage": isDltb ? baggage.round() : baggage,
            "cardType":
                '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
            "passengerType": "$passengerType",
            "coopId": "${coopData['_id']}",
            "isOffline": isOffline,
            "pax": quantity,
            "reverseNum": sessionBox['reverseNum']
          }
        });
        print('isSendTorTicket: $isSendTorTicket');
        // try {
        if (isSendTorTicket['messages']['code'].toString() == "500") {
          print(
              'error in ticketpage: ${isSendTorTicket['messages']['message']}');
          Navigator.of(context).pop();
          if (typeCard == 'mastercard') {
            if (coopData['modeOfPayment'] == "cashless") {
              await ArtSweetAlert.show(
                  context: context,
                  barrierDismissible: false,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      showCancelBtn: true,
                      cancelButtonText: 'NO',
                      confirmButtonText: 'YES',
                      title: "OFFLINE",
                      onConfirm: () {
                        Navigator.of(context).pop();
                        isOffline = true;
                        isProceed = true;
                        print('addOfflineTicket: $isOffline');
                      },
                      onDeny: () {
                        print('deny');
                        Navigator.of(context).pop();
                        return;
                      },
                      text:
                          "Are you sure you would like to use Offline mode?\nNote: It may negative your balance card."));
            } else {
              isOffline = true;
              isProceed = true;
            }
          } else {
            ArtSweetAlert.show(
                context: context,
                barrierDismissible: false,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.danger,
                    title: "OFFLINE",
                    text: "FILIPAY CARD IS NOT AVAILABLE IN OFFLINE MODE"));
          }
        } else if (isSendTorTicket['messages']['code'].toString() == "1") {
          Navigator.of(context).pop();
          ArtSweetAlert.show(
              context: context,
              barrierDismissible: false,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "ERROR",
                  text:
                      "${isSendTorTicket['messages']['message'].toString().toUpperCase()}"));
          return;
        }
        // } catch (e) {
        //   print(e);
        //   exit(0);
        //   // ArtSweetAlert.show(
        //   //     context: context,
        //   //     barrierDismissible: false,
        //   //     artDialogArgs: ArtDialogArgs(
        //   //         type: ArtSweetAlertType.danger,
        //   //         title: "ERROR",
        //   //         text: "SOMETHING WENT WRONG."));
        //   // return;
        //   // Navigator.of(context).pop();
        //   // bool isConfirmed = await ArtSweetAlert.show(
        //   //     context: context,
        //   //     barrierDismissible: false,
        //   //     artDialogArgs: ArtDialogArgs(
        //   //         type: ArtSweetAlertType.danger,
        //   //         showCancelBtn: true,
        //   //         cancelButtonText: 'NO',
        //   //         confirmButtonText: 'YES',
        //   //         title: "OFFLINE",
        //   //         text:
        //   //             "Are you sure you would like to use Offline mode?\nNote: It may negative your balance card."));
        //   // if (isConfirmed) {
        //   //   // User clicked YES
        //   //   isOffline = true;
        //   // } else {
        //   //   return;
        //   // }
        // }

        print(
            'charPassengerType: $charPassengerType, passengerType:   $passengerType');
        print('charPassengerType  controlNo;  $controlNo');
        double newBalance = 0;
        Map<String, dynamic> itemBody = {
          "UUID": "$uuid",
          "device_id": "$deviceid",
          "control_no": "$controlNo",
          "tor_no": "${torTrip[sessionBox['currentTripIndex']]['tor_no']}",
          "date_of_trip":
              "${torTrip[sessionBox['currentTripIndex']]['date_of_trip']}",
          "bus_no": "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
          "route": "${torTrip[sessionBox['currentTripIndex']]['route']}",
          "route_code":
              "${torTrip[sessionBox['currentTripIndex']]['route_code']}",
          "bound": "$bound",
          "trip_no": sessionBox['currentTripIndex'] + 1,
          "ticket_no": "$ticketNo",
          "ticket_type": "$charPassengerType",
          "ticket_status": "",
          "timestamp": "$timestamp",
          "from_place": "${stations[currentStationIndex]['stationName']}",
          "to_place": "$selectedStationName",
          "from_km": stations[currentStationIndex][stationkm],
          "to_km": toKM,
          "km_run": kmRun,
          "fare": isDltb ? newprice.round() : newprice,
          "subtotal": isDltb ? subtotal.round().toInt() : subtotal,
          "discount": isDltb ? discount.round().toInt() : discount,
          "additionalFare": 0,
          "additionalFareCardType": "",
          "card_no": "$result",
          "status": "",
          "lat": latitude,
          "long": longitude,
          "created_on": "$timestamp",
          "updated_on": "$timestamp",
          "baggage": isDltb ? baggage.round() : baggage,
          "cardType":
              '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
          "passengerType": "$passengerType",
          "coopId": "${coopData['_id']}",
          "rowNo": rowNo,
          "pax": quantity,
          "reverseNum": sessionBox['reverseNum']
        };
        if (isSendTorTicket['messages']['code'].toString() == "0") {
          try {
            newBalance = double.parse(
                isSendTorTicket['response']['newBalance'].toString());
          } catch (e) {
            print(e);
          }

          print(
              'success in ticketpage: ${isSendTorTicket['messages']['message']}');
          isProceed = true;
        }

        if (!isProceed) {
          return;
        }
        bool isAddedTicket = await hiveService.addTicket(itemBody);

        if (isAddedTicket) {
          storedData['isFix'] = isFix;
          if (isFix) {
            storedData['selectedDestination'] = selectedDestination;

            _myBox.put('SESSION', storedData);

            print("new selectedDestination: $selectedDestination");
          }
          // int baggagepriceoffline = 0;
          // if (baggagePrice.text.trim().isNotEmpty || baggagePrice.text != '') {
          //   baggagepriceoffline = int.parse(baggagePrice.text);
          // }
          if (isOffline) {
            bool isAddOfflineTicket = await hiveService.addOfflineTicket({
              "cardId": result,
              "amount": isDltb ? subtotal.round().toInt() : subtotal,
              "cardType":
                  '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
              "isNegative": false,
              "coopId": "${coopData['_id']}",
              "modeOfPayment": "$modeOfPayment",
              "items": {
                "UUID": "$uuid",
                "device_id": "$deviceid",
                "control_no": "$controlNo",
                "tor_no":
                    "${torTrip[sessionBox['currentTripIndex']]['tor_no']}",
                "date_of_trip":
                    "${torTrip[sessionBox['currentTripIndex']]['date_of_trip']}",
                "bus_no":
                    "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
                "route": "${torTrip[sessionBox['currentTripIndex']]['route']}",
                "route_code":
                    "${torTrip[sessionBox['currentTripIndex']]['route_code']}",
                "bound": "$bound",
                "trip_no": sessionBox['currentTripIndex'] + 1,
                "ticket_no": "$ticketNo",
                "ticket_type": "$charPassengerType",
                "ticket_status": "",
                "timestamp": "$timestamp",
                "from_place": "${stations[currentStationIndex]['stationName']}",
                "to_place": "$selectedStationName",
                "from_km": stations[currentStationIndex][stationkm],
                "to_km": toKM,
                "km_run": kmRun,
                "fare": isDltb ? newprice.round() : newprice,
                "subtotal": isDltb ? subtotal.round() : subtotal,
                "discount": isDltb ? discount.round() : discount,
                "additionalFare": 0,
                "additionalFareCardType": "",
                "card_no": "$result",
                "status": "",
                "lat": latitude,
                "long": longitude,
                "created_on": "$timestamp",
                "updated_on": "$timestamp",
                // "previous_balance": previousBalance,
                // "current_balance": currentBalance,
                "baggage": isDltb ? baggage.round() : baggage,
                "cardType":
                    '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
                "passengerType": "$passengerType",
                "coopId": "${coopData['_id']}",
                "rowNo": rowNo,
                "pax": quantity,
                "reverseNum": sessionBox['reverseNum']
              }
            });
          }
          if (passengerType != '' && !baggageOnly) {
            printService.printTicket(
              ticketNo,
              typeCard,
              coopData['coopType'] == "Jeepney"
                  ? fetchservice.roundToNearestQuarter(price, minimumFare)
                  : price,
              coopData['coopType'] == "Jeepney"
                  ? fetchService.roundToNearestQuarter(
                      (fetchservice.roundToNearestQuarter(price, minimumFare) -
                              discount) *
                          quantity,
                      minimumFare)
                  : ((price - discount) * quantity).round().toDouble(),
              double.parse(kmRun),
              '${stations[currentStationIndex]['stationName']}',
              '$selectedStationName',
              passengerType,
              isDiscounted,
              coopData['coopType'] == "Jeepney"
                  ? "${torTrip[sessionBox['currentTripIndex']]['bus_no']}:${torTrip[sessionBox['currentTripIndex']]['plate_number']} "
                  : "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
              stations[currentStationIndex][stationkm].toString(),
              toKM.toString(),
              "${torTrip[sessionBox['currentTripIndex']]['route']}",
              discountPercent,
              quantity,
              newBalance,
            );
          }
          Navigator.of(context).pop();
          ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      title: "SUCCESS",
                      text: "THANK YOU"))
              .then((alertResult) {
            double baggageprice = 0;
            try {
              baggageprice = double.parse(baggagePrice.text);
            } catch (e) {
              print(e);
            }
            if (baggageprice > 0) {
              ArtSweetAlert.show(
                      context: context,
                      barrierDismissible: false,
                      artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.info,
                          title: "BAGGAGE RECEIPT",
                          text: "CLICK OK TO PRINT"))
                  .then((alertResult) {
                printService.printBaggage(
                    ticketNo,
                    typeCard,
                    double.parse(baggagePrice.text),
                    double.parse(kmRun),
                    '${stations[currentStationIndex]['stationName']}',
                    '$selectedStationName',
                    coopData['coopType'] == "Jeepney"
                        ? "${torTrip[sessionBox['currentTripIndex']]['bus_no']}:${torTrip[sessionBox['currentTripIndex']]['plate_number']} "
                        : "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
                    stations[currentStationIndex][stationkm].toString(),
                    toKM.toString(),
                    "${torTrip[sessionBox['currentTripIndex']]['route']}");
                // setState(() {
                //   discount = 0.0;

                //   passengerType = '';
                //   typeofCards = '';
                //   kmRun = '0';
                //   baggagePrice.text = '';
                //   isNfcScanOn = false;
                //   price = 0;
                //   subtotal = 0;
                //   currentStationIndex = 0;
                //   routeCode = '';
                //   toKM = 0;
                // });
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => TicketingPage()));
              });
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TicketingPage()));
            }
            // setState(() {
            //   discount = 0.0;

            //   passengerType = '';
            //   typeofCards = '';
            //   kmRun = '0';
            //   baggagePrice.text = '';
            //   isNfcScanOn = false;
            //   price = 0;
            //   subtotal = 0;
            //   currentStationIndex = 0;
            //   routeCode = '';
            //   toKM = 0;
            // });
            // Navigator.of(context).pop();
            // Navigator.of(context).pop();
          });
        } else {
          setState(() {
            isNfcScanOn = true;
          });
          Navigator.of(context).pop();
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "ERROR",
                  text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN"));
        }

        // } else {
        //   Navigator.of(context).pop();
        //   ArtSweetAlert.show(
        //       context: context,
        //       artDialogArgs: ArtDialogArgs(
        //           type: ArtSweetAlertType.danger,
        //           title: "SOMETHING WENT WRONG",
        //           text: "PLEASE TRY AGAIN"));
        // }
        // } else {
        //   Navigator.of(context).pop();
        //   ArtSweetAlert.show(
        //           context: context,
        //           artDialogArgs: ArtDialogArgs(
        //               type: ArtSweetAlertType.danger,
        //               title: "INSUFFICIENT BALANCE",
        //               text: "PLEASE RELOAD YOUR CARD"))
        //       .then((value) {
        //     setState(() {
        //       _startNFCReader(typeCard);
        //     });
        //   });

        // }

        return;
      } else {
        Navigator.of(context).pop();
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "INVALID",
                text: "PLEASE TAP VALID CARD"));
        print('Card ID $result does not exist in the list.');
      }
    }
    _startNFCReader(typeCard);
    return;
    // } catch (e) {
    //   print(e);
    //   Navigator.of(context).pop();
    //   ArtSweetAlert.show(
    //       context: context,
    //       artDialogArgs: ArtDialogArgs(
    //           type: ArtSweetAlertType.warning,
    //           title: "ERROR",
    //           text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN"));
    // }
    // _startNFCReaderDashboard();
  }

  List<Map<String, dynamic>> getRouteById(
      List<Map<String, dynamic>> routeList, String id) {
    return routeList.where((route) => route['_id'].toString() == id).toList();
  }

  List<Map<String, dynamic>> getFilteredStations(
      List<Map<String, dynamic>> stationList) {
    // List<Map<String, dynamic>> filteredStations = stationList
    //     .where((station) => station['routeId'].toString() == routeid)
    //     .toList();

    // // // Sort the filtered stations based on the 'km' field
    // filteredStations.sort((a, b) {
    //   int kmA = a['km'] ?? 0;
    //   int kmB = b['km'] ?? 0;
    //   return kmA.compareTo(kmB);
    // });
    List<Map<String, dynamic>> filteredStations = stationList
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

  String formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString(); // Display as an integer
    } else {
      return value
          .toStringAsFixed(1); // Display as a double with 1 decimal place
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool checkifValid() {
    double baggageprice = 0.00;


if(coopData['coopType']=="Bus"){
 if (selectedStationName == null || selectedStationName == "") {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "MISSING DESTINATION",
              text: "PLEASE SELECT FIRST YOUR DESTINATION"));
      return false;
    }

    if (selectedStationName == "NO STATIONS") {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "NOT FOUND",
              text:
                  "There is no corresponding station identified in the kilometer post."));
      return false;
    }

}
   
    if (baggagePrice.text != '') {
      try {
        baggageprice = double.parse(baggagePrice.text);
        if (baggageprice >
            double.parse(coopData['maximumBaggage'].toString())) {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "EXCEEDED",
                  text: "REACHED MAXIMUM BAGGAGE"));
          return false;
        }
      } catch (e) {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "INVALID",
                text: "INVALID BAGGAGE AMOUNT"));
        return false;
      }
    }
    if (subtotal > double.parse(coopData['maximumFare'].toString())) {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "EXCEEDED",
              text: "REACHED MAXIMUM FARE"));
      return false;
    }
    print('subtotal: $subtotal');
    if ((baggageOnly && baggageprice <= 0) ||
        (!baggageOnly && passengerType == "")) {
      // if (coopData['coopType'] != "Bus") {
      setState(() {
        ismissingPassengerType = true;
      });
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "INCOMPLETE",
              text: baggageOnly
                  ? "INPUT BAGGAGE AMOUNT"
                  : (coopData['coopType'] == "Bus"
                      ? "CHOOSE TICKET TYPE FIRST"
                      : "CHOOSE PASSENGER TYPE FIRST")));
      return false;
      // } else {
      // if (baggageprice <= 0) {
      //   ArtSweetAlert.show(
      //       context: context,
      //       artDialogArgs: ArtDialogArgs(
      //           type: ArtSweetAlertType.danger,
      //           title: "INCOMPLETE",
      //           text: "INPUT BAGGAGE AMOUNT"));
      //   return false;
      // } else {
      //   return true;
      // }
      // }
    } else {
      setState(() {
        ismissingPassengerType = false;
      });
      if (fetchService.getIsNumeric()) {
        if (double.parse(editAmountController.text) <= 0 && baggageprice <= 0) {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INCOMPLETE",
                  text: "AMOUNT 0 IS NOT VALID"));
          return false;
        } else {
          return true;
        }
      } else {
        if (subtotal <= 0 && baggageprice <= 0) {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INCOMPLETE",
                  text: "AMOUNT 0 IS NOT VALID"));
          return false;
        }
        if (subtotal > double.parse(coopData['maximumFare'].toString())) {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "EXCEEDED",
                  text: "REACHED MAXIMUM "));
          return false;
        }
        if (selectedStationName == '') {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INCOMPLETE",
                  text: "PLEASE CHOOSE STATION"));

          return false;
        } else {
          return true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();

    print('passenger type: $passengerType');
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // logic
      },
      child: Scaffold(
        body: SafeArea(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                  opacity: 0.5, child: Image.asset("assets/citybg.png")),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  appbar(),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'TICKET ISSUANCE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: coopData['coopType'] == "Bus"
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      'ROUTE',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '$route',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'BOUND',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      '$bound',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                'FROM',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  child: Text(
                                                    'KM',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffc0c1be),
                                                          border: Border(
                                                            top: BorderSide(
                                                              color: Colors
                                                                  .white, // Border color
                                                              width:
                                                                  2.0, // Border width
                                                            ),
                                                            left: BorderSide(
                                                              color: Colors
                                                                  .white, // Border color
                                                              width:
                                                                  2.0, // Border width
                                                            ),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Icon(
                                                              Icons.cancel,
                                                              color: AppColors
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Expanded(
                                                          child: Container(
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .white),
                                                        child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  '${stations[currentStationIndex]['stationName']}'),
                                                            )),
                                                      )),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (isFix) return;
                                                          bool isproceed =
                                                              false;
                                                          if ((currentStationIndex +
                                                                  1) >=
                                                              stations.length)
                                                            return;
                                                          await ArtSweetAlert
                                                              .show(
                                                                  context:
                                                                      context,
                                                                  artDialogArgs:
                                                                      ArtDialogArgs(
                                                                    type: ArtSweetAlertType
                                                                        .warning,
                                                                    cancelButtonText:
                                                                        'NO',
                                                                    showCancelBtn:
                                                                        true,
                                                                    confirmButtonText:
                                                                        'YES',
                                                                    title:
                                                                        "NEXT STATION",
                                                                    text:
                                                                        "Are you sure you want to go to the next station?",
                                                                    onConfirm:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      isproceed =
                                                                          true;
                                                                    },
                                                                  ));

                                                          if (isFix) return;
                                                          if (!isproceed)
                                                            return;

                                                          final storedData =
                                                              _myBox.get(
                                                                  'SESSION');
                                                          // print('Data in Hive box: $storedData');

                                                          setState(() {
                                                            currentStationIndex++;
                                                            fromKmPostController
                                                                    .text =
                                                                "${stations[currentStationIndex]['km']}";

                                                            if (double.parse(
                                                                    selectedDestination[
                                                                            'rowNo']
                                                                        .toString()) <=
                                                                double.parse(stations[
                                                                            currentStationIndex]
                                                                        [
                                                                        'rowNo']
                                                                    .toString())) {
                                                              selectedDestination =
                                                                  stations[
                                                                      currentStationIndex +
                                                                          1];

                                                              toKmPostController
                                                                      .text =
                                                                  "${selectedDestination['km']}";
                                                            }
                                                          });
                                                          if (stations.length >
                                                              currentStationIndex) {
                                                            print(stations[
                                                                    currentStationIndex]
                                                                [
                                                                'stationName']);
                                                            storedData[
                                                                    'currentStationIndex'] =
                                                                currentStationIndex;

                                                            print(
                                                                "currentStationIndex: $currentStationIndex");
                                                            _myBox.put(
                                                                'SESSION',
                                                                storedData);
                                                            print(
                                                                'Data in Hive box: $storedData');
                                                            _updateAmount(
                                                                isDiscounted);

                                                            // if (selectedDestination
                                                            //     .isNotEmpty) {
                                                            //   // selectedDestination =
                                                            //   //     storedData['selectedDestination'];

                                                            //   double stationKM = (double.parse(
                                                            //               selectedDestination[stationkm]
                                                            //                   .toString()) -
                                                            //           double.parse(stations[currentStationIndex]
                                                            //                   [
                                                            //                   stationkm]
                                                            //               .toString()))
                                                            //       .abs();
                                                            //   double
                                                            //       baggageprice =
                                                            //       0.00;
                                                            //   if (baggagePrice
                                                            //           .text !=
                                                            //       '') {
                                                            //     baggageprice =
                                                            //         double.parse(
                                                            //             baggagePrice
                                                            //                 .text);
                                                            //   }

                                                            //   setState(() {
                                                            //     print(
                                                            //         'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                                            //     selectedStationID =
                                                            //         selectedDestination[
                                                            //             '_id'];

                                                            //     storedData[
                                                            //             'selectedDestination'] =
                                                            //         selectedDestination;

                                                            //     toKM = double.parse(
                                                            //         selectedDestination[
                                                            //                 stationkm]
                                                            //             .toString());

                                                            //     selectedStationName =
                                                            //         selectedDestination[
                                                            //             'stationName'];
                                                            //     print(
                                                            //         'selectedStationName: $selectedStationName');
                                                            //     // price = (pricePerKM * stationKM);
                                                            //     if (fetchService
                                                            //         .getIsNumeric()) {
                                                            //       price = double
                                                            //           .parse(coopData[
                                                            //                   'amount']
                                                            //               .toString());
                                                            //     } else {
                                                            //       if (stationKM <=
                                                            //           firstKM) {
                                                            //         // If the total distance is 4 km or less, the cost is fixed.
                                                            //         price =
                                                            //             minimumFare;
                                                            //       } else {
                                                            //         // If the total distance is more than 4 km, calculate the cost.
                                                            //         // double initialCost =
                                                            //         //     pricePerKM; // Cost for the first 4 km
                                                            //         // double additionalKM = stationKM -
                                                            //         //     firstkm; // Additional kilometers beyond 4 km
                                                            //         // double additionalCost = (additionalKM *
                                                            //         //         pricePerKM) /
                                                            //         //     firstkm; // Cost for additional kilometers

                                                            //         if (coopData[
                                                            //                 'coopType'] !=
                                                            //             "Bus") {
                                                            //           price = minimumFare +
                                                            //               ((stationKM - firstKM) *
                                                            //                   pricePerKm);
                                                            //         } else {
                                                            //           price = stationKM *
                                                            //               pricePerKm;
                                                            //         }
                                                            //       }
                                                            //     }
                                                            //     print(
                                                            //         'passenger Type: $passengerType');
                                                            //     print(
                                                            //         'discount: $discount');

                                                            //     if (isDiscounted) {
                                                            //       discount = price *
                                                            //           discountPercent;
                                                            //     }
                                                            //     subtotal = (price -
                                                            //             discount +
                                                            //             baggageprice) *
                                                            //         quantity;
                                                            //     editAmountController
                                                            //             .text =
                                                            //         fetchservice
                                                            //             .roundToNearestQuarter(
                                                            //                 subtotal,
                                                            //                 minimumFare)
                                                            //             .toStringAsFixed(
                                                            //                 2);
                                                            //     if (coopData[
                                                            //             'coopType'] ==
                                                            //         "Jeepney") {
                                                            //       subtotal = fetchService
                                                            //           .roundToNearestQuarter(
                                                            //               subtotal,
                                                            //               minimumFare);
                                                            //     }

                                                            //     kmRun =
                                                            //         formatDouble(
                                                            //             stationKM);
                                                            //   });
                                                            //   print(
                                                            //       'selectedDestination: $selectedDestination');
                                                            // }
                                                          } else {
                                                            setState(() {
                                                              currentStationIndex--;
                                                            });
                                                          }
                                                          // print(stations.length);
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xffc0c1be),
                                                            border: Border(
                                                              top: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                              left: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              Icons
                                                                  .chevron_right,
                                                              color: AppColors
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  child: TextField(
                                                    controller:
                                                        fromKmPostController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    enabled: false,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff5f6062)),
                                                    decoration: InputDecoration(
                                                        // contentPadding:
                                                        //     EdgeInsets.only(bottom: 10),
                                                        hintText:
                                                            'Enter KM Post',
                                                        hintStyle: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                        )),
                                                    onChanged: (value) async {
                                                      double kmrun = 0;
                                                      bool isNegative = false;
                                                      bool isproceed = false;

                                                      try {
                                                        kmrun = double.parse(
                                                                value) -
                                                            double.parse(
                                                                stations[currentStationIndex]
                                                                        ['km']
                                                                    .toString());
                                                        if (kmrun > 0) {
                                                          isNegative = false;
                                                        }
                                                      } catch (e) {
                                                        print(e);

                                                        // dito na ko from
                                                      }
                                                      if (!isNegative) {
                                                        try {
                                                          double fromkmpost =
                                                              double.parse(value
                                                                  .toString());
                                                          if (fromkmpost >
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      ['km']
                                                                  .toString())) {
                                                            setState(() {
                                                              currentStationIndex =
                                                                  sessionBox[
                                                                      'currentStationIndex'];
                                                            });
                                                            return;
                                                          } else {
                                                            int index = stations
                                                                .indexWhere((item) =>
                                                                    double.parse(
                                                                        item['km']
                                                                            .toString()) ==
                                                                    fromkmpost);
                                                            if (index >= 0) {
                                                              setState(() {
                                                                currentStationIndex =
                                                                    index;
                                                                storedData[
                                                                        'currentStationIndex'] =
                                                                    currentStationIndex;
                                                                _myBox.put(
                                                                    "SESSION",
                                                                    storedData);
                                                              });
                                                            }
                                                            print(
                                                                "index: $index");
                                                          }
                                                        } catch (e) {
                                                          print(e);
                                                        }
                                                      } else {
                                                        try {
                                                          double fromkmpost =
                                                              double.parse(value
                                                                  .toString());
                                                          if (fromkmpost <
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      ['km']
                                                                  .toString())) {
                                                            setState(() {
                                                              currentStationIndex =
                                                                  sessionBox[
                                                                      'currentStationIndex'];
                                                            });
                                                            return;
                                                          } else {
                                                            int index = stations
                                                                .indexWhere((item) =>
                                                                    double.parse(
                                                                        item['km']
                                                                            .toString()) ==
                                                                    fromkmpost);
                                                            if (index >= 0) {
                                                              setState(() {
                                                                currentStationIndex =
                                                                    index;
                                                                storedData[
                                                                        'currentStationIndex'] =
                                                                    currentStationIndex;
                                                                _myBox.put(
                                                                    "SESSION",
                                                                    storedData);
                                                              });
                                                            }
                                                            print(
                                                                "index: $index");
                                                          }
                                                        } catch (e) {
                                                          print(e);
                                                        }
                                                      }
                                                    },
                                                  ))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                'TO',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  child: Text(
                                                    'KM',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (isFix) return;
                                                          int index = stations
                                                              .indexWhere((element) =>
                                                                  selectedDestination[
                                                                      '_id'] ==
                                                                  element[
                                                                      '_id']);
                                                          if ((index - 1) < 0) {
                                                            print(
                                                                "selected destination: less than 0");
                                                            return;
                                                          }
                                                          if (double.parse(stations[
                                                                          index -
                                                                              1]
                                                                      ['rowNo']
                                                                  .toString()) <
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      ['rowNo']
                                                                  .toString())) {
                                                            return;
                                                          }

                                                          setState(() {
                                                            selectedDestination =
                                                                stations[
                                                                    index - 1];
                                                            toKmPostController
                                                                    .text =
                                                                "${selectedDestination['km']}";
                                                            selectedStationName =
                                                                selectedDestination[
                                                                    'stationName'];
                                                          });
                                                          _updateAmount(
                                                              isDiscounted);

                                                          print(
                                                              'selected destination: $selectedDestination');
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xffc0c1be),
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            20)),
                                                            border: Border(
                                                              top: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                              left: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                                Icons
                                                                    .chevron_left,
                                                                color: AppColors
                                                                    .primaryColor),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          // width: double.infinity,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton2<
                                                                      String>(
                                                                isExpanded:
                                                                    true,
                                                                hint: FittedBox(
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  child: Text(
                                                                    'Select Station',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                items:
                                                                    stationNames
                                                                        .map<
                                                                            DropdownMenuItem<
                                                                                String>>((item) =>
                                                                            DropdownMenuItem<String>(
                                                                              value: item['stationName'] as String,
                                                                              child: FittedBox(
                                                                                fit: BoxFit.scaleDown,
                                                                                child: Text(
                                                                                  item['stationName'] as String,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                                value:
                                                                    selectedStationName,
                                                                onChanged:
                                                                    (String?
                                                                        value) {
                                                                  if (value !=
                                                                      null) {
                                                                    final selectedStation =
                                                                        stationNames
                                                                            .firstWhere(
                                                                      (station) =>
                                                                          station[
                                                                              'stationName'] ==
                                                                          value,
                                                                      orElse:
                                                                          () =>
                                                                              {},
                                                                    );

                                                                    setState(
                                                                        () {
                                                                      selectedStationName =
                                                                          value;
                                                                      toKmPostController
                                                                              .text =
                                                                          "${selectedStation['km']}";
                                                                      selectedDestination =
                                                                          selectedStation;
                                                                      _updateAmount(
                                                                          isDiscounted);
                                                                    });
                                                                  }
                                                                  // setState(() {
                                                                  //   selectedStationName =
                                                                  //       value ??
                                                                  //           '';

                                                                  // });
                                                                },
                                                                buttonStyleData:
                                                                    const ButtonStyleData(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              16),
                                                                  height: 40,
                                                                  width: 200,
                                                                ),
                                                                dropdownStyleData:
                                                                    const DropdownStyleData(
                                                                  maxHeight:
                                                                      200,
                                                                ),
                                                                menuItemStyleData:
                                                                    const MenuItemStyleData(
                                                                  height: 40,
                                                                ),
                                                                dropdownSearchData:
                                                                    DropdownSearchData(
                                                                  searchController:
                                                                      selectedStationNameController,
                                                                  searchInnerWidgetHeight:
                                                                      50,
                                                                  searchInnerWidget:
                                                                      Container(
                                                                    height: 50,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      top: 8,
                                                                      bottom: 4,
                                                                      right: 8,
                                                                      left: 8,
                                                                    ),
                                                                    child:
                                                                        TextFormField(
                                                                      expands:
                                                                          true,
                                                                      maxLines:
                                                                          null,
                                                                      controller:
                                                                          selectedStationNameController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              8,
                                                                        ),
                                                                        hintText:
                                                                            'Search for an item...',
                                                                        hintStyle:
                                                                            const TextStyle(fontSize: 12),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  searchMatchFn:
                                                                      (item,
                                                                          searchValue) {
                                                                    return item
                                                                        .value
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .contains(
                                                                            searchValue.toUpperCase());
                                                                  },
                                                                ),
                                                                //This to clear the search value when you close the menu
                                                                onMenuStateChange:
                                                                    (isOpen) {
                                                                  if (!isOpen) {
                                                                    selectedStationNameController
                                                                        .clear();
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Expanded(
                                                      //     child: Container(
                                                      //   height: 40,
                                                      //   decoration:
                                                      //       BoxDecoration(
                                                      //           color: Colors
                                                      //               .white),
                                                      //   child: FittedBox(
                                                      //       fit: BoxFit
                                                      //           .scaleDown,
                                                      //       child: Padding(
                                                      //         padding:
                                                      //             const EdgeInsets
                                                      //                 .all(8.0),
                                                      //         child: Text(
                                                      //             '${selectedDestination['stationName']}'),
                                                      //       )),
                                                      // )),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (isFix) return;

                                                          int index = stations
                                                              .indexWhere((element) =>
                                                                  selectedDestination[
                                                                      '_id'] ==
                                                                  element[
                                                                      '_id']);
                                                          if (index < 0) {
                                                            print(
                                                                "selected destination: less than 0");
                                                            return;
                                                          }

                                                          if ((index + 1) >=
                                                              stations.length) {
                                                            print(
                                                                "selected destination: greater than 0");
                                                            return;
                                                          }

                                                          setState(() {
                                                            selectedDestination =
                                                                stations[
                                                                    index + 1];
                                                            toKmPostController
                                                                    .text =
                                                                "${selectedDestination['km']}";
                                                            selectedStationName =
                                                                selectedDestination[
                                                                    'stationName'];
                                                            // kmRun = (double.parse(stations[currentStationIndex]
                                                            //                 [
                                                            //                 'km']
                                                            //             .toString()) -
                                                            //         double.parse(
                                                            //             selectedDestination['km']
                                                            //                 .toString()))
                                                            //     .abs()
                                                            //     .toString();

                                                            // double stationKM = (double.parse(stations[currentStationIndex]
                                                            //                 [
                                                            //                 'km']
                                                            //             .toString()) -
                                                            //         double.parse(
                                                            //             selectedDestination['km']
                                                            //                 .toString()))
                                                            //     .abs();

                                                            // try {
                                                            //   if (stationKM <=
                                                            //       firstKM) {
                                                            //     // If the total distance is 4 km or less, the cost is fixed.
                                                            //     price =
                                                            //         minimumFare;
                                                            //   } else {
                                                            //     // If the total distance is more than 4 km, calculate the cost.
                                                            //     // double initialCost =
                                                            //     //     pricePerKM; // Cost for the first 4 km
                                                            //     // double additionalKM = stationKM -
                                                            //     //     firstkm; // Additional kilometers beyond 4 km
                                                            //     // double additionalCost = (additionalKM *
                                                            //     //         pricePerKM) /
                                                            //     //     firstkm; // Cost for additional kilometers

                                                            //     if (coopData[
                                                            //             'coopType'] !=
                                                            //         "Bus") {
                                                            //       double
                                                            //           succeedingprice =
                                                            //           succeedingPrice(
                                                            //               stationKM -
                                                            //                   firstKM);
                                                            //       print(
                                                            //           "succeedingprice: $succeedingprice");
                                                            //       price = minimumFare +
                                                            //           ((stationKM -
                                                            //                   firstKM) *
                                                            //               pricePerKm);
                                                            //       // price = minimumFare +
                                                            //       //     succeedingprice;
                                                            //     } else {
                                                            //       price = stationKM *
                                                            //           pricePerKm;
                                                            //     }
                                                            //   }
                                                            // } catch (e) {
                                                            //   print(e);
                                                            // }
                                                          });
                                                          _updateAmount(
                                                              isDiscounted);
                                                          print(
                                                              'selected destination: $selectedDestination');
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xffc0c1be),
                                                            border: Border(
                                                              top: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                              left: BorderSide(
                                                                color: Colors
                                                                    .white, // Border color
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              Icons
                                                                  .chevron_right,
                                                              color: AppColors
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  height: 40,
                                                  child: TextField(
                                                    controller:
                                                        toKmPostController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    enabled: !isFix,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff5f6062)),
                                                    decoration: InputDecoration(
                                                        // contentPadding:
                                                        //     EdgeInsets.only(bottom: 10),
                                                        hintText:
                                                            'Enter KM Post',
                                                        hintStyle: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            20)))),
                                                    onChanged: (value) {
                                                      double kmrun = 0;
                                                      bool isNegative = false;

                                                      try {
                                                        kmrun = double.parse(
                                                                value) -
                                                            double.parse(
                                                                stations[currentStationIndex]
                                                                        ['km']
                                                                    .toString());
                                                        if (kmrun < 0) {
                                                          isNegative = true;
                                                        }
                                                        findNearestStation(
                                                            stations,
                                                            double.parse(
                                                                value));
                                                      } catch (e) {
                                                        print(e);
                                                        setState(() {
                                                          stationNames = [];
                                                          selectedStationName =
                                                              null;
                                                        });
                                                        // dito na ko to
                                                      }
                                                      try {
                                                        double tokmpost =
                                                            double.parse(value
                                                                .toString());
                                                        if (isNegative) {
                                                          if (tokmpost >
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      ['km']
                                                                  .toString())) {
                                                            setState(() {
                                                              selectedDestination =
                                                                  sessionBox[
                                                                      'selectedDestination'];
                                                              selectedStationName =
                                                                  selectedDestination[
                                                                      'stationName'];
                                                              toKM = double.parse(
                                                                  selectedDestination[
                                                                          'km']
                                                                      .toString());
                                                            });
                                                            _updateAmount(
                                                                isDiscounted);
                                                            return;
                                                          } else {
                                                            int index = stations
                                                                .indexWhere((item) =>
                                                                    double.parse(
                                                                        item['km']
                                                                            .toString()) ==
                                                                    tokmpost);
                                                            if (index >= 0) {
                                                              setState(() {
                                                                selectedDestination =
                                                                    stations[
                                                                        index];
                                                                selectedStationName =
                                                                    selectedDestination[
                                                                        'stationName'];
                                                                toKM = double.parse(
                                                                    selectedDestination[
                                                                            'km']
                                                                        .toString());
                                                              });
                                                            }
                                                            print(
                                                                "index: $index");
                                                          }
                                                        } else {
                                                          if (tokmpost <
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      ['km']
                                                                  .toString())) {
                                                            setState(() {
                                                              selectedDestination =
                                                                  sessionBox[
                                                                      'selectedDestination'];
                                                              selectedStationName =
                                                                  selectedDestination[
                                                                      'stationName'];
                                                              toKM = double.parse(
                                                                  selectedDestination[
                                                                          'km']
                                                                      .toString());
                                                            });
                                                            _updateAmount(
                                                                isDiscounted);
                                                            return;
                                                          } else {
                                                            int index = stations
                                                                .indexWhere((item) =>
                                                                    double.parse(
                                                                        item['km']
                                                                            .toString()) ==
                                                                    tokmpost);
                                                            if (index >= 0) {
                                                              setState(() {
                                                                selectedDestination =
                                                                    stations[
                                                                        index];
                                                                selectedStationName =
                                                                    selectedDestination[
                                                                        'stationName'];
                                                                toKM = double.parse(
                                                                    selectedDestination[
                                                                            'km']
                                                                        .toString());
                                                              });
                                                            }
                                                            print(
                                                                "tokm change index: $index");
                                                          }
                                                        }
                                                        _updateAmount(
                                                            isDiscounted);
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                      print(
                                                          'tokm change: selectedstation: $selectedStationName');
                                                    },
                                                  ))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  'KM RUN',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                                Text(
                                                  'FIX',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isFix = !isFix;
                                                    });
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  width: 2)),
                                                          child: isFix
                                                              ? Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .black)
                                                              : SizedBox(
                                                                  width: 20,
                                                                  height: 20),
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                              ],
                                            ),
                                          )),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20))),
                                            child:
                                                Center(child: Text('$kmRun')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'TICKET TYPE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Text(
                                                  'Passenger Type',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                                items: passengerTypeList
                                                    .map((item) =>
                                                        DropdownMenuItem(
                                                          value: item,
                                                          child: Text(
                                                            item,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                value:
                                                    passengerType == "regular"
                                                        ? "FULL FARE"
                                                        : passengerType
                                                            .toUpperCase(),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    switch (value) {
                                                      case 'FULL FARE':
                                                        passengerType =
                                                            "regular";
                                                        isDiscounted = false;
                                                        _updateAmount(false);
                                                        break;
                                                      case 'SENIOR':
                                                        passengerType =
                                                            "senior";
                                                        isDiscounted = true;
                                                        _updateAmount(true);
                                                        break;
                                                      case 'STUDENT':
                                                        passengerType =
                                                            "student";
                                                        isDiscounted = true;
                                                        _updateAmount(true);
                                                        break;

                                                      case 'PWD':
                                                        passengerType = "pwd";
                                                        isDiscounted = true;
                                                        _updateAmount(true);
                                                        break;

                                                      case 'BAGGAGE':
                                                        setState(() {
                                                          baggageOnly = true;
                                                          price = 0;
                                                          discount = 0;

                                                          try {
                                                            subtotal =
                                                                double.parse(
                                                                    baggagePrice
                                                                        .text);
                                                          } catch (e) {
                                                            subtotal = 0;
                                                            baggagePrice.text =
                                                                "0";
                                                          }
                                                        });

                                                        break;

                                                      default:
                                                        passengerType =
                                                            value ?? "";
                                                        break;
                                                    }
                                                    // passengerType = value ?? '';
                                                    print(
                                                        'passengerTypezz: $passengerType');
                                                  });
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                  height: 40,
                                                  width: 200,
                                                ),
                                                dropdownStyleData:
                                                    const DropdownStyleData(
                                                  maxHeight: 200,
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  height: 40,
                                                ),

                                                //This to clear the search value when you close the menu
                                                onMenuStateChange: (isOpen) {
                                                  if (!isOpen) {
                                                    passengerTypeController
                                                        .clear();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              'PASSENGER FARE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  '${(price - discount).round()}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(height: 5),
                                  Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '*  ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25),
                                                  ),
                                                  Text(
                                                    'BAGGAGE FARE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: TextField(
                                                  controller: baggagePrice,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                  decoration: InputDecoration(
                                                      // contentPadding:
                                                      //     EdgeInsets.only(bottom: 10),
                                                      hintText: 'Enter Baggage',
                                                      hintStyle: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xff5f6062)),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      )),
                                                  onChanged: (value) {
                                                    try {
                                                      double baggageprice =
                                                          double.parse(value);
                                                      if (baggageprice <= 0) {
                                                        baggagePrice.text = "";
                                                      }
                                                    } catch (e) {}
                                                    _updateAmount(false);
                                                  },
                                                  onTap: () {
                                                    try {
                                                      double baggageprice =
                                                          double.parse(
                                                              baggagePrice
                                                                  .text);
                                                      if (baggageprice <= 0) {
                                                        baggagePrice.text = "";
                                                      }
                                                    } catch (e) {}
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(height: 5),
                                  Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight:
                                                  Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              'TOTAL FARE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  '${subtotal.round()}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(height: 5),
                                  Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight:
                                                  Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: SizedBox(
                                                width: double.infinity,
                                                child: Text('PAYMENT TYPE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ))),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isMastercard = true;
                                                  });
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Transform.scale(
                                                            scale: 1.6,
                                                            child: Radio(
                                                                activeColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                value: true,
                                                                groupValue:
                                                                    isMastercard,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    isMastercard =
                                                                        value!;
                                                                  });
                                                                }),
                                                          ),
                                                          Text(
                                                            'CASH CARD',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              )),
                                              SizedBox(width: 3),
                                              Expanded(
                                                  child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isMastercard = false;
                                                  });
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Transform.scale(
                                                            scale: 1.6,
                                                            child: Radio(
                                                                activeColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                value: false,
                                                                groupValue:
                                                                    isMastercard,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    isMastercard =
                                                                        value!;
                                                                  });
                                                                }),
                                                          ),
                                                          Text(
                                                            'FILIPAY',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              )),
                                            ],
                                          )
                                        ]),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 60,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _showDialogMenu(context);
                                              // Navigator.pushReplacement(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             TicketingMenuPage()));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: AppColors
                                                  .primaryColor, // Background color of the button
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24.0),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0), // Border radius
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'MENU',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 60,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (checkifValid()) {
                                                // _startNFCReader('mastercard');
                                                setState(() {
                                                  isNfcScanOn = true;
                                                });
                                                String cardType = "";
                                                if (isMastercard) {
                                                  cardType = "mastercard";
                                                  _showDialognfcScan(
                                                      context,
                                                      'MASTER CARD',
                                                      'master-card.png');
                                                } else {
                                                  _showDialognfcScan(
                                                      context,
                                                      'FILIPAY CARD',
                                                      'FILIPAY Cards - Regular.png');
                                                  if (passengerType !=
                                                      "regular") {
                                                    cardType = "discounted";
                                                  } else {
                                                    cardType = "regular";
                                                  }
                                                }

                                                _startNFCReader('$cardType');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: AppColors
                                                  .primaryColor, // Background color of the button
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24.0),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0), // Border radius
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'PROCEED',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: fetchService.getIsNumeric()
                                  ? Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                          decoration: BoxDecoration(
                                              // color: Color(0xFFd9d9d9),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Container(
                                                  //   width: MediaQuery.of(context)
                                                  //           .size
                                                  //           .width *
                                                  //       0.3,
                                                  //   decoration: BoxDecoration(
                                                  //       color: AppColors.primaryColor,
                                                  //       borderRadius:
                                                  //           BorderRadius.circular(10)),
                                                  //   child: Padding(
                                                  //     padding: const EdgeInsets.all(2.0),
                                                  //     child: Column(
                                                  //       mainAxisAlignment:
                                                  //           MainAxisAlignment.center,
                                                  //       children: [
                                                  //         FittedBox(
                                                  //           fit: BoxFit.scaleDown,
                                                  //           child: Text(
                                                  //             'KM RUN',
                                                  //             style: TextStyle(
                                                  //                 fontSize: 12,
                                                  //                 color: Colors.white,
                                                  //                 fontWeight:
                                                  //                     FontWeight.bold),
                                                  //           ),
                                                  //         ),
                                                  //         Container(
                                                  //           width: MediaQuery.of(context)
                                                  //               .size
                                                  //               .width,
                                                  //           color: Colors.white,
                                                  //           child: FittedBox(
                                                  //             fit: BoxFit.scaleDown,
                                                  //             child: Text(
                                                  //               '$kmRun',
                                                  //               style: TextStyle(
                                                  //                   fontSize: 20),
                                                  //               textAlign:
                                                  //                   TextAlign.center,
                                                  //             ),
                                                  //           ),
                                                  //         )
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print('tama');
                                                        // if (coopData[
                                                        //         'coopType'] ==
                                                        //     "Bus") {
                                                        //   _showDialogMenu(
                                                        //       context);
                                                        // } else {
                                                        setState(() {
                                                          isNfcScanOn = true;
                                                        });
                                                        _verificationCard();
                                                        _showTapVerificationCard(
                                                            context);
                                                        // }
                                                      },
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        decoration: BoxDecoration(
                                                            color: AppColors
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              'MENU',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '${bound.toUpperCase()}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 75,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'AMOUNT',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    // textfieldamount
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showDialogJeepneyTicketing(
                                                            context);
                                                      },
                                                      child: SizedBox(
                                                        height: 30,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: TextField(
                                                          controller:
                                                              editAmountController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          enabled: false,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          onSubmitted: (value) {
                                                            setState(() {
                                                              price =
                                                                  double.parse(
                                                                      value);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                    // Text(
                                                    //   '${subtotal.round()}',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(
                                                    //       fontSize: 30,
                                                    //       color: isDiscounted
                                                    //           ? Colors.orangeAccent
                                                    //           : Colors.white,
                                                    //       fontWeight: FontWeight.bold),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '$route',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height:
                                              // coopData['coopType'] == "Bus"
                                              //     ? MediaQuery.of(context)
                                              //             .size
                                              //             .height *
                                              //         0.3
                                              //     :
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.45,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          2, // 2 items per row

                                                      childAspectRatio: 2),
                                              itemCount: stations.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final station = stations[index];
                                                double amount = double.parse(
                                                    stations[index]['amount']
                                                        .toString());
                                                bool isselectedStationID =
                                                    false;
                                                if (station['_id'] ==
                                                    selectedStationID) {
                                                  isselectedStationID = true;
                                                }
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (isFix) return;
                                                    setState(() {
                                                      rowNo = station['rowNo'];

                                                      print(
                                                          'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                                      selectedStationID =
                                                          station['_id'];

                                                      selectedDestination =
                                                          station;
                                                      print(
                                                          'selectedDestination: $selectedDestination');

                                                      selectedStationName =
                                                          station['stationName'] ??
                                                              "";
                                                      print(
                                                          'selectedStationName: $selectedStationName');

                                                      double stationKM = (double
                                                                  .parse(station[
                                                                          stationkm] ??
                                                                      0
                                                                          .toString()) -
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      [
                                                                      stationkm] ??
                                                                  0.toString()))
                                                          .abs();
                                                      if (fetchService
                                                          .getIsNumeric()) {
                                                        price = double.parse(
                                                            station['amount']
                                                                .toString());
                                                      } else {
                                                        if (stationKM <=
                                                            firstKM) {
                                                          // If the total distance is 4 km or less, the cost is fixed.
                                                          price = minimumFare;
                                                        } else {
                                                          // If the total distance is more than 4 km, calculate the cost.
                                                          // double initialCost =
                                                          //     pricePerKM; // Cost for the first 4 km
                                                          // double additionalKM = stationKM -
                                                          //     firstkm; // Additional kilometers beyond 4 km
                                                          // double additionalCost = (additionalKM *
                                                          //         pricePerKM) /
                                                          //     firstkm; // Cost for additional kilometers

                                                          // if (coopData[
                                                          //         'coopType'] !=
                                                          //     "Bus") {
                                                          double
                                                              succeedingprice =
                                                              succeedingPrice(
                                                                  stationKM -
                                                                      firstKM);
                                                          print(
                                                              "succeedingprice: $succeedingprice");
                                                          price = minimumFare +
                                                              ((stationKM -
                                                                      firstKM) *
                                                                  pricePerKm);
                                                          // price = minimumFare +
                                                          //     succeedingprice;
                                                          // } else {
                                                          //   price = stationKM *
                                                          //       pricePerKm;
                                                          // }
                                                        }
                                                      }
                                                      print(
                                                          'passenger Type: $passengerType');
                                                      print(
                                                          'discount: $discount');

                                                      if (isDiscounted) {
                                                        discount = price *
                                                            discountPercent;
                                                        subtotal =
                                                            amount - discount;
                                                      } else {
                                                        subtotal = amount;
                                                      }

                                                      editAmountController
                                                              .text =
                                                          fetchservice
                                                              .roundToNearestQuarter(
                                                                  subtotal,
                                                                  minimumFare)
                                                              .toStringAsFixed(
                                                                  2);
                                                    });
                                                    // if (coopData['coopType'] ==
                                                    //     "Jeepney") {
                                                    print(
                                                        'show dialog for jeepney');
                                                    _showDialogJeepneyTicketing(
                                                        context);
                                                    // }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: isselectedStationID
                                                              ? AppColors
                                                                  .secondaryColor
                                                              : AppColors
                                                                  .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              width: 2,
                                                              color: AppColors
                                                                  .primaryColor)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            // '(${station[stationkm] - stations[currentStationIndex][stationkm]})',
                                                            '₱${isDltb ? amount.round() : amount.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                                color: isselectedStationID
                                                                    ? AppColors
                                                                        .primaryColor
                                                                    : AppColors
                                                                        .secondaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        // if (coopData['coopType'] == "Bus")
                                        //   Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceAround,
                                        //     children: [
                                        //       GestureDetector(
                                        //         onTap: () {
                                        //           _showDialogPassengerType(
                                        //               context);
                                        //         },
                                        //         child: buttonBottomWidget(
                                        //           title: 'PASSENGER TYPE',
                                        //           image: 'passenger.png',
                                        //           passengerType: passengerType,
                                        //           isDiscounted: isDiscounted,
                                        //           missing:
                                        //               ismissingPassengerType,
                                        //         ),
                                        //       ),
                                        //       GestureDetector(
                                        //         onTap: () {
                                        //           if (checkifValid()) {
                                        //             _showDialogBaggage(context);
                                        //           }
                                        //           // if (selectedStationName == '') {
                                        //           //   ArtSweetAlert.show(
                                        //           //       context: context,
                                        //           //       artDialogArgs: ArtDialogArgs(
                                        //           //           type: ArtSweetAlertType.danger,
                                        //           //           title: "INCOMPLETE",
                                        //           //           text: "PLEASE CHOOSE STATION"));
                                        //           // } else {
                                        //           //   _showDialogBaggage(context);
                                        //           // }
                                        //         },
                                        //         child: buttonBottomWidget(
                                        //           title: 'BAGGAGE',
                                        //           image: 'baggage.png',
                                        //           passengerType: passengerType,
                                        //           isDiscounted: isDiscounted,
                                        //           missing: false,
                                        //         ),
                                        //       ),
                                        //       GestureDetector(
                                        //         onTap: () {
                                        //           print(
                                        //               'subtotalzz: $subtotal');
                                        //           if (checkifValid()) {
                                        //             _showDialogTypeCards(
                                        //                 context);
                                        //           }
                                        //           // if (checkifValid()) {

                                        //           // if (int.parse(kmRun) >= 0) {
                                        //           //   if (passengerType != '' ||
                                        //           //       baggagePrice.text.trim() != '') {

                                        //           //   } else {
                                        //           //     ArtSweetAlert.show(
                                        //           //         context: context,
                                        //           //         artDialogArgs: ArtDialogArgs(
                                        //           //             type:
                                        //           //                 ArtSweetAlertType.warning,
                                        //           //             title: "INVALID",
                                        //           //             text:
                                        //           //                 "PLEASE CHOOSE PASSENGER TYPE\nOR INPUT BAGGAGE PRICE"));
                                        //           //   }
                                        //           // } else {

                                        //           //   ArtSweetAlert.show(
                                        //           //       context: context,
                                        //           //       artDialogArgs: ArtDialogArgs(
                                        //           //           type: ArtSweetAlertType.warning,
                                        //           //           title: "INVALID",
                                        //           //           text: "PLEASE CHOOSE STATION"));
                                        //           // }

                                        //           // }
                                        //         },
                                        //         child: buttonBottomWidget(
                                        //           title: isNoMasterCard
                                        //               ? 'PAYMENT'
                                        //               : 'CARD',
                                        //           image: isNoMasterCard
                                        //               ? 'cash.png'
                                        //               : 'filipay-cards.png',
                                        //           passengerType: passengerType,
                                        //           isDiscounted: isDiscounted,
                                        //           missing: false,
                                        //         ),
                                        //       )
                                        //     ],
                                        //   ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '${bound.toUpperCase()}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // if (coopData['coopType'] !=
                                                //     "Bus") {
                                                _showDialogJeepneyTicketing(
                                                    context);
                                                // }
                                              },
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: AppColors
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'AMOUNT',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          '${isDltb ? subtotal.round() : subtotal.toStringAsFixed(2)}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color: isDiscounted
                                                                  ? Colors
                                                                      .orangeAccent
                                                                  : AppColors
                                                                      .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '$route',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFd9d9d9),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  // if (coopData['coopType'] ==
                                                  //     "Bus")
                                                  //   Expanded(
                                                  //     child: Container(
                                                  //       height: MediaQuery.of(
                                                  //               context)
                                                  //           .size
                                                  //           .height,
                                                  //       decoration: BoxDecoration(
                                                  //           color: AppColors
                                                  //               .primaryColor,
                                                  //           borderRadius:
                                                  //               BorderRadius
                                                  //                   .circular(
                                                  //                       10)),
                                                  //       child: Padding(
                                                  //         padding:
                                                  //             const EdgeInsets
                                                  //                 .all(8.0),
                                                  //         child: Row(
                                                  //           mainAxisAlignment:
                                                  //               MainAxisAlignment
                                                  //                   .center,
                                                  //           children: [
                                                  //             Text(
                                                  //               'FIX',
                                                  //               style: TextStyle(
                                                  //                   fontSize:
                                                  //                       20,
                                                  //                   color: AppColors
                                                  //                       .secondaryColor,
                                                  //                   fontWeight:
                                                  //                       FontWeight
                                                  //                           .bold),
                                                  //             ),
                                                  //             Transform.scale(
                                                  //               scale: 2.0,
                                                  //               child: Checkbox(
                                                  //                 value: isFix,
                                                  //                 fillColor: MaterialStateProperty
                                                  //                     .resolveWith<
                                                  //                         Color?>(
                                                  //                   (Set<MaterialState>
                                                  //                       states) {
                                                  //                     if (states
                                                  //                         .contains(
                                                  //                             MaterialState.pressed)) {
                                                  //                       return AppColors
                                                  //                           .secondaryColor; // Color when the button is pressed
                                                  //                     }
                                                  //                     if (states
                                                  //                         .contains(
                                                  //                             MaterialState.disabled)) {
                                                  //                       return Colors
                                                  //                           .grey; // Color when the button is disabled
                                                  //                     }
                                                  //                     return AppColors
                                                  //                         .primaryColor; // Default color
                                                  //                   },
                                                  //                 ),
                                                  //                 side: BorderSide(
                                                  //                     width: 2,
                                                  //                     color: AppColors
                                                  //                         .secondaryColor),
                                                  //                 onChanged:
                                                  //                     (value) {
                                                  //                   setState(
                                                  //                       () {
                                                  //                     isFix =
                                                  //                         value!;
                                                  //                     storedData[
                                                  //                             'isFix'] =
                                                  //                         isFix;
                                                  //                     if (isFix) {
                                                  //                       storedData['selectedDestination'] =
                                                  //                           selectedDestination;

                                                  //                       _myBox.put(
                                                  //                           'SESSION',
                                                  //                           storedData);
                                                  //                     } else {
                                                  //                       print(
                                                  //                           'isFix _myBox: ${storedData['isFix']}');
                                                  //                       _myBox.put(
                                                  //                           'SESSION',
                                                  //                           storedData);
                                                  //                     }

                                                  //                     print(
                                                  //                         'isFix: $isFix');
                                                  //                   });
                                                  //                 },
                                                  //               ),
                                                  //             )
                                                  //           ],
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   ),

                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      // width:
                                                      //     coopData['coopType'] == "Bus"
                                                      //         ? MediaQuery.of(context)
                                                      //                 .size
                                                      //                 .width *
                                                      //             0.3
                                                      //         : MediaQuery.of(context)
                                                      //                 .size
                                                      //                 .width *
                                                      //             0.4,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                'KM RUN',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color:
                                                                  Colors.white,
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                child: Text(
                                                                  '$kmRun',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print('tama');
                                                        // if (coopData[
                                                        //         'coopType'] ==
                                                        //     "Bus") {
                                                        //   _showDialogMenu(
                                                        //       context);
                                                        // } else {
                                                        setState(() {
                                                          isNfcScanOn = true;
                                                        });
                                                        _verificationCard();
                                                        _showTapVerificationCard(
                                                            context);
                                                        // }
                                                      },
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        decoration: BoxDecoration(
                                                            color: AppColors
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              'MENU',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  if (isFix) return;
                                                  // final storedData = _myBox.get('SESSION');
                                                  setState(() {
                                                    currentStationIndex--;
                                                  });
                                                  if (currentStationIndex >=
                                                      0) {
                                                    print(stations[
                                                            currentStationIndex]
                                                        ['stationName']);
                                                    storedData[
                                                            'currentStationIndex'] =
                                                        currentStationIndex;
                                                    print(
                                                        "currentStationIndex: $currentStationIndex");
                                                    _myBox.put(
                                                        'SESSION', storedData);
                                                    print(
                                                        'Data in Hive box: $storedData');
                                                    // selectedDestination =
                                                    //     storedData['selectedDestination'];
                                                    if (selectedDestination
                                                        .isNotEmpty) {
                                                      double stationKM = (double.parse(
                                                                  selectedDestination[
                                                                          stationkm]
                                                                      .toString()) -
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      [
                                                                      stationkm]
                                                                  .toString()))
                                                          .abs();
                                                      double baggageprice =
                                                          0.00;
                                                      if (baggagePrice.text !=
                                                          '') {
                                                        baggageprice =
                                                            double.parse(
                                                                baggagePrice
                                                                    .text);
                                                      }
                                                      setState(() {
                                                        print(
                                                            'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                                        selectedStationID =
                                                            selectedDestination[
                                                                '_id'];

                                                        storedData[
                                                                'selectedDestination'] =
                                                            selectedDestination;

                                                        toKM = double.parse(
                                                            selectedDestination[
                                                                    stationkm]
                                                                .toString());

                                                        selectedStationName =
                                                            selectedDestination[
                                                                'stationName'];
                                                        print(
                                                            'selectedStationName: $selectedStationName');
                                                        // price = (pricePerKM * stationKM);
                                                        if (fetchService
                                                            .getIsNumeric()) {
                                                          price = double.parse(
                                                              coopData['amount']
                                                                  .toString());
                                                        } else {
                                                          if (stationKM <=
                                                              firstKM) {
                                                            // If the total distance is 4 km or less, the cost is fixed.
                                                            price = minimumFare;
                                                          } else {
                                                            // If the total distance is more than 4 km, calculate the cost.
                                                            // double initialCost =
                                                            //     pricePerKM; // Cost for the first 4 km
                                                            // double additionalKM = stationKM -
                                                            //     firstkm; // Additional kilometers beyond 4 km
                                                            // double additionalCost = (additionalKM *
                                                            //         pricePerKM) /
                                                            //     firstkm; // Cost for additional kilometers
                                                            // if (coopData[
                                                            //         'coopType'] !=
                                                            //     "Bus") {
                                                            price = minimumFare +
                                                                ((stationKM -
                                                                        firstKM) *
                                                                    pricePerKm);
                                                            // } else {
                                                            //   price = stationKM *
                                                            //       pricePerKm;
                                                            // }
                                                          }
                                                        }

                                                        print(
                                                            'passenger Type: $passengerType');
                                                        print(
                                                            'discount: $discount');

                                                        if (isDiscounted) {
                                                          discount = price *
                                                              discountPercent;
                                                        }
                                                        subtotal = (price -
                                                                discount +
                                                                baggageprice) *
                                                            quantity;
                                                        editAmountController
                                                                .text =
                                                            fetchservice
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare)
                                                                .toStringAsFixed(
                                                                    2);

                                                        kmRun = formatDouble(
                                                            stationKM);
                                                      });
                                                      print(
                                                          'selectedDestination: $selectedDestination');
                                                    }
                                                  } else {
                                                    setState(() {
                                                      currentStationIndex++;
                                                    });
                                                  }
                                                  // print(stations.length);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: AppColors
                                                      .primaryColor, // Background color of the button
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 24.0),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: AppColors
                                                            .secondaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0), // Border radius
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.chevron_left_sharp,
                                                  color: Colors.white,
                                                )),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '${stations[currentStationIndex]['stationName']}',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if (isFix) return;
                                                  if (currentStationIndex + 2 ==
                                                      stations.length) {
                                                    if (!fetchservice
                                                            .getIsNumeric() &&
                                                        coopData['coopType'] ==
                                                            "Jeepney") {
                                                      await ArtSweetAlert.show(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          artDialogArgs:
                                                              ArtDialogArgs(
                                                                  type:
                                                                      ArtSweetAlertType
                                                                          .info,
                                                                  showCancelBtn:
                                                                      true,
                                                                  cancelButtonText:
                                                                      'NO',
                                                                  confirmButtonText:
                                                                      'YES',
                                                                  title:
                                                                      "REVERSE",
                                                                  onConfirm:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      sessionBox[
                                                                              'isViceVersa'] =
                                                                          !sessionBox[
                                                                              'isViceVersa'];
                                                                      sessionBox[
                                                                          'currentStationIndex'] = 0;
                                                                      sessionBox[
                                                                          'reverseNum'] += 1;
                                                                      _myBox.put(
                                                                          'SESSION',
                                                                          sessionBox);
                                                                      currentStationIndex =
                                                                          0;
                                                                      stations = stations
                                                                          .reversed
                                                                          .toList();
                                                                    });

                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  onDeny: () {
                                                                    print(
                                                                        'deny');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    return;
                                                                  },
                                                                  text:
                                                                      "Are you sure you would like to Reverse?"));
                                                    }
                                                    return;
                                                  }
                                                  final storedData =
                                                      _myBox.get('SESSION');
                                                  // print('Data in Hive box: $storedData');

                                                  setState(() {
                                                    currentStationIndex++;
                                                  });
                                                  if (stations.length >
                                                      currentStationIndex) {
                                                    print(stations[
                                                            currentStationIndex]
                                                        ['stationName']);
                                                    storedData[
                                                            'currentStationIndex'] =
                                                        currentStationIndex;

                                                    print(
                                                        "currentStationIndex: $currentStationIndex");
                                                    _myBox.put(
                                                        'SESSION', storedData);
                                                    print(
                                                        'Data in Hive box: $storedData');

                                                    if (selectedDestination
                                                        .isNotEmpty) {
                                                      // selectedDestination =
                                                      //     storedData['selectedDestination'];

                                                      double stationKM = (double.parse(
                                                                  selectedDestination[
                                                                          stationkm]
                                                                      .toString()) -
                                                              double.parse(stations[
                                                                          currentStationIndex]
                                                                      [
                                                                      stationkm]
                                                                  .toString()))
                                                          .abs();
                                                      double baggageprice =
                                                          0.00;
                                                      if (baggagePrice.text !=
                                                          '') {
                                                        baggageprice =
                                                            double.parse(
                                                                baggagePrice
                                                                    .text);
                                                      }

                                                      setState(() {
                                                        print(
                                                            'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                                        selectedStationID =
                                                            selectedDestination[
                                                                '_id'];

                                                        storedData[
                                                                'selectedDestination'] =
                                                            selectedDestination;

                                                        toKM = double.parse(
                                                            selectedDestination[
                                                                    stationkm]
                                                                .toString());

                                                        selectedStationName =
                                                            selectedDestination[
                                                                'stationName'];
                                                        print(
                                                            'selectedStationName: $selectedStationName');
                                                        // price = (pricePerKM * stationKM);
                                                        if (fetchService
                                                            .getIsNumeric()) {
                                                          price = double.parse(
                                                              coopData['amount']
                                                                  .toString());
                                                        } else {
                                                          if (stationKM <=
                                                              firstKM) {
                                                            // If the total distance is 4 km or less, the cost is fixed.
                                                            price = minimumFare;
                                                          } else {
                                                            // If the total distance is more than 4 km, calculate the cost.
                                                            // double initialCost =
                                                            //     pricePerKM; // Cost for the first 4 km
                                                            // double additionalKM = stationKM -
                                                            //     firstkm; // Additional kilometers beyond 4 km
                                                            // double additionalCost = (additionalKM *
                                                            //         pricePerKM) /
                                                            //     firstkm; // Cost for additional kilometers

                                                            // if (coopData[
                                                            //         'coopType'] !=
                                                            //     "Bus") {
                                                            price = minimumFare +
                                                                ((stationKM -
                                                                        firstKM) *
                                                                    pricePerKm);
                                                            // } else {
                                                            //   price = stationKM *
                                                            //       pricePerKm;
                                                            // }
                                                          }
                                                        }
                                                        print(
                                                            'passenger Type: $passengerType');
                                                        print(
                                                            'discount: $discount');

                                                        if (isDiscounted) {
                                                          discount = price *
                                                              discountPercent;
                                                        }
                                                        subtotal = (price -
                                                                discount +
                                                                baggageprice) *
                                                            quantity;
                                                        editAmountController
                                                                .text =
                                                            fetchservice
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare)
                                                                .toStringAsFixed(
                                                                    2);
                                                        if (coopData[
                                                                'coopType'] ==
                                                            "Jeepney") {
                                                          subtotal = fetchService
                                                              .roundToNearestQuarter(
                                                                  subtotal,
                                                                  minimumFare);
                                                        }

                                                        kmRun = formatDouble(
                                                            stationKM);
                                                      });
                                                      print(
                                                          'selectedDestination: $selectedDestination');
                                                    }
                                                  } else {
                                                    setState(() {
                                                      currentStationIndex--;
                                                    });
                                                  }
                                                  // print(stations.length);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: AppColors
                                                      .primaryColor, // Background color of the button
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 24.0),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0), // Border radius
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.chevron_right_sharp,
                                                  color: Colors.white,
                                                )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        2, // 2 items per row

                                                    childAspectRatio: 2),
                                            itemCount: stations.length -
                                                currentStationIndex -
                                                1,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final station = stations[index +
                                                  currentStationIndex +
                                                  1];
                                              double price2 = 0;
                                              bool isselectedStationID = false;
                                              if (station['_id'] ==
                                                  selectedStationID) {
                                                isselectedStationID = true;
                                              }

                                              double stationKM2 = (double.parse(
                                                          station[stationkm]
                                                              .toString()) -
                                                      double.parse(stations[
                                                                  currentStationIndex]
                                                              [stationkm]
                                                          .toString()))
                                                  .abs();
                                              double baggageprice2 = 0.00;
                                              if (stationKM2 <= firstKM) {
                                                // If the total distance is 4 km or less, the cost is fixed.
                                                price2 = minimumFare;
                                              } else {
                                                // If the total distance is more than 4 km, calculate the cost.
                                                // double initialCost2 =
                                                //     pricePerKM2; // Cost for the first 4 km
                                                // double additionalKM2 = stationKM2 -
                                                //     firstkm2; // Additional kilometers beyond 4 km
                                                // double additionalCost2 = (additionalKM2 *
                                                //         pricePerKM2) /
                                                //     firstkm2; // Cost for additional kilometers

                                                if (coopData['coopType'] !=
                                                    "Bus") {
                                                  price2 = minimumFare +
                                                      ((stationKM2 - firstKM) *
                                                          pricePerKm);
                                                } else {
                                                  price2 =
                                                      stationKM2 * pricePerKm;
                                                }
                                              }
                                              return GestureDetector(
                                                onTap: () {
                                                  if (isFix) return;
                                                  // final storedData = _myBox.get('SESSION');
                                                  final station = stations[
                                                      index +
                                                          currentStationIndex +
                                                          1];

                                                  double stationKM = (double
                                                              .parse(station[
                                                                      stationkm]
                                                                  .toString()) -
                                                          double.parse(stations[
                                                                      currentStationIndex]
                                                                  [stationkm]
                                                              .toString()))
                                                      .abs();
                                                  double baggageprice = 0.00;

                                                  if (baggagePrice.text != '') {
                                                    baggageprice = double.parse(
                                                        baggagePrice.text);
                                                  }

                                                  setState(() {
                                                    rowNo = station['rowNo'];

                                                    if (fetchService
                                                        .getIsNumeric()) {
                                                      price = double.parse(
                                                          coopData['amount']
                                                              .toString());
                                                    } else {
                                                      if (stationKM <=
                                                          firstKM) {
                                                        // If the total distance is 4 km or less, the cost is fixed.
                                                        price = minimumFare;
                                                      } else {
                                                        // If the total distance is more than 4 km, calculate the cost.
                                                        // double initialCost =
                                                        //     pricePerKM; // Cost for the first 4 km
                                                        // double additionalKM = stationKM -
                                                        //     firstkm; // Additional kilometers beyond 4 km
                                                        // double additionalCost = (additionalKM *
                                                        //         pricePerKM) /
                                                        //     firstkm; // Cost for additional kilometers

                                                        if (coopData[
                                                                'coopType'] !=
                                                            "Bus") {
                                                          double
                                                              succeedingprice =
                                                              succeedingPrice(
                                                                  stationKM -
                                                                      firstKM);
                                                          print(
                                                              "succeedingprice: $succeedingprice");
                                                          price = minimumFare +
                                                              ((stationKM -
                                                                      firstKM) *
                                                                  pricePerKm);
                                                          // price = minimumFare +
                                                          //     succeedingprice;
                                                        } else {
                                                          price = stationKM *
                                                              pricePerKm;
                                                        }
                                                      }
                                                    }
                                                    print(
                                                        'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                                    selectedStationID =
                                                        station['_id'];

                                                    selectedDestination =
                                                        station;
                                                    print(
                                                        'selectedDestination: $selectedDestination');
                                                    toKM = double.parse(
                                                        station[stationkm]
                                                            .toString());

                                                    selectedStationName =
                                                        station['stationName'];
                                                    print(
                                                        'selectedStationName: $selectedStationName');
                                                    // price = (pricePerKM * stationKM);

                                                    print(
                                                        'passenger Type: $passengerType');
                                                    print(
                                                        'discount: $discount');

                                                    if (isDiscounted) {
                                                      discount = price *
                                                          discountPercent;
                                                    }
                                                    subtotal = (price -
                                                            discount +
                                                            baggageprice) *
                                                        quantity;
                                                    if (coopData['coopType'] ==
                                                        "Jeepney") {
                                                      subtotal = fetchService
                                                          .roundToNearestQuarter(
                                                              subtotal,
                                                              minimumFare);
                                                    }
                                                    editAmountController.text =
                                                        fetchservice
                                                            .roundToNearestQuarter(
                                                                subtotal,
                                                                minimumFare)
                                                            .toStringAsFixed(2);
                                                    kmRun =
                                                        formatDouble(stationKM);
                                                  });
                                                  print('price: $price');
                                                  if (coopData['coopType'] ==
                                                      "Jeepney") {
                                                    print(
                                                        'show dialog for jeepney');
                                                    _showDialogJeepneyTicketing(
                                                        context);
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: isselectedStationID
                                                            ? Color(0xff00558d)
                                                            : AppColors
                                                                .primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            width: 2,
                                                            color:
                                                                Colors.white)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          // '(${station[stationkm] - stations[currentStationIndex][stationkm]})',
                                                          '₱${isDltb ? price2.round() : fetchservice.roundToNearestQuarter(price2, minimumFare).toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                              '${station['stationName']}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                              //  Card(
                                              //   margin: EdgeInsets.all(8.0),
                                              //   child: ListTile(
                                              //     title: Text(route['origin']),
                                              //     subtitle: Text(route['destination']),
                                              //   ),
                                              // );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        // if (coopData['coopType'] == "Bus")
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceAround,
                                        //   children: [
                                        //     GestureDetector(
                                        //       onTap: () {
                                        //         _showDialogPassengerType(context);
                                        //       },
                                        //       child: buttonBottomWidget(
                                        //         title: 'PASSENGER TYPE',
                                        //         image: 'passenger.png',
                                        //         passengerType: passengerType,
                                        //         isDiscounted: isDiscounted,
                                        //         missing: ismissingPassengerType,
                                        //       ),
                                        //     ),
                                        //     GestureDetector(
                                        //       onTap: () {
                                        //         if (selectedStationName == '') {
                                        //           ArtSweetAlert.show(
                                        //               context: context,
                                        //               artDialogArgs: ArtDialogArgs(
                                        //                   type: ArtSweetAlertType
                                        //                       .danger,
                                        //                   title: "INCOMPLETE",
                                        //                   text:
                                        //                       "PLEASE CHOOSE STATION"));
                                        //         } else {
                                        //           _showDialogBaggage(context);
                                        //         }
                                        //       },
                                        //       child: buttonBottomWidget(
                                        //         title: 'BAGGAGE',
                                        //         image: 'baggage.png',
                                        //         passengerType: passengerType,
                                        //         isDiscounted: isDiscounted,
                                        //         missing: false,
                                        //       ),
                                        //     ),
                                        //     GestureDetector(
                                        //       onTap: () {
                                        //         if (!checkifValid()) {
                                        //           return;
                                        //         }
                                        //         // if (checkifValid()) {
                                        //         if (int.parse(kmRun) >= 0) {
                                        //           if (passengerType != '' ||
                                        //               baggagePrice.text.trim() !=
                                        //                   '') {
                                        //             _showDialogTypeCards(context);
                                        //           } else {
                                        //             ArtSweetAlert.show(
                                        //                 context: context,
                                        //                 artDialogArgs: ArtDialogArgs(
                                        //                     type: ArtSweetAlertType
                                        //                         .warning,
                                        //                     title: "INVALID",
                                        //                     text:
                                        //                         "PLEASE CHOOSE PASSENGER TYPE\nOR INPUT BAGGAGE PRICE"));
                                        //           }
                                        //         } else {
                                        //           ArtSweetAlert.show(
                                        //               context: context,
                                        //               artDialogArgs: ArtDialogArgs(
                                        //                   type: ArtSweetAlertType
                                        //                       .warning,
                                        //                   title: "INVALID",
                                        //                   text:
                                        //                       "PLEASE CHOOSE STATION"));
                                        //         }

                                        //         // }
                                        //       },
                                        //       child: buttonBottomWidget(
                                        //         title: isNoMasterCard
                                        //             ? 'PAYMENT'
                                        //             : 'CARD',
                                        //         image: isNoMasterCard
                                        //             ? 'cash.png'
                                        //             : 'filipay-cards.png',
                                        //         passengerType: passengerType,
                                        //         isDiscounted: isDiscounted,
                                        //         missing: false,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                      ],
                                    ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  void _showDialogMenu(BuildContext context) {
    String lastTicketNo = 'N/A';
    print('district km: ${stations[0][stationkm]}');

    int currentKM = fetchService.getIsNumeric()
        ? 0
        : stations[currentStationIndex][stationkm];
    print('current station KM: ${stations[currentStationIndex][stationkm]}');

    final torTicket = fetchservice.fetchTorTicket();
    if (torTicket.isNotEmpty) {
      lastTicketNo = '${torTicket[torTicket.length - 1]['ticket_no']}';
    }
    int onboardPassenger = fetchservice.onBoardPassenger();

    int onboardBaggage = fetchservice.onBoardBaggage();
    print('total passenger onboard: $onboardPassenger');
    print('total passenger onboardBaggage: $onboardBaggage');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: coopData['coopType'] == "Jeepney"
                ? MediaQuery.of(context).size.height * 0.4
                : MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TICKETING MENU',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Are you sure you want to exit?',
                                  style: TextStyle(
                                      color: Color(0xff58595b),
                                      fontWeight: FontWeight.bold),
                                ),
                                if (coopData['coopType'] == "Bus")
                                  ticketingmenuWidget(
                                      title: 'Passenger on Board',
                                      count: onboardPassenger.toDouble()),
                                if (coopData['coopType'] == "Bus")
                                  ticketingmenuWidget(
                                      title: 'Baggage on Board',
                                      count: onboardBaggage.toDouble()),
                                if (coopData['coopType'] == "Bus")
                                  ticketingmenuWidget(
                                      title: 'Cash Received',
                                      count: fetchservice
                                          .totalTripCashReceived()
                                          .toDouble()),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.white, width: 5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0,
                                              2), // Shadow position (horizontal, vertical)
                                          blurRadius:
                                              4.0, // Spread of the shadow
                                          spreadRadius:
                                              1.0, // Expanding the shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Last Ticket No.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text('$lastTicketNo',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // ticketingmenuWidget(
                                //     title: 'Last Ticket No.',count:0 ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors
                                              .primaryColor, // Background color of the button
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Border radius
                                          ),
                                        ),
                                        child: Text(
                                          'NO',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    ElevatedButton(
                                        onPressed: () {
                                          if (coopData['coopType'] == "Bus") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TicketingMenuPage()));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DashboardPage()));
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors
                                              .primaryColor, // Background color of the button
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Border radius
                                          ),
                                        ),
                                        child: Text(
                                          'YES',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                )
                              ]))),
                ],
              ),
            ),
          ),
        );
        // AlertDialog(
        //   title: Text('CHOOSE POSITION'),
        //   content: Text('This is a simple dialog box.'),
        //   actions: <Widget>[
        //     ElevatedButton(
        //       child: Text('TICKETING MENU'),
        //       onPressed: () {
        //         Navigator.of(context).pop(); // Close the dialog
        //       },
        //     ),
        //     ElevatedButton(
        //       child: Text('OTHER MENU'),
        //       onPressed: () {
        //         Navigator.of(context).pop(); // Close the dialog
        //       },
        //     ),
        //   ],
        // );
      },
    );
  }

  void _showDialogPassengerType(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
                color: Color(0xFF00558d),
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'SELECT PASSENGER TYPE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (passengerType != 'regular') {
                                              double baggageprice = 0.00;
                                              if (baggagePrice.text != '') {
                                                baggageprice = double.parse(
                                                    baggagePrice.text);
                                              }

                                              setState(() {
                                                isDiscounted = false;
                                                discount = 0;
                                                passengerType = 'regular';
                                                ismissingPassengerType = false;

                                                subtotal = price + baggageprice;
                                                editAmountController.text =
                                                    fetchservice
                                                        .roundToNearestQuarter(
                                                            subtotal,
                                                            minimumFare)
                                                        .toStringAsFixed(2);
                                                if (coopData['coopType'] ==
                                                    "Jeepney") {
                                                  subtotal = fetchService
                                                      .roundToNearestQuarter(
                                                          subtotal,
                                                          minimumFare);
                                                }
                                              });
                                            }

                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: passengerType == 'regular'
                                                ? Color(0xff00558d)
                                                : Color(
                                                    0xFF46aef2), // Background color of the button
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0), // Border radius
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'FULL FARE',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (passengerType != 'senior') {
                                              setState(() {
                                                passengerType = 'senior';
                                                ismissingPassengerType = false;
                                                if (!isDiscounted) {
                                                  isDiscounted = true;
                                                  int baggageprice = 0;
                                                  if (baggagePrice.text
                                                          .trim() !=
                                                      '') {
                                                    baggageprice = int.parse(
                                                        baggagePrice.text);
                                                  }
                                                  //   // price = (price*discountPercent);

                                                  //   discount = price * discountPercent;

                                                  //   subtotal =
                                                  //       subtotal - discount;
                                                  // } else {

                                                  // }
                                                  discount =
                                                      price * discountPercent;
                                                  // price = price - discount;

                                                  subtotal = price -
                                                      discount +
                                                      baggageprice;
                                                  editAmountController.text =
                                                      fetchservice
                                                          .roundToNearestQuarter(
                                                              subtotal,
                                                              minimumFare)
                                                          .toStringAsFixed(2);
                                                  if (coopData['coopType'] ==
                                                      "Jeepney") {
                                                    subtotal = fetchService
                                                        .roundToNearestQuarter(
                                                            subtotal,
                                                            minimumFare);
                                                  }
                                                  print(
                                                      'current price: $price');
                                                }
                                              });
                                            }

                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: passengerType == 'senior'
                                                ? Color(0xff00558d)
                                                : Color(
                                                    0xFF46aef2), // Background color of the button
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0), // Border radius
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'SENIOR',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (passengerType != 'student') {
                                              setState(() {
                                                passengerType = 'student';
                                                ismissingPassengerType = false;
                                                if (!isDiscounted) {
                                                  isDiscounted = true;
                                                  int baggageprice = 0;
                                                  if (baggagePrice.text
                                                          .trim() !=
                                                      '') {
                                                    baggageprice = int.parse(
                                                        baggagePrice.text);
                                                  }
                                                  //   // price = (price*discountPercent);

                                                  //   discount = price * discountPercent;

                                                  //   subtotal =
                                                  //       subtotal - discount;
                                                  // } else {

                                                  // }
                                                  discount =
                                                      price * discountPercent;

                                                  subtotal = price -
                                                      discount +
                                                      baggageprice;
                                                  editAmountController.text =
                                                      fetchservice
                                                          .roundToNearestQuarter(
                                                              subtotal,
                                                              minimumFare)
                                                          .toStringAsFixed(2);
                                                  if (coopData['coopType'] ==
                                                      "Jeepney") {
                                                    subtotal = fetchService
                                                        .roundToNearestQuarter(
                                                            subtotal,
                                                            minimumFare);
                                                  }
                                                }
                                              });
                                            }

                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: passengerType == 'student'
                                                ? Color(0xff00558d)
                                                : Color(
                                                    0xFF46aef2), // Background color of the button
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0), // Border radius
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'STUDENT',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (passengerType != 'pwd') {
                                              setState(() {
                                                passengerType = 'pwd';
                                                ismissingPassengerType = false;
                                                if (!isDiscounted) {
                                                  isDiscounted = true;
                                                  int baggageprice = 0;
                                                  if (baggagePrice.text
                                                          .trim() !=
                                                      '') {
                                                    baggageprice = int.parse(
                                                        baggagePrice.text);
                                                  }
                                                  //   // price = (price*discountPercent);

                                                  //   discount = price * discountPercent;

                                                  //   subtotal =
                                                  //       subtotal - discount;
                                                  // } else {

                                                  // }
                                                  discount =
                                                      price * discountPercent;

                                                  subtotal = price -
                                                      discount +
                                                      baggageprice;
                                                  editAmountController.text =
                                                      fetchservice
                                                          .roundToNearestQuarter(
                                                              subtotal,
                                                              minimumFare)
                                                          .toStringAsFixed(2);
                                                  if (coopData['coopType'] ==
                                                      "Jeepney") {
                                                    subtotal = fetchService
                                                        .roundToNearestQuarter(
                                                            subtotal,
                                                            minimumFare);
                                                  }
                                                }
                                              });
                                            }

                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: passengerType == 'pwd'
                                                ? Color(0xff00558d)
                                                : Color(
                                                    0xFF46aef2), // Background color of the button
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0), // Border radius
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'PWD',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ]))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialogBaggage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: BoxDecoration(
                color: Color(0xFF00558d),
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'BAGGAGE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From: 0 - ${selectedRoute[0]['origin']}',
                              ),
                              Text('To: $kmRun - ${selectedStationName}'),
                              SizedBox(height: 5),
                              TextFormField(
                                controller: baggagePrice,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits (0-9)
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Prevent line breaks
                                ],
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: 'ENTER THE PRICE',
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.primaryColor),
                              ),
                            ]),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xff46aef2), // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.white),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: Text(
                              'CLOSE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              double baggageprice = 0.00;
                              if (baggagePrice.text != '') {
                                baggageprice = double.parse(baggagePrice.text);
                              }

                              setState(() {
                                if (passengerType == 'discounted') {
                                  discount = price * discountPercent;
                                }
                                if (passengerType != '') {
                                  subtotal = price - discount + baggageprice;
                                } else {
                                  subtotal = baggageprice;
                                }
                                if (coopData['coopType'] == "Jeepney") {
                                  subtotal = fetchService.roundToNearestQuarter(
                                      subtotal, minimumFare);
                                }
                                editAmountController.text = fetchservice
                                    .roundToNearestQuarter(
                                        subtotal, minimumFare)
                                    .toStringAsFixed(2);
                              });

                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xff46aef2), // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.white),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialogTypeCards(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
                color: Color(0xFF00558d),
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'SELECT TYPE OF CARDS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (checkifValid()) {
                                      // _startNFCReader('mastercard');
                                      if (!isNoMasterCard) {
                                        setState(() {
                                          isNfcScanOn = true;
                                        });
                                        _startNFCReader('mastercard');
                                        _showDialognfcScan(context,
                                            'MASTER CARD', 'master-card.png');
                                      } else {
                                        _startNFCReader('mastercard');
                                      }
                                    }
                                  },
                                  child: typeofCardsWidget(
                                      title: isNoMasterCard
                                          ? 'CASH'
                                          : 'MASTER CARD',
                                      image: isNoMasterCard
                                          ? 'cash.png'
                                          : 'master-card.png'),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              if (!isDiscounted)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      _startNFCReader('regular');
                                      _showDialognfcScan(
                                          context,
                                          'FILIPAY CARD',
                                          'FILIPAY Cards - Regular.png');
                                    },
                                    child: typeofCardsWidget(
                                        title: 'FILIPAY CARD',
                                        image: 'FILIPAY Cards - Regular.png'),
                                  ),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              if (isDiscounted)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      _startNFCReader('discounted');
                                      _showDialognfcScan(
                                          context,
                                          'DISCOUNTED CARD',
                                          'FILIPAY Cards - Discounted.png');
                                    },
                                    child: typeofCardsWidget(
                                        title: 'DISCOUNTED CARD',
                                        image:
                                            'FILIPAY Cards - Discounted.png'),
                                  ),
                                ),
                            ],
                          ))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialognfcScan(
      BuildContext context, String cardType, String cardImg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TAP YOUR CARD',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/$cardImg',
                                    width: 200,
                                    height: 200,
                                  )),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/nfc.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${cardType.toUpperCase()}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      setState(() {
        isNfcScanOn = false;
      });
    });
  }

  void _showDialogJeepneyTicketing(BuildContext context) {
    double baggageprice = 0.00;
    if (baggagePrice.text != '') {
      baggageprice = double.parse(baggagePrice.text);
    }
    if (baggageOnly) {
      passengerType = "";
      subtotal = baggageprice;
      editAmountController.text = fetchservice
          .roundToNearestQuarter(subtotal, minimumFare)
          .toStringAsFixed(2);
    } else {
      subtotal =
          ((fetchservice.roundToNearestQuarter(price, minimumFare) - discount) *
                  quantity) +
              baggageprice;
      editAmountController.text = fetchservice
          .roundToNearestQuarter(subtotal, minimumFare)
          .toStringAsFixed(2);
    }
    try {
      double checkifzero = double.parse(editAmountController.text);
      if (checkifzero <= 0) {
        editAmountController.text = "";
      }
    } catch (e) {
      print(e);
    }
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Quick Menu',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SingleChildScrollView(
                                  child: Column(
                                children: [
                                  Container(
                                    height: 75,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2,
                                            color: AppColors.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'AMOUNT',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // textfieldamount
                                          SizedBox(
                                            height: 30,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: TextField(
                                              controller: editAmountController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.only(bottom: 10),
                                                border: InputBorder.none,
                                              ),
                                              style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold),

                                              onChanged: (value) {
                                                setState(() {
                                                  try {
                                                    price = double.parse(
                                                        editAmountController
                                                            .text);
                                                    subtotal = double.parse(
                                                        editAmountController
                                                            .text);
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                });
                                              },
                                              onTap: () {
                                                try {
                                                  double checkifzero =
                                                      double.parse(
                                                          editAmountController
                                                              .text);
                                                  if (checkifzero <= 0) {
                                                    editAmountController.text =
                                                        "";
                                                  }
                                                } catch (e) {
                                                  print(e);
                                                }
                                              },
                                              onTapOutside: (value) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              // onTapOutside: (value) {
                                              //   setState(() {
                                              //     try {
                                              //       price = double.parse(
                                              //           editAmountController
                                              //               .text);
                                              //       subtotal = double.parse(
                                              //           editAmountController
                                              //               .text);
                                              //     } catch (e) {
                                              //       print(e);
                                              //     }
                                              //   });
                                              //   FocusScope.of(context)
                                              //       .unfocus();
                                              // },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  StatefulBuilder(builder: (context, setState) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  if (baggageOnly) {
                                                    return;
                                                  }
                                                  setState(() {
                                                    if (quantity > 1) {
                                                      quantity--;
                                                      editAmountController.text = fetchservice
                                                          .roundToNearestQuarter(
                                                              (double.parse(
                                                                      editAmountController
                                                                          .text) -
                                                                  (fetchservice.roundToNearestQuarter(
                                                                          price,
                                                                          minimumFare) -
                                                                      discount)),
                                                              minimumFare)
                                                          .toStringAsFixed(2);
                                                      subtotal -= fetchservice
                                                              .roundToNearestQuarter(
                                                                  price,
                                                                  minimumFare) -
                                                          discount;
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_back_ios_rounded,
                                                    color: AppColors
                                                        .primaryColor)),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primaryColor,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8),
                                                  child: Text("$quantity",
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                            IconButton(
                                                onPressed: () {
                                                  if (baggageOnly) {
                                                    return;
                                                  }
                                                  setState(() {
                                                    quantity++;
                                                    subtotal += fetchservice
                                                            .roundToNearestQuarter(
                                                                price,
                                                                minimumFare) -
                                                        discount;
                                                    editAmountController.text = fetchservice
                                                        .roundToNearestQuarter(
                                                            (double.parse(
                                                                    editAmountController
                                                                        .text) +
                                                                (fetchservice.roundToNearestQuarter(
                                                                        price,
                                                                        minimumFare) -
                                                                    discount)),
                                                            minimumFare)
                                                        .toStringAsFixed(2);
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    color: AppColors
                                                        .primaryColor)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (passengerType !=
                                                        'regular') {
                                                      double baggageprice =
                                                          0.00;
                                                      if (baggagePrice.text !=
                                                          '') {
                                                        baggageprice =
                                                            double.parse(
                                                                baggagePrice
                                                                    .text);
                                                      }

                                                      setState(() {
                                                        isDiscounted = false;
                                                        discount = 0;
                                                        passengerType =
                                                            'regular';
                                                        ismissingPassengerType =
                                                            false;

                                                        subtotal = (fetchservice
                                                                    .roundToNearestQuarter(
                                                                        price,
                                                                        minimumFare) *
                                                                quantity) +
                                                            baggageprice;
                                                        print(
                                                            'subtotal quick:  $subtotal');
                                                        editAmountController
                                                                .text =
                                                            fetchservice
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare)
                                                                .toStringAsFixed(
                                                                    2);
                                                        if (coopData[
                                                                'coopType'] ==
                                                            "Jeepney") {
                                                          subtotal = fetchService
                                                              .roundToNearestQuarter(
                                                                  subtotal,
                                                                  minimumFare);
                                                        }
                                                        if (baggageOnly) {
                                                          passengerType = "";
                                                          subtotal =
                                                              baggageprice;
                                                          editAmountController
                                                                  .text =
                                                              fetchservice
                                                                  .roundToNearestQuarter(
                                                                      subtotal,
                                                                      minimumFare)
                                                                  .toStringAsFixed(
                                                                      2);
                                                        }
                                                      });
                                                    }

                                                    // Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: passengerType ==
                                                            'regular'
                                                        ? Color(0xff00558d)
                                                        : Color(
                                                            0xFF46aef2), // Background color of the button
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Border radius
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'FULL FARE',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (passengerType !=
                                                        'senior') {
                                                      setState(() {
                                                        passengerType =
                                                            'senior';
                                                        ismissingPassengerType =
                                                            false;
                                                        if (!isDiscounted) {
                                                          isDiscounted = true;
                                                          double baggageprice =
                                                              0;
                                                          if (baggagePrice.text
                                                                  .trim() !=
                                                              '') {
                                                            baggageprice =
                                                                double.parse(
                                                                    baggagePrice
                                                                        .text);
                                                          }
                                                          //   // price = (price*discountPercent);

                                                          //   discount = price * discountPercent;

                                                          //   subtotal =
                                                          //       subtotal - discount;
                                                          // } else {

                                                          // }
                                                          discount = price *
                                                              discountPercent;
                                                          // price = price - discount;

                                                          subtotal = ((price -
                                                                      discount) *
                                                                  quantity) +
                                                              baggageprice;
                                                          editAmountController
                                                                  .text =
                                                              fetchservice
                                                                  .roundToNearestQuarter(
                                                                      subtotal,
                                                                      minimumFare)
                                                                  .toStringAsFixed(
                                                                      2);
                                                          if (coopData[
                                                                  'coopType'] ==
                                                              "Jeepney") {
                                                            subtotal = fetchService
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare);
                                                          }
                                                          print(
                                                              'current price: $price');
                                                          if (baggageOnly) {
                                                            passengerType = "";
                                                            subtotal =
                                                                baggageprice;
                                                            editAmountController
                                                                    .text =
                                                                fetchservice
                                                                    .roundToNearestQuarter(
                                                                        subtotal,
                                                                        minimumFare)
                                                                    .toStringAsFixed(
                                                                        2);
                                                          }
                                                        }
                                                      });
                                                    }

                                                    // Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: passengerType ==
                                                            'senior'
                                                        ? Color(0xff00558d)
                                                        : Color(
                                                            0xFF46aef2), // Background color of the button
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Border radius
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'SENIOR',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (passengerType !=
                                                        'student') {
                                                      setState(() {
                                                        passengerType =
                                                            'student';
                                                        ismissingPassengerType =
                                                            false;
                                                        if (!isDiscounted) {
                                                          isDiscounted = true;
                                                          double baggageprice =
                                                              0;
                                                          if (baggagePrice.text
                                                                  .trim() !=
                                                              '') {
                                                            baggageprice =
                                                                double.parse(
                                                                    baggagePrice
                                                                        .text);
                                                          }
                                                          //   // price = (price*discountPercent);

                                                          //   discount = price * discountPercent;

                                                          //   subtotal =
                                                          //       subtotal - discount;
                                                          // } else {

                                                          // }
                                                          discount = price *
                                                              discountPercent;

                                                          subtotal = ((price -
                                                                      discount) *
                                                                  quantity) +
                                                              baggageprice;
                                                          editAmountController
                                                                  .text =
                                                              fetchservice
                                                                  .roundToNearestQuarter(
                                                                      subtotal,
                                                                      minimumFare)
                                                                  .toStringAsFixed(
                                                                      2);
                                                          if (coopData[
                                                                  'coopType'] ==
                                                              "Jeepney") {
                                                            subtotal = fetchService
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare);
                                                          }
                                                          if (baggageOnly) {
                                                            passengerType = "";
                                                            subtotal =
                                                                baggageprice;
                                                            editAmountController
                                                                    .text =
                                                                fetchservice
                                                                    .roundToNearestQuarter(
                                                                        subtotal,
                                                                        minimumFare)
                                                                    .toStringAsFixed(
                                                                        2);
                                                          }
                                                        }
                                                      });
                                                    }

                                                    // Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: passengerType ==
                                                            'student'
                                                        ? Color(0xff00558d)
                                                        : Color(
                                                            0xFF46aef2), // Background color of the button
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Border radius
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'STUDENT',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (passengerType !=
                                                        'pwd') {
                                                      setState(() {
                                                        passengerType = 'pwd';
                                                        ismissingPassengerType =
                                                            false;
                                                        if (!isDiscounted) {
                                                          isDiscounted = true;
                                                          double baggageprice =
                                                              0;
                                                          if (baggagePrice.text
                                                                  .trim() !=
                                                              '') {
                                                            baggageprice =
                                                                double.parse(
                                                                    baggagePrice
                                                                        .text);
                                                          }
                                                          //   // price = (price*discountPercent);

                                                          //   discount = price * discountPercent;

                                                          //   subtotal =
                                                          //       subtotal - discount;
                                                          // } else {

                                                          // }
                                                          discount = price *
                                                              discountPercent;

                                                          subtotal = ((price -
                                                                      discount) *
                                                                  quantity) +
                                                              baggageprice;
                                                          editAmountController
                                                                  .text =
                                                              subtotal
                                                                  .toStringAsFixed(
                                                                      2);
                                                          if (coopData[
                                                                  'coopType'] ==
                                                              "Jeepney") {
                                                            subtotal = fetchService
                                                                .roundToNearestQuarter(
                                                                    subtotal,
                                                                    minimumFare);
                                                          }
                                                          if (baggageOnly) {
                                                            passengerType = "";
                                                            subtotal =
                                                                baggageprice;
                                                            editAmountController
                                                                    .text =
                                                                subtotal
                                                                    .toString();
                                                          }
                                                        }
                                                      });
                                                    }

                                                    // Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: passengerType ==
                                                            'pwd'
                                                        ? Color(0xff00558d)
                                                        : Color(
                                                            0xFF46aef2), // Background color of the button
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Border radius
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'PWD',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'Baggage Only',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0, left: 16),
                                                  child: Transform.scale(
                                                    scale: 1.1,
                                                    child: Checkbox(
                                                        activeColor:
                                                            Color.fromARGB(255,
                                                                0, 80, 109),
                                                        value: baggageOnly,
                                                        onChanged: (value) {
                                                          double baggageprice =
                                                              0.00;
                                                          if (baggagePrice
                                                                  .text !=
                                                              '') {
                                                            baggageprice =
                                                                double.parse(
                                                                    baggagePrice
                                                                        .text);
                                                          }
                                                          setState(() {
                                                            baggageOnly =
                                                                !baggageOnly;

                                                            if (baggageOnly) {
                                                              passengerType =
                                                                  "";
                                                              subtotal =
                                                                  baggageprice;
                                                              editAmountController
                                                                      .text =
                                                                  "$subtotal";
                                                              quantity = 1;
                                                              price = 0;
                                                            } else {
                                                              quantity = 1;
                                                              subtotal = ((price -
                                                                          discount) *
                                                                      quantity) +
                                                                  baggageprice;
                                                              editAmountController
                                                                      .text =
                                                                  subtotal
                                                                      .toString();
                                                            }
                                                          });
                                                        }),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.white),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextFormField(
                                                            controller:
                                                                baggagePrice,
                                                            textAlign: TextAlign
                                                                .center,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <TextInputFormatter>[
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly, // Allow only digits (0-9)
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly, // Prevent line breaks
                                                            ],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'ENTER THE BAGGAGE',
                                                                    hintStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Color(
                                                                            0xff46aef2)),
                                                            onEditingComplete:
                                                                () {
                                                              try {
                                                                double
                                                                    baggageprice =
                                                                    double.parse(
                                                                        baggagePrice
                                                                            .text);
                                                                setState(() {
                                                                  if (baggageOnly) {
                                                                    passengerType =
                                                                        "";
                                                                    subtotal =
                                                                        baggageprice;
                                                                  } else {
                                                                    subtotal = ((price -
                                                                                discount) *
                                                                            quantity) +
                                                                        baggageprice;
                                                                  }

                                                                  editAmountController
                                                                          .text =
                                                                      subtotal
                                                                          .toString();
                                                                });
                                                                print(
                                                                    'baggage error not');
                                                              } catch (e) {
                                                                print(
                                                                    'baggage error $e');
                                                                subtotal = (price -
                                                                        discount) *
                                                                    quantity;
                                                                editAmountController
                                                                        .text =
                                                                    subtotal
                                                                        .toString();
                                                              }
                                                            },
                                                          ),
                                                        ]),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (checkifValid()) {
                                                    _startNFCReader(
                                                        'mastercard');
                                                    // if (!isNoMasterCard) {
                                                    //   setState(() {
                                                    //     isNfcScanOn = true;
                                                    //   });
                                                    //   _showDialognfcScan(context,
                                                    //       'MASTER CARD', 'master-card.png');
                                                    // }
                                                  }
                                                },
                                                child: typeofCardsWidget(
                                                    title: isNoMasterCard
                                                        ? 'CASH'
                                                        : 'MASTER CARD',
                                                    image: isNoMasterCard
                                                        ? 'cash.png'
                                                        : 'master-card.png'),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            if (!isDiscounted)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (!checkifValid()) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      isNfcScanOn = true;
                                                    });
                                                    _startNFCReader('regular');
                                                    _showDialognfcScan(
                                                        context,
                                                        'FILIPAY CARD',
                                                        'FILIPAY Cards - Regular.png');
                                                  },
                                                  child: typeofCardsWidget(
                                                      title: 'FILIPAY CARD',
                                                      image:
                                                          'FILIPAY Cards - Regular.png'),
                                                ),
                                              ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            if (isDiscounted)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isNfcScanOn = true;
                                                    });
                                                    _startNFCReader(
                                                        'discounted');
                                                    _showDialognfcScan(
                                                        context,
                                                        'DISCOUNTED CARD',
                                                        'FILIPAY Cards - Discounted.png');
                                                  },
                                                  child: typeofCardsWidget(
                                                      title: 'DISCOUNTED CARD',
                                                      image:
                                                          'FILIPAY Cards - Discounted.png'),
                                                ),
                                              ),
                                          ],
                                        )
                                      ],
                                    );
                                  }),
                                ],
                              )),
                            )),
                      ],
                    ),
                  ),
                ),
              ));
        }).then((value) {
      double baggageprice = 0.00;
      if (baggagePrice.text != '') {
        baggageprice = double.parse(baggagePrice.text);
      }
      setState(() {
        if (baggageOnly) {
          passengerType = "";
          subtotal = baggageprice;
          editAmountController.text = fetchservice
              .roundToNearestQuarter(subtotal, minimumFare)
              .toStringAsFixed(2);
          price = 0;
        } else {
          if (coopData['coopType'] == "Jeepney") {
            subtotal = (fetchservice.roundToNearestQuarter(price, minimumFare) -
                    discount * quantity) +
                baggageprice;
          } else {
            subtotal = (price - discount * quantity) + baggageprice;
          }

          editAmountController.text = fetchservice
              .roundToNearestQuarter(subtotal, minimumFare)
              .toStringAsFixed(2);
        }
      });
    });
  }

  void _showTapVerificationCard(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'VERIFY CARD',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/master-card.png',
                                width: 150,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.asset('assets/nfc.png',
                                        width: 70),
                                  ))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  void _updateAmount(bool isthisDiscounted) {
    double baggageprice = 0;
    double stationKM =
        (double.parse((selectedDestination['km'] ?? 0.0).toString()) -
                double.parse(stations[currentStationIndex]['km'].toString()))
            .abs();
    try {
      baggageprice = double.parse(baggagePrice.text);
    } catch (e) {
      print(e);
    }
    setState(() {
      if (baggageOnly) {
        price = 0;
        discount = 0;
      } else {
        if (stationKM <= firstKM) {
          // If the total distance is 4 km or less, the cost is fixed.
          price = minimumFare;
        } else {
          price = stationKM * pricePerKm;
        }
        if (isthisDiscounted) {
          discount = price * discountPercent;
        } else {
          discount = 0;
        }
      }

      subtotal = price - discount + baggageprice;
      kmRun = "$stationKM";
      toKM = double.parse("${selectedDestination['km']}");
    });
  }
}

class typeofCardsWidget extends StatelessWidget {
  const typeofCardsWidget(
      {super.key, required this.title, required this.image});
  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.17,
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/$image',
              width: 50,
              height: 50,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$title',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ]),
      ),
    );
  }
}

class buttonBottomWidget extends StatelessWidget {
  const buttonBottomWidget(
      {super.key,
      required this.title,
      required this.image,
      required this.passengerType,
      required this.isDiscounted,
      required this.missing});
  final String title;
  final String image;
  final String passengerType;
  final bool isDiscounted;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    String newimage = image;
    if (title == 'PASSENGER TYPE') {
      if (passengerType == 'senior') {
        newimage = 'discounted-old.png';
      }
      if (passengerType == 'pwd') {
        newimage = 'pwd.png';
      }
      if (passengerType == 'student') {
        newimage = 'student.png';
      }
    }

    print('newimage: $newimage');
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xffb5e1ee),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    width: missing ? 5 : 2,
                    color: missing ? Colors.red : Color(0xff55a2d8))),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/$newimage',
                  width: 50,
                  height: 50,
                )),
          ),
          SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$title',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ticketingmenuWidget extends StatelessWidget {
  const ticketingmenuWidget(
      {super.key, required this.title, required this.count});
  final String title;
  final double count;

  String formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString(); // Display as an integer
    } else {
      return value
          .toStringAsFixed(1); // Display as a double with 1 decimal place
    }
  }

  @override
  Widget build(BuildContext context) {
    String newcount = formatDouble(count);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 2), // Shadow position (horizontal, vertical)
              blurRadius: 4.0, // Spread of the shadow
              spreadRadius: 1.0, // Expanding the shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$newcount',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
