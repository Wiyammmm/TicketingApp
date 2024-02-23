import 'dart:ffi';
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
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
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

  Map<dynamic, dynamic> sessionBox = {};
  fetchServices fetchService = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  TestPrinttt printService = TestPrinttt();
  double discount = 0.0;

  String bound = '';
  String route = '';
  String passengerType = '';
  String typeofCards = '';
  bool isFix = true;
  String selectedStationID = '';

  bool ismissingPassengerType = false;
  bool isDiscounted = false;
  String selectedStationName = '';
  int rowNo = 0;
  int quantity = 1;

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

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
  TextEditingController baggagePrice = TextEditingController();
  TextEditingController editAmountController = TextEditingController();
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

    if (isFix) {
      if (storedData['selectedDestination'].isNotEmpty) {
        selectedDestination = storedData['selectedDestination'];
        rowNo =
            int.parse(storedData['selectedDestination']['rowNo'].toString());

        double stationKM = (double.parse(
                    (selectedDestination[stationkm] ?? 0).toString()) -
                double.parse(
                    (stations[currentStationIndex][stationkm] ?? 0).toString()))
            .abs();
        double baggageprice = 0.00;
        if (baggagePrice.text != '') {
          baggageprice = double.parse(baggagePrice.text);
        }
        setState(() {
          print(
              'currentstation km: ${stations[currentStationIndex][stationkm]}');
          selectedStationID = selectedDestination['_id'];

          storedData['selectedDestination'] = selectedDestination;

          toKM = double.parse(selectedDestination[stationkm].toString()) ?? 0.0;

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
    }
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
      if (passengerType != "regular") {
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
          if (passengerType != '') {
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
            if (baggagePrice.text != '') {
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
      if (coopData['coopType'] != "Bus") {
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
                    : "CHOOSE PASSENGER TYPE FIRST"));
        return false;
      } else {
        if (baggageprice <= 0) {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INCOMPLETE",
                  text: "INPUT BAGGAGE AMOUNT"));
          return false;
        } else {
          return true;
        }
      }
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
            child: SingleChildScrollView(
          child: Column(
            children: [
              appbar(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: Color(0xFF00558d),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: fetchService.getIsNumeric()
                        ? Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$formattedDate',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                    // color: Color(0xFFd9d9d9),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (coopData['coopDType'] == "Bus")
                                          Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            decoration: BoxDecoration(
                                                color: Color(0xff46aef2),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'FIX',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Transform.scale(
                                                    scale: 2.0,
                                                    child: Checkbox(
                                                      value: isFix,
                                                      fillColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color?>(
                                                        (Set<MaterialState>
                                                            states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .pressed)) {
                                                            return Colors
                                                                .blue; // Color when the button is pressed
                                                          }
                                                          if (states.contains(
                                                              MaterialState
                                                                  .disabled)) {
                                                            return Colors
                                                                .grey; // Color when the button is disabled
                                                          }
                                                          return Color(
                                                              0xff18467e); // Default color
                                                        },
                                                      ),
                                                      side: BorderSide(
                                                          width: 2,
                                                          color: Colors.white),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          isFix = value!;
                                                          storedData['isFix'] =
                                                              isFix;
                                                          if (isFix) {
                                                            storedData[
                                                                    'selectedDestination'] =
                                                                selectedDestination;

                                                            _myBox.put(
                                                                'SESSION',
                                                                storedData);
                                                          } else {
                                                            print(
                                                                'isFix _myBox: ${storedData['isFix']}');
                                                            _myBox.put(
                                                                'SESSION',
                                                                storedData);
                                                          }

                                                          print(
                                                              'isFix: $isFix');
                                                        });
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        // Container(
                                        //   width: MediaQuery.of(context)
                                        //           .size
                                        //           .width *
                                        //       0.3,
                                        //   decoration: BoxDecoration(
                                        //       color: Color(0xff46aef2),
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
                                        GestureDetector(
                                          onTap: () {
                                            print('tama');
                                            if (coopData['coopType'] == "Bus") {
                                              _showDialogMenu(context);
                                            } else {
                                              setState(() {
                                                isNfcScanOn = true;
                                              });
                                              _verificationCard();
                                              _showTapVerificationCard(context);
                                            }
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: coopData['coopType'] == "Bus"
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                            decoration: BoxDecoration(
                                                color: Color(0xff46aef2),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'MENU',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${bound.toUpperCase()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 75,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
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
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // textfieldamount
                                          GestureDetector(
                                            onTap: () {
                                              _showDialogJeepneyTicketing(
                                                  context);
                                            },
                                            child: SizedBox(
                                              height: 30,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: TextField(
                                                controller:
                                                    editAmountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                enabled: false,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 10),
                                                  border: InputBorder.none,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                onSubmitted: (value) {
                                                  setState(() {
                                                    price = double.parse(value);
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$route',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: coopData['coopType'] == "Bus"
                                    ? MediaQuery.of(context).size.height * 0.3
                                    : MediaQuery.of(context).size.height * 0.45,
                                width: MediaQuery.of(context).size.width,
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                2, // 2 items per row

                                            childAspectRatio: 2),
                                    itemCount: stations.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final station = stations[index];
                                      double amount = double.parse(
                                          stations[index]['amount'].toString());
                                      bool isselectedStationID = false;
                                      if (station['_id'] == selectedStationID) {
                                        isselectedStationID = true;
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          if (isFix) return;
                                          setState(() {
                                            rowNo = station['rowNo'];

                                            print(
                                                'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                            selectedStationID = station['_id'];

                                            selectedDestination = station;
                                            print(
                                                'selectedDestination: $selectedDestination');

                                            selectedStationName =
                                                station['stationName'] ?? "";
                                            print(
                                                'selectedStationName: $selectedStationName');

                                            double stationKM = (double.parse(
                                                        station[stationkm] ??
                                                            0.toString()) -
                                                    double.parse(stations[
                                                                currentStationIndex]
                                                            [stationkm] ??
                                                        0.toString()))
                                                .abs();
                                            if (fetchService.getIsNumeric()) {
                                              price = double.parse(
                                                  station['amount'].toString());
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

                                                if (coopData['coopType'] !=
                                                    "Bus") {
                                                  double succeedingprice =
                                                      succeedingPrice(
                                                          stationKM - firstKM);
                                                  print(
                                                      "succeedingprice: $succeedingprice");
                                                  price = minimumFare +
                                                      ((stationKM - firstKM) *
                                                          pricePerKm);
                                                  // price = minimumFare +
                                                  //     succeedingprice;
                                                } else {
                                                  price =
                                                      stationKM * pricePerKm;
                                                }
                                              }
                                            }
                                            print(
                                                'passenger Type: $passengerType');
                                            print('discount: $discount');

                                            if (isDiscounted) {
                                              discount =
                                                  price * discountPercent;
                                              subtotal = amount - discount;
                                            } else {
                                              subtotal = amount;
                                            }

                                            editAmountController.text =
                                                fetchservice
                                                    .roundToNearestQuarter(
                                                        subtotal, minimumFare)
                                                    .toStringAsFixed(2);
                                          });
                                          if (coopData['coopType'] ==
                                              "Jeepney") {
                                            print('show dialog for jeepney');
                                            _showDialogJeepneyTicketing(
                                                context);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: isselectedStationID
                                                    ? Color(0xff00558d)
                                                    : Color(0xff46aef2),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.white)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  // '(${station[stationkm] - stations[currentStationIndex][stationkm]})',
                                                  '₱${isDltb ? amount.round() : amount.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              if (coopData['coopType'] == "Bus")
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showDialogPassengerType(context);
                                      },
                                      child: buttonBottomWidget(
                                        title: 'PASSENGER TYPE',
                                        image: 'passenger.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: ismissingPassengerType,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (checkifValid()) {
                                          _showDialogBaggage(context);
                                        }
                                        // if (selectedStationName == '') {
                                        //   ArtSweetAlert.show(
                                        //       context: context,
                                        //       artDialogArgs: ArtDialogArgs(
                                        //           type: ArtSweetAlertType.danger,
                                        //           title: "INCOMPLETE",
                                        //           text: "PLEASE CHOOSE STATION"));
                                        // } else {
                                        //   _showDialogBaggage(context);
                                        // }
                                      },
                                      child: buttonBottomWidget(
                                        title: 'BAGGAGE',
                                        image: 'baggage.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: false,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print('subtotalzz: $subtotal');
                                        if (checkifValid()) {
                                          _showDialogTypeCards(context);
                                        }
                                        // if (checkifValid()) {

                                        // if (int.parse(kmRun) >= 0) {
                                        //   if (passengerType != '' ||
                                        //       baggagePrice.text.trim() != '') {

                                        //   } else {
                                        //     ArtSweetAlert.show(
                                        //         context: context,
                                        //         artDialogArgs: ArtDialogArgs(
                                        //             type:
                                        //                 ArtSweetAlertType.warning,
                                        //             title: "INVALID",
                                        //             text:
                                        //                 "PLEASE CHOOSE PASSENGER TYPE\nOR INPUT BAGGAGE PRICE"));
                                        //   }
                                        // } else {

                                        //   ArtSweetAlert.show(
                                        //       context: context,
                                        //       artDialogArgs: ArtDialogArgs(
                                        //           type: ArtSweetAlertType.warning,
                                        //           title: "INVALID",
                                        //           text: "PLEASE CHOOSE STATION"));
                                        // }

                                        // }
                                      },
                                      child: buttonBottomWidget(
                                        title:
                                            isNoMasterCard ? 'PAYMENT' : 'CARD',
                                        image: isNoMasterCard
                                            ? 'cash.png'
                                            : 'filipay-cards.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: false,
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$formattedDate',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${bound.toUpperCase()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (coopData['coopType'] != "Bus") {
                                        _showDialogJeepneyTicketing(context);
                                      }
                                    },
                                    child: Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              width: 2, color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Column(
                                            children: [
                                              Text(
                                                'AMOUNT',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${isDltb ? subtotal.round() : subtotal.toStringAsFixed(2)}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: isDiscounted
                                                        ? Colors.orangeAccent
                                                        : Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$route',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                    color: Color(0xFFd9d9d9),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        if (coopData['coopType'] == "Bus")
                                          Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            decoration: BoxDecoration(
                                                color: Color(0xff46aef2),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'FIX',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Transform.scale(
                                                    scale: 2.0,
                                                    child: Checkbox(
                                                      value: isFix,
                                                      fillColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color?>(
                                                        (Set<MaterialState>
                                                            states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .pressed)) {
                                                            return Colors
                                                                .blue; // Color when the button is pressed
                                                          }
                                                          if (states.contains(
                                                              MaterialState
                                                                  .disabled)) {
                                                            return Colors
                                                                .grey; // Color when the button is disabled
                                                          }
                                                          return Color(
                                                              0xff18467e); // Default color
                                                        },
                                                      ),
                                                      side: BorderSide(
                                                          width: 2,
                                                          color: Colors.white),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          isFix = value!;
                                                          storedData['isFix'] =
                                                              isFix;
                                                          if (isFix) {
                                                            storedData[
                                                                    'selectedDestination'] =
                                                                selectedDestination;

                                                            _myBox.put(
                                                                'SESSION',
                                                                storedData);
                                                          } else {
                                                            print(
                                                                'isFix _myBox: ${storedData['isFix']}');
                                                            _myBox.put(
                                                                'SESSION',
                                                                storedData);
                                                          }

                                                          print(
                                                              'isFix: $isFix');
                                                        });
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        Container(
                                          width: coopData['coopType'] == "Bus"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                          decoration: BoxDecoration(
                                              color: Color(0xff46aef2),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'KM RUN',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.white,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '$kmRun',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            print('tama');
                                            if (coopData['coopType'] == "Bus") {
                                              _showDialogMenu(context);
                                            } else {
                                              setState(() {
                                                isNfcScanOn = true;
                                              });
                                              _verificationCard();
                                              _showTapVerificationCard(context);
                                            }
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                                color: Color(0xff46aef2),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'MENU',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                ),
                              ),
                              SizedBox(
                                height: 20,
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
                                        if (currentStationIndex >= 0) {
                                          print(stations[currentStationIndex]
                                              ['stationName']);
                                          storedData['currentStationIndex'] =
                                              currentStationIndex;
                                          print(
                                              "currentStationIndex: $currentStationIndex");
                                          _myBox.put('SESSION', storedData);
                                          print(
                                              'Data in Hive box: $storedData');
                                          // selectedDestination =
                                          //     storedData['selectedDestination'];
                                          if (selectedDestination.isNotEmpty) {
                                            double stationKM = (double.parse(
                                                        selectedDestination[
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
                                              print(
                                                  'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                              selectedStationID =
                                                  selectedDestination['_id'];

                                              storedData[
                                                      'selectedDestination'] =
                                                  selectedDestination;

                                              toKM = double.parse(
                                                  selectedDestination[stationkm]
                                                      .toString());

                                              selectedStationName =
                                                  selectedDestination[
                                                      'stationName'];
                                              print(
                                                  'selectedStationName: $selectedStationName');
                                              // price = (pricePerKM * stationKM);
                                              if (fetchService.getIsNumeric()) {
                                                price = double.parse(
                                                    coopData['amount']
                                                        .toString());
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
                                                  if (coopData['coopType'] !=
                                                      "Bus") {
                                                    price = minimumFare +
                                                        ((stationKM - firstKM) *
                                                            pricePerKm);
                                                  } else {
                                                    price =
                                                        stationKM * pricePerKm;
                                                  }
                                                }
                                              }

                                              print(
                                                  'passenger Type: $passengerType');
                                              print('discount: $discount');

                                              if (isDiscounted) {
                                                discount =
                                                    price * discountPercent;
                                              }
                                              subtotal = (price -
                                                      discount +
                                                      baggageprice) *
                                                  quantity;
                                              editAmountController.text =
                                                  fetchservice
                                                      .roundToNearestQuarter(
                                                          subtotal, minimumFare)
                                                      .toStringAsFixed(2);

                                              kmRun = formatDouble(stationKM);
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
                                        primary: Colors
                                            .transparent, // Background color of the button
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white),
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Border radius
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.chevron_left_sharp,
                                        color: Colors.white,
                                      )),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${stations[currentStationIndex]['stationName']}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (isFix) return;
                                        if (currentStationIndex + 2 ==
                                            stations.length) {
                                          if (!fetchservice.getIsNumeric() &&
                                              coopData['coopType'] ==
                                                  "Jeepney") {
                                            await ArtSweetAlert.show(
                                                context: context,
                                                barrierDismissible: false,
                                                artDialogArgs: ArtDialogArgs(
                                                    type:
                                                        ArtSweetAlertType.info,
                                                    showCancelBtn: true,
                                                    cancelButtonText: 'NO',
                                                    confirmButtonText: 'YES',
                                                    title: "REVERSE",
                                                    onConfirm: () {
                                                      setState(() {
                                                        sessionBox[
                                                                'isViceVersa'] =
                                                            !sessionBox[
                                                                'isViceVersa'];
                                                        sessionBox[
                                                            'currentStationIndex'] = 0;
                                                        sessionBox[
                                                            'reverseNum'] += 1;
                                                        _myBox.put('SESSION',
                                                            sessionBox);
                                                        currentStationIndex = 0;
                                                        stations = stations
                                                            .reversed
                                                            .toList();
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    onDeny: () {
                                                      print('deny');
                                                      Navigator.of(context)
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
                                          print(stations[currentStationIndex]
                                              ['stationName']);
                                          storedData['currentStationIndex'] =
                                              currentStationIndex;

                                          print(
                                              "currentStationIndex: $currentStationIndex");
                                          _myBox.put('SESSION', storedData);
                                          print(
                                              'Data in Hive box: $storedData');

                                          if (selectedDestination.isNotEmpty) {
                                            // selectedDestination =
                                            //     storedData['selectedDestination'];

                                            double stationKM = (double.parse(
                                                        selectedDestination[
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
                                              print(
                                                  'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                              selectedStationID =
                                                  selectedDestination['_id'];

                                              storedData[
                                                      'selectedDestination'] =
                                                  selectedDestination;

                                              toKM = double.parse(
                                                  selectedDestination[stationkm]
                                                      .toString());

                                              selectedStationName =
                                                  selectedDestination[
                                                      'stationName'];
                                              print(
                                                  'selectedStationName: $selectedStationName');
                                              // price = (pricePerKM * stationKM);
                                              if (fetchService.getIsNumeric()) {
                                                price = double.parse(
                                                    coopData['amount']
                                                        .toString());
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

                                                  if (coopData['coopType'] !=
                                                      "Bus") {
                                                    price = minimumFare +
                                                        ((stationKM - firstKM) *
                                                            pricePerKm);
                                                  } else {
                                                    price =
                                                        stationKM * pricePerKm;
                                                  }
                                                }
                                              }
                                              print(
                                                  'passenger Type: $passengerType');
                                              print('discount: $discount');

                                              if (isDiscounted) {
                                                discount =
                                                    price * discountPercent;
                                              }
                                              subtotal = (price -
                                                      discount +
                                                      baggageprice) *
                                                  quantity;
                                              editAmountController.text =
                                                  fetchservice
                                                      .roundToNearestQuarter(
                                                          subtotal, minimumFare)
                                                      .toStringAsFixed(2);
                                              if (coopData['coopType'] ==
                                                  "Jeepney") {
                                                subtotal = fetchService
                                                    .roundToNearestQuarter(
                                                        subtotal, minimumFare);
                                              }

                                              kmRun = formatDouble(stationKM);
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
                                        primary: Colors
                                            .transparent, // Background color of the button
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white),
                                          borderRadius: BorderRadius.circular(
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
                                height: coopData['coopType'] == "Bus"
                                    ? MediaQuery.of(context).size.height * 0.3
                                    : MediaQuery.of(context).size.height * 0.45,
                                width: MediaQuery.of(context).size.width,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2, // 2 items per row

                                          childAspectRatio: 2),
                                  itemCount:
                                      stations.length - currentStationIndex - 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final station = stations[
                                        index + currentStationIndex + 1];
                                    double price2 = 0;
                                    bool isselectedStationID = false;
                                    if (station['_id'] == selectedStationID) {
                                      isselectedStationID = true;
                                    }

                                    double stationKM2 = (double.parse(
                                                station[stationkm].toString()) -
                                            double.parse(
                                                stations[currentStationIndex]
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

                                      if (coopData['coopType'] != "Bus") {
                                        price2 = minimumFare +
                                            ((stationKM2 - firstKM) *
                                                pricePerKm);
                                      } else {
                                        price2 = stationKM2 * pricePerKm;
                                      }
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        if (isFix) return;
                                        // final storedData = _myBox.get('SESSION');
                                        final station = stations[
                                            index + currentStationIndex + 1];

                                        double stationKM = (double.parse(
                                                    station[stationkm]
                                                        .toString()) -
                                                double.parse(stations[
                                                            currentStationIndex]
                                                        [stationkm]
                                                    .toString()))
                                            .abs();
                                        double baggageprice = 0.00;

                                        if (baggagePrice.text != '') {
                                          baggageprice =
                                              double.parse(baggagePrice.text);
                                        }

                                        setState(() {
                                          rowNo = station['rowNo'];

                                          if (fetchService.getIsNumeric()) {
                                            price = double.parse(
                                                coopData['amount'].toString());
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

                                              if (coopData['coopType'] !=
                                                  "Bus") {
                                                double succeedingprice =
                                                    succeedingPrice(
                                                        stationKM - firstKM);
                                                print(
                                                    "succeedingprice: $succeedingprice");
                                                price = minimumFare +
                                                    ((stationKM - firstKM) *
                                                        pricePerKm);
                                                // price = minimumFare +
                                                //     succeedingprice;
                                              } else {
                                                price = stationKM * pricePerKm;
                                              }
                                            }
                                          }
                                          print(
                                              'currentstation km: ${stations[currentStationIndex][stationkm]}');
                                          selectedStationID = station['_id'];

                                          selectedDestination = station;
                                          print(
                                              'selectedDestination: $selectedDestination');
                                          toKM = double.parse(
                                              station[stationkm].toString());

                                          selectedStationName =
                                              station['stationName'];
                                          print(
                                              'selectedStationName: $selectedStationName');
                                          // price = (pricePerKM * stationKM);

                                          print(
                                              'passenger Type: $passengerType');
                                          print('discount: $discount');

                                          if (isDiscounted) {
                                            discount = price * discountPercent;
                                          }
                                          subtotal = (price -
                                                  discount +
                                                  baggageprice) *
                                              quantity;
                                          if (coopData['coopType'] ==
                                              "Jeepney") {
                                            subtotal = fetchService
                                                .roundToNearestQuarter(
                                                    subtotal, minimumFare);
                                          }
                                          editAmountController.text =
                                              fetchservice
                                                  .roundToNearestQuarter(
                                                      subtotal, minimumFare)
                                                  .toStringAsFixed(2);
                                          kmRun = formatDouble(stationKM);
                                        });
                                        print('price: $price');
                                        if (coopData['coopType'] == "Jeepney") {
                                          print('show dialog for jeepney');
                                          _showDialogJeepneyTicketing(context);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: isselectedStationID
                                                  ? Color(0xff00558d)
                                                  : Color(0xff46aef2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.white)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                // '(${station[stationkm] - stations[currentStationIndex][stationkm]})',
                                                '₱${isDltb ? price2.round() : fetchservice.roundToNearestQuarter(price2, minimumFare).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                    '${station['stationName']}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                              if (coopData['coopType'] == "Bus")
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showDialogPassengerType(context);
                                      },
                                      child: buttonBottomWidget(
                                        title: 'PASSENGER TYPE',
                                        image: 'passenger.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: ismissingPassengerType,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (selectedStationName == '') {
                                          ArtSweetAlert.show(
                                              context: context,
                                              artDialogArgs: ArtDialogArgs(
                                                  type:
                                                      ArtSweetAlertType.danger,
                                                  title: "INCOMPLETE",
                                                  text:
                                                      "PLEASE CHOOSE STATION"));
                                        } else {
                                          _showDialogBaggage(context);
                                        }
                                      },
                                      child: buttonBottomWidget(
                                        title: 'BAGGAGE',
                                        image: 'baggage.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: false,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (!checkifValid()) {
                                          return;
                                        }
                                        // if (checkifValid()) {
                                        if (int.parse(kmRun) >= 0) {
                                          if (passengerType != '' ||
                                              baggagePrice.text.trim() != '') {
                                            _showDialogTypeCards(context);
                                          } else {
                                            ArtSweetAlert.show(
                                                context: context,
                                                artDialogArgs: ArtDialogArgs(
                                                    type: ArtSweetAlertType
                                                        .warning,
                                                    title: "INVALID",
                                                    text:
                                                        "PLEASE CHOOSE PASSENGER TYPE\nOR INPUT BAGGAGE PRICE"));
                                          }
                                        } else {
                                          ArtSweetAlert.show(
                                              context: context,
                                              artDialogArgs: ArtDialogArgs(
                                                  type:
                                                      ArtSweetAlertType.warning,
                                                  title: "INVALID",
                                                  text:
                                                      "PLEASE CHOOSE STATION"));
                                        }

                                        // }
                                      },
                                      child: buttonBottomWidget(
                                        title:
                                            isNoMasterCard ? 'PAYMENT' : 'CARD',
                                        image: isNoMasterCard
                                            ? 'cash.png'
                                            : 'filipay-cards.png',
                                        passengerType: passengerType,
                                        isDiscounted: isDiscounted,
                                        missing: false,
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                  ),
                ),
              )
            ],
          ),
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
                color: Color(0xFF00558d),
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
                                      color: Color(0xFF00558d),
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
                                          primary: Color(
                                              0xFF00adee), // Background color of the button
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
                                          primary: Color(
                                              0xFF00adee), // Background color of the button
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
                                    fillColor: Color(0xff46aef2)),
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
                                      color: Color(0xff00558d),
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
                    color: Color(0xFF46aef2),
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
                                            width: 2, color: Color(0xFF46aef2)),
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
                                                color: Color(0xFF46aef2),
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
                                                  color: Color(0xFF46aef2),
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
                                                    color: Color(0xFF46aef2))),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF46aef2),
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
                                                          color:
                                                              Color(0xFF46aef2),
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
                                                    color: Color(0xFF46aef2))),
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
                    color: Color(0xFF46aef2),
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
          color: Color(0xff46aef2), borderRadius: BorderRadius.circular(10)),
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
          color: Color(0xFF00558d),
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
