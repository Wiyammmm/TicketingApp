import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/inspectorMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

class InspectionSummaryPage extends StatefulWidget {
  const InspectionSummaryPage({super.key, required this.inspectorData});
  final inspectorData;
  @override
  State<InspectionSummaryPage> createState() => _InspectionSummaryPageState();
}

class _InspectionSummaryPageState extends State<InspectionSummaryPage> {
  final _myBox = Hive.box('myBox');
  timeServices dateservice = timeServices();
  fetchServices fetchservice = fetchServices();
  TestPrinttt printService = TestPrinttt();
  timeServices timeService = timeServices();

  httprequestService httprequestServices = httprequestService();
  GeneratorServices generatorServices = GeneratorServices();

  HiveService hiveservices = HiveService();
  // text editing controller
  TextEditingController ticketIssuedController = TextEditingController();
  TextEditingController headCountController = TextEditingController(text: "0");
  TextEditingController baggageCountController =
      TextEditingController(text: "0");
  TextEditingController passengerController = TextEditingController();
  TextEditingController baggageController = TextEditingController();
  TextEditingController kmPostController = TextEditingController();
  TextEditingController discrepancyController = TextEditingController();
  TextEditingController onboardplaceController = TextEditingController();
  String? selectedOnboardPlace;
  TextEditingController baggageOnlyController = TextEditingController();
  TextEditingController baggageWithPassengerController =
      TextEditingController();
  TextEditingController passengerTransferController =
      TextEditingController(text: "0");
  TextEditingController passengerWithPassController =
      TextEditingController(text: "0");
  TextEditingController passengerWithPrepaidController =
      TextEditingController(text: "0");
  // end text editing controller

  bool isTicket = false;
  List<Map<String, dynamic>> torTicket = [];
  List<Map<String, dynamic>> torTrip = [];
  List<Map<String, dynamic>> employeeList = [];
  List<Map<String, dynamic>> stations = [];
  Map<String, dynamic> SESSION = {};
  Map<String, dynamic> inspectorData = {};
  Map<String, dynamic> coopData = {};
  List<Map<String, dynamic>> filteredTickets = [];

  String torNo = '';
  String driverName = '';
  String conductorName = '';
  String vehicleNo = '';

  int onboardPassenger = 0;
  int onboardBaggage = 0;
  int allBaggage = 0;
  int allpassengerTicket = 0;
  List<Map<String, dynamic>> printTicketWillPass = [];
  List<Map<String, dynamic>> onboardfilteredTorTicket = [];
  List<Map<String, dynamic>> filteredTorTicket = [];
  List<Map<String, dynamic>> filteredStations = [];
  // List<Map<String, dynamic>> filteredTorBagage = [];
  String route = '';
  String control_no = '';
  double currentKM = 0;
  List<String> stationNames = [];

  @override
  void initState() {
    super.initState();
    coopData = fetchservice.fetchCoopData();
    torTicket = fetchservice.fetchallPerTripTicket();
    allpassengerTicket = fetchservice.fetchAllPassengerCount();

    // filteredTorBagage = fetchservice.fetchTorBaggage();
    SESSION = _myBox.get('SESSION');
    torTrip = _myBox.get('torTrip');
    String routeid = SESSION['routeID'];
    inspectorData = widget.inspectorData;
    print('inspectorData: $inspectorData');
    torNo = '${torTrip[SESSION['currentTripIndex']]['tor_no']}';
    vehicleNo = coopData['coopType'] == "Jeepney"
        ? "${torTrip[SESSION['currentTripIndex']]['bus_no']}:${torTrip[SESSION['currentTripIndex']]['plate_number']} "
        : "${torTrip[SESSION['currentTripIndex']]['bus_no']}";
    conductorName = fetchservice.conductorName();
    driverName = fetchservice.driverName();

    route = torTrip[SESSION['currentTripIndex']]['route'];

    print('conductorName: $conductorName');
    print('driverName: $driverName');

    ticketIssuedController.text = '${torTicket.length}';

    print('allBaggage : $allBaggage');

    stations = fetchservice.fetchStationList();
    filteredStations = stations
        .where((station) => station['routeId'].toString() == routeid)
        .toList();

    // Sort the filtered stations based on the 'createdAt' field
    filteredStations.sort((a, b) {
      int orderNumberA = a['rowNo'] ?? 0;
      int orderNumberB = b['rowNo'] ?? 0;
      return orderNumberA.compareTo(orderNumberB);
    });
    print('filteredStations: $filteredStations');
    try {
      currentKM = double.parse(
          filteredStations[SESSION['currentStationIndex']]['km'].toString());
    } catch (e) {
      currentKM = 0;
    }
    kmPostController.text = "$currentKM";
    control_no = torTrip[SESSION['currentTripIndex']]['control_no'].toString();
    print(
        'trip control_no: ${torTrip[SESSION['currentTripIndex']]['control_no']}');
    filteredTorTicket = torTicket;

    for (int i = 0; i < torTicket.length; i++) {
      print('torticket $i: ${torTicket[i]}');
    }
    //     .where((ticket) => ticket['control_no'] == control_no)
    //     .toList();

    // filteredTorBagage = torTicket
    //     .where((ticket) =>
    //         ticket['control_no'] == control_no &&
    //         (ticket['baggage'] is num && ticket['baggage'] > 0))
    //     .toList();

    // print('filteredTorBagage: $filteredTorBagage');
    filteredTickets = torTicket
        .where((ticket) => ticket['control_no'] == control_no)
        .toList();
    if (!fetchservice.getIsNumeric()) {
      baggageOnlyController.text = fetchservice.onBoardBaggageOnly().toString();
      baggageWithPassengerController.text =
          fetchservice.onBoardBaggageWithPassenger().toString();
      onboardBaggage = fetchservice.onBoardBaggage();
      onboardPassenger = fetchservice.onBoardPassenger();
      allBaggage = fetchservice.baggageCount();
      // passengerController.text = '$onboardPassenger';
      passengerController.text =
          '${fetchservice.inspectorOnBoardPassenger(currentKM)}';
      baggageController.text = '$onboardBaggage';
      onboardfilteredTorTicket = torTicket.where((item) {
        double isNegative = item['from_km'] - item['to_km'];

        double kmRun = item['to_km'];
        final torNoInTicket = item['control_no'];

        bool isReverse = false;

        if (isNegative < 0) {
          isReverse = true;
          kmRun = kmRun.abs();
        } else {
          isReverse = false;
        }

        if (kmRun == null || torNoInTicket == null) {
          return false; // Handle missing "km_run" or "tor_no" data
        }
        print('onboardfilteredTorTicket kmrun: $kmRun');
        print('onboardfilteredTorTicket isReverse: $isReverse');
        print('onboardfilteredTorTicket firstkm: ${filteredStations[0]['km']}');
        print('onboardfilteredTorTicket currentKM: $currentKM');
        if (!isReverse) {
          if (kmRun == double.parse(filteredStations[0]['km'].toString())) {
            return kmRun <= currentKM && torNoInTicket == control_no;
          } else {
            return kmRun < currentKM && torNoInTicket == control_no;
          }
        } else {
          if (kmRun == 0) {
            return kmRun >= currentKM && torNoInTicket == control_no;
          } else {
            return kmRun > currentKM && torNoInTicket == control_no;
          }
        }
      }).toList();
      for (int i = 0; i < filteredTorTicket.length; i++) {
        print('filteredTorTicket $i: ${filteredTorTicket[i]}');
      }

      print('onboardfilteredTorTicket: $onboardfilteredTorTicket');

      for (int i = 0; i < onboardfilteredTorTicket.length; i++) {
        print('onboardfilteredTorTicket $i: ${onboardfilteredTorTicket[i]}');
      }
    } else {
      List<Map<String, dynamic>> filteredTicketsPassenger = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no && ticket['fare'] > 0)
          .toList();

      List<Map<String, dynamic>> filteredTicketsBaggageOnly = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['baggage'] > 0 && ticket['fare'] == 0))
          .toList();

      List<Map<String, dynamic>> filteredTicketsBaggageWithPass = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['baggage'] > 0 && ticket['fare'] > 0))
          .toList();

      baggageOnlyController.text = filteredTicketsBaggageOnly.length.toString();
      baggageWithPassengerController.text =
          filteredTicketsBaggageWithPass.length.toString();
      passengerController.text =
          fetchservice.fetchAllPassengerCount().toString();
      baggageController.text = "${fetchservice.baggageCount()}";
    }

    // final driverData = employeeList.firstWhere(
    //   (employee) =>
    //       employee['empNo'] ==
    //       torTrip[SESSION['currentTripIndex']]['driver_id'],
    // );
    // print('driverData: $driverData');
    // driverName =
    //     '${driverData['firstName']} ${driverData['middleName'][0]}. ${driverData['lastName']}';
    try {
      discrepancyController.text =
          "${int.parse(passengerController.text) - int.parse(headCountController.text)}";
    } catch (e) {
      discrepancyController.text = "0";
    }

    findNearestStation(filteredStations, currentKM.toDouble());
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
        String stationName = station['stationName']?.toString() ?? '';

        setState(() {
          stationNames.add(stationName);
        });
      }
    }
    print('stationNames: $stationNames');

    if (stationNames.isNotEmpty) {
      // Concatenate the first and last station names with the same target km
      String firstStationName = stationNames.first;
      String lastStationName = stationNames.last;
      return '$firstStationName - $lastStationName';
    } else {
      setState(() {
        stationNames = filteredStations.map((station) {
          return station['stationName']?.toString() ??
              ''; // Convert to string, handle null
        }).toList();
      });
      return ''; // No stations found with the target km
    }
  }

  void updateOnboardPassenger(double currentkmpost, String control_no) {
    setState(() {
      onboardfilteredTorTicket = torTicket.where((item) {
        double isNegative = item['from_km'] - item['to_km'];
        double kmRun = item['to_km'];
        final torNoInTicket = item['control_no'];
        final reverseNum = item['reverseNum'];
        bool isReverse = false;

        if (isNegative < 0) {
          isReverse = true;
          kmRun = kmRun.abs();
        } else {
          isReverse = false;
        }

        if (kmRun == null || torNoInTicket == null) {
          return false; // Handle missing "km_run" or "tor_no" data
        }
        print('onboardfilteredTorTicket kmrun: $kmRun');
        print('onboardfilteredTorTicket isReverse: $isReverse');
        print('onboardfilteredTorTicket firstkm: ${filteredStations[0]['km']}');
        print('onboardfilteredTorTicket currentKM: $currentkmpost');
        if (!isReverse) {
          if (kmRun == int.parse(filteredStations[0]['km'].toString())) {
            return kmRun <= currentkmpost &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'];
          } else {
            return kmRun < currentkmpost &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'];
          }
        } else {
          if (kmRun == 0) {
            return kmRun >= currentkmpost &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'];
          } else {
            return kmRun > currentkmpost &&
                torNoInTicket == control_no &&
                reverseNum == SESSION['reverseNum'];
          }
        }
      }).toList();
    });
  }

  void printingInspectionSummary() async {
    if (!fetchservice.getIsNumeric()) {
      if (selectedOnboardPlace != null) {
        if (selectedOnboardPlace!.trim() == "") {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "MISSING",
                  text: "PLEASE FILL UP THE ON BOARD PLACE"));
          return;
        }
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "MISSING",
                text: "PLEASE FILL UP THE ON BOARD PLACE"));
        return;
      }
    }
    String type = '';
    bool isProceed = false;
    bool isOffline = false;
    if (!fetchservice.getIsNumeric()) {
      if (isTicket) {
        type = 'ALL TICKETS';
        printTicketWillPass = filteredTorTicket;
      } else {
        type = 'ON BOARD';
        printTicketWillPass = onboardfilteredTorTicket;
      }
    } else {
      printTicketWillPass = filteredTickets;
    }

    print('printTicketWillPass: $printTicketWillPass');

    if (inspectorData['empNo'].toString() !=
        SESSION['lastInspectorEmpNo'].toString()) {
      String uuid = await generatorServices.generateUuid();
      String onboardTime = await dateservice.departedTime();
      String onboardPlace =
          filteredStations[SESSION['currentStationIndex']]['stationName'];
      if (coopData['coopType'] == "Bus") {
        onboardPlace = filteredStations[0]['stationName'];
      }
      try {
        // onboardPlace = fetchservice.getInspectorCurrentStation(
        //     filteredStations, double.parse(kmPostController.text));
        onboardPlace = findNearestStation(
            filteredStations, double.parse(kmPostController.text));
      } catch (e) {
        onboardPlace =
            filteredStations[SESSION['currentStationIndex']]['stationName'];
        if (coopData['coopType'] == "Bus") {
          onboardPlace = filteredStations[0]['stationName'];
        }
      }
      int passengerCountPrepaid = 0;
      int baggageCount = 0;

      try {
        passengerCountPrepaid = int.parse(passengerWithPrepaidController.text);
      } catch (e) {
        return;
      }

      try {
        baggageCount = int.parse(baggageCountController.text);
      } catch (e) {
        return;
      }

      Map<String, dynamic> item = {
        "fieldData": {
          "coopId": "${torTrip[SESSION['currentTripIndex']]['coopId']}",
          "UUID": "$uuid",
          "device_id": "${torTrip[SESSION['currentTripIndex']]['device_id']}",
          "control_no": "${torTrip[SESSION['currentTripIndex']]['control_no']}",
          "tor_no": "${torTrip[SESSION['currentTripIndex']]['tor_no']}",
          "date_of_trip":
              "${torTrip[SESSION['currentTripIndex']]['date_of_trip']}",
          "bus_no": "${torTrip[SESSION['currentTripIndex']]['bus_no']}",
          "route": "${torTrip[SESSION['currentTripIndex']]['route']}",
          "route_code": "${torTrip[SESSION['currentTripIndex']]['route_code']}",
          "bound": "${torTrip[SESSION['currentTripIndex']]['bound']}",
          "trip_no": torTrip[SESSION['currentTripIndex']]['trip_no'],
          "inspector_emp_no": "${inspectorData['empNo']}",
          "inspector_emp_name": "${inspectorData['idName']}",
          "onboard_time": "$onboardTime",
          "onboard_place": "$selectedOnboardPlace",
          "onboard_km_post": double.parse(kmPostController.text),
          "offboard_time": "$onboardTime",
          "offboard_place": "",
          "offboard_km_post": "",
          "ticket_no_beginning": filteredTickets.isNotEmpty
              ? "${filteredTickets[0]['ticket_no']}"
              : "No Ticket",
          "ticket_no_ending": filteredTickets.isNotEmpty
              ? "${torTicket[torTicket.length - 1]['ticket_no']}"
              : "No Ticket",
          "passenger_count_paid": int.parse(passengerController.text),
          "passenger_count_with_pass": "${passengerWithPassController.text}",
          "passenger_count_transfer": "${passengerTransferController.text}",
          "passenger_count_cash": int.parse(headCountController.text),
          "passenger_count_total":
              int.parse(headCountController.text) + baggageCount,
          "actual_count": int.parse(headCountController.text) + baggageCount,
          "total_discrepancy": int.parse(discrepancyController.text),
          "remarks": "${headCountController.text} pax",
          "timestamp": "$onboardTime",
          "lat": "14.076688",
          "long": "120.866036",
          "passenger_tickets_cash": int.parse(passengerController.text),
          "passenger_count_prepaid": passengerCountPrepaid,
          "baggage_tickets_cash": onboardBaggage,
          "baggage_count_cash": baggageCount,
          "discrepancy": int.parse(discrepancyController.text),
        }
      };

      Map<String, dynamic> isAddedInspection =
          await httprequestServices.addInspection(item);

      if (isAddedInspection['messages'][0]['code'].toString() != '0') {
        // Navigator.of(context).pop();

        await ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: 'OFFLINE',
                showCancelBtn: true,
                confirmButtonText: 'YES',
                cancelButtonText: 'NO',
                onConfirm: () async {
                  isProceed = true;
                  isOffline = true;
                  Navigator.of(context).pop();
                },
                onDeny: () {
                  Navigator.of(context).pop();
                  return;
                },
                onCancel: () {
                  Navigator.of(context).pop();
                  return;
                },
                text: "Do you want to use offline mode?"));
        // ArtSweetAlert.show(
        //   context: context,
        //   artDialogArgs: ArtDialogArgs(
        //     type: ArtSweetAlertType.danger,
        //     title: "ERROR",
        //     text:
        //         "${isAddedInspection['messages'][0]['message'].toString().toUpperCase()}",
        //   ),
        // );

        // return;
      }
      if (isAddedInspection['messages'][0]['code'].toString() == '0') {
        // Navigator.of(context).pop();
        isProceed = true;
      }

      print('isProceed: $isProceed');

      if (!isProceed) {
        return;
      }
      if (isOffline) {
        bool isAddedOfflineAdditionalFare =
            await hiveservices.addOfflineInspection(item);
      }

      bool isAddedInspectionHive =
          await hiveservices.addInspection(item['fieldData']);

      if (!isAddedInspectionHive) {
        Navigator.of(context).pop();
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "ERROR",
            text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN",
          ),
        );
        return;
      }
    }
    _showDialogPrinting('PRINTING PLEASE WAIT...', false);
    int passengerTransfer = 0;
    int passengerWithPass = 0;
    int passengerPrepaid = 0;
    int baggageCount = 0;
    try {
      passengerTransfer = int.parse(passengerTransferController.text);
    } catch (e) {
      print(e);
    }
    try {
      passengerWithPass = int.parse(passengerWithPassController.text);
    } catch (e) {
      print(e);
    }

    try {
      passengerPrepaid = int.parse(passengerWithPrepaidController.text);
    } catch (e) {
      print(e);
    }
    try {
      baggageCount = int.parse(baggageCountController.text);
    } catch (e) {
      print(e);
    }

    // Navigator.of(context).pop();
    bool isprintDone = await printService.printInspectionSummary(
        type,
        torNo,
        passengerController.text,
        baggageController.text,
        headCountController.text,
        kmPostController.text,
        driverName,
        conductorName,
        vehicleNo,
        route,
        "${inspectorData['firstName']} ${inspectorData['middleName'] != '' ? inspectorData['middleName'][0] : ''} ${inspectorData['lastName']}",
        printTicketWillPass,
        isTicket,
        // (onboardPassenger - int.parse(headCountController.text)).abs().toInt(),
        int.parse(discrepancyController.text),
        passengerTransfer,
        passengerWithPass,
        passengerPrepaid,
        baggageCount);

    if (isprintDone) {
      SESSION['inspectorKmPost'] = double.parse(kmPostController.text);
      SESSION['inspectorOnBoardPlace'] = "$selectedOnboardPlace";
      _myBox.put('SESSION', SESSION);
      Navigator.of(context).pop();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.question,
            title: "REPRINT",
            text: "DO YOU WANT TO PRINT AGAIN?",
            denyButtonText: "NO",
            confirmButtonText: 'YES',
            onConfirm: () {
              print('confirm');
              Navigator.of(context).pop();
              printingInspectionSummary();
            },
            onCancel: () {
              print('cancel');
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = dateservice.formatDateNow();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => InspectorMenuPage(
                      inspectorData: inspectorData,
                    )));
        return true;
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
                      child: Text(
                    'INSPECTION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'DATE',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(
                                          child: Text(
                                              '${timeService.dateofTrip2()}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'ROUTE',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration:
                                            BoxDecoration(color: Colors.white),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            '$route',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        '${coopData['coopType'].toString().toUpperCase()} NO',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(
                                            child: Text(
                                          '$vehicleNo',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'TOR NO.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            '$torNo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (!fetchservice.getIsNumeric())
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        topLeft: Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '* ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              'KM POST',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Center(
                                            child: TextField(
                                              controller: kmPostController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xff5f6062)),
                                              decoration: InputDecoration(
                                                  // contentPadding:
                                                  //     EdgeInsets.only(bottom: 10),
                                                  hintText: 'Enter KM Post',
                                                  hintStyle: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      20)))),
                                              onChanged: (value) {
                                                bool isproceed = true;
                                                try {
                                                  double thisvalue =
                                                      double.parse(value);
                                                  if (thisvalue <= 0) {
                                                    setState(() {
                                                      kmPostController.text =
                                                          "";
                                                    });
                                                  }
                                                } catch (e) {
                                                  isproceed = false;
                                                  print(e);

                                                  setState(() {
                                                    stationNames = [];
                                                    selectedOnboardPlace = null;
                                                  });
                                                }

                                                if (!isproceed) return;
                                                if (!isTicket) {
                                                  try {
                                                    if (kmPostController.text
                                                            .trim() !=
                                                        '') {
                                                      findNearestStation(
                                                          filteredStations,
                                                          double.parse(
                                                              kmPostController
                                                                  .text
                                                                  .trim()));
                                                      print(
                                                          'kmrun updateOnboardPassenger');
                                                      setState(() {
                                                        selectedOnboardPlace =
                                                            null;
                                                        updateOnboardPassenger(
                                                            double.parse(
                                                                kmPostController
                                                                    .text),
                                                            control_no);
                                                        onboardPassenger = fetchservice
                                                            .inspectorOnBoardPassenger(
                                                                double.parse(
                                                                    kmPostController
                                                                        .text));

                                                        int onboardBaggageOnly =
                                                            fetchservice.inspectorOnBoardBaggageOnly(
                                                                double.parse(
                                                                    kmPostController
                                                                        .text));

                                                        int onboardBaggagePassenger =
                                                            fetchservice.inspectorOnBoardBaggageWithPassenger(
                                                                double.parse(
                                                                    kmPostController
                                                                        .text));

                                                        baggageOnlyController
                                                                .text =
                                                            onboardBaggageOnly
                                                                .toString();

                                                        baggageWithPassengerController
                                                                .text =
                                                            onboardBaggagePassenger
                                                                .toString();

                                                        passengerController
                                                                .text =
                                                            onboardPassenger
                                                                .toString();

                                                        discrepancyController
                                                                .text =
                                                            "${int.parse(passengerController.text) - int.parse(headCountController.text)}";
                                                      });
                                                    }
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '* ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                'PLACE ON BOARD',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Text(
                                                  'Select Station',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                                items: stationNames
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
                                                value: selectedOnboardPlace,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    selectedOnboardPlace =
                                                        value ?? '';
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
                                                dropdownSearchData:
                                                    DropdownSearchData(
                                                  searchController:
                                                      onboardplaceController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 4,
                                                      right: 8,
                                                      left: 8,
                                                    ),
                                                    child: TextFormField(
                                                      expands: true,
                                                      maxLines: null,
                                                      controller:
                                                          onboardplaceController,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                        hintText:
                                                            'Search for an item...',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  searchMatchFn:
                                                      (item, searchValue) {
                                                    return item.value
                                                        .toString()
                                                        .toUpperCase()
                                                        .contains(searchValue
                                                            .toUpperCase());
                                                  },
                                                ),
                                                //This to clear the search value when you close the menu
                                                onMenuStateChange: (isOpen) {
                                                  if (!isOpen) {
                                                    onboardplaceController
                                                        .clear();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              border: Border.all(
                                  width: 3, color: AppColors.primaryColor)),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              children: [
                                Text(
                                  'Opening: ',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 3,
                                            color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20))),
                                    child: Center(
                                      child: Text(
                                        torTicket.isNotEmpty
                                            ? '${torTicket[0]['ticket_no']}'
                                            : 'NO TICKET',
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              border: Border.all(
                                  width: 3, color: AppColors.primaryColor)),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              children: [
                                Text(
                                  'Closing: ',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 3,
                                            color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(20))),
                                    child: Center(
                                      child: Text(
                                        torTicket.isNotEmpty
                                            ? '${torTicket[torTicket.length - 1]['ticket_no']}'
                                            : 'NO TICKET',
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  'PASSENGER TICKETS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child:
                                          Text('${passengerController.text}'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        if (!fetchservice.getIsNumeric())
                          SizedBox(
                            height: 5,
                          ),
                        if (!fetchservice.getIsNumeric())
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '* ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            'PASSENGER COUNT',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: TextField(
                                          controller: headCountController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xff5f6062)),
                                          decoration: InputDecoration(
                                            hintText: 'Enter Passenger Count',
                                            hintStyle: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              try {
                                                // discrepancyController.text =
                                                //     "${int.parse(passengerController.text) - int.parse(headCountController.text)}";
                                                discrepancyController.text =
                                                    "${(int.parse(passengerController.text) + int.parse(baggageController.text)) - (int.parse(headCountController.text) + int.parse(baggageCountController.text))}";
                                              } catch (e) {
                                                discrepancyController.text =
                                                    "0";
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   right: 10,
                              //   child: Container(
                              //     height: 20,
                              //     width: 20,
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(100),
                              //         border: Border.all(color: Colors.black)),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(
                              //         left: 4.0,
                              //       ),
                              //       child: Text(
                              //         '*',
                              //         style: TextStyle(
                              //             color: Colors.red, fontSize: 20),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: fetchservice.getIsNumeric()
                                  ? BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20))
                                  : BorderRadius.circular(0)),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  'BAGGAGE TICKETS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: fetchservice.getIsNumeric()
                                        ? BorderRadius.only(
                                            bottomRight: Radius.circular(20))
                                        : BorderRadius.circular(0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child: Text(
                                          '${int.parse(baggageOnlyController.text) + int.parse(baggageWithPassengerController.text)}'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (!fetchservice.getIsNumeric())
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '* ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'BAGGAGE COUNT',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      controller: baggageCountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Color(0xff5f6062)),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Baggage Count',
                                        hintStyle: TextStyle(
                                            fontSize: 10, color: Colors.black),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          try {
                                            // discrepancyController.text =
                                            //     "${int.parse(passengerController.text) - int.parse(headCountController.text)}";
                                            discrepancyController.text =
                                                "${(int.parse(passengerController.text) + int.parse(baggageController.text)) - (int.parse(headCountController.text) + int.parse(baggageCountController.text))}";
                                          } catch (e) {
                                            discrepancyController.text = "0";
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 5,
                        ),
                        if (!fetchservice.getIsNumeric())
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'DISCREPANCY',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Center(
                                        child: Text(
                                            '${discrepancyController.text}'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        if (!fetchservice.getIsNumeric())
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: SizedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '* ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            SizedBox(
                                              width: 160,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'PASSENGER (TRANSFERRED)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height: 35,
                                        // decoration: BoxDecoration(
                                        //     color: Colors.white,
                                        //     borderRadius: BorderRadius.only(
                                        //         topRight: Radius.circular(20))),
                                        child: TextField(
                                          controller:
                                              passengerTransferController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              hintText: 'Enter Pass Transfer',
                                              hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff5f6062)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20)))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   right: 10,
                              //   child: Container(
                              //     height: 20,
                              //     width: 20,
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(100),
                              //         border: Border.all(color: Colors.black)),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(
                              //         left: 4.0,
                              //       ),
                              //       child: Text(
                              //         '*',
                              //         style: TextStyle(
                              //             color: Colors.red, fontSize: 20),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        SizedBox(height: 5),
                        if (!fetchservice.getIsNumeric())
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child: Row(
                                            children: [
                                              Text(
                                                '* ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'PASSENGER (WITH PASS)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height: 35,
                                        // decoration: BoxDecoration(
                                        //     color: Colors.white,
                                        //     borderRadius: BorderRadius.only(
                                        //         topRight: Radius.circular(20))),
                                        child: TextField(
                                          controller:
                                              passengerWithPassController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Enter Passenger w/ Pass',
                                              hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff5f6062)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20)))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   right: 10,
                              //   child: Container(
                              //     height: 20,
                              //     width: 20,
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(100),
                              //         border: Border.all(color: Colors.black)),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(
                              //         left: 4.0,
                              //       ),
                              //       child: Text(
                              //         '*',
                              //         style: TextStyle(
                              //             color: Colors.red, fontSize: 20),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        SizedBox(height: 5),
                        if (!fetchservice.getIsNumeric())
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child: Row(
                                            children: [
                                              Text(
                                                '* ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'PASSENGER (PREPAID)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height: 35,
                                        // decoration: BoxDecoration(
                                        //     color: Colors.white,
                                        //     borderRadius: BorderRadius.only(
                                        //         topRight: Radius.circular(20))),
                                        child: TextField(
                                          controller:
                                              passengerWithPrepaidController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Enter Passenger Prepaid',
                                              hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff5f6062)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20)))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 0,
                              //   right: 10,
                              //   child: Container(
                              //     height: 20,
                              //     width: 20,
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(100),
                              //         border: Border.all(color: Colors.black)),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(
                              //         left: 4.0,
                              //       ),
                              //       child: Text(
                              //         '*',
                              //         style: TextStyle(
                              //             color: Colors.red, fontSize: 20),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InspectorMenuPage(
                                                  inspectorData: inspectorData,
                                                )));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors
                                        .primaryColor, // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'MENU',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!fetchservice.getIsNumeric()) {
                                      bool isAllready = false;

                                      if (headCountController.text == '') {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "MISSING",
                                                text:
                                                    "PLEASE FILL UP THE HEAD COUNT"));
                                      } else if (kmPostController.text == '') {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "MISSING",
                                                text:
                                                    "PLEASE FILL UP THE KM POST"));
                                      } else {
                                        isAllready = true;
                                      }
                                      if (isAllready) {
                                        printingInspectionSummary();
                                      }
                                    } else {
                                      printingInspectionSummary();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors
                                        .primaryColor, // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'PRINT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
          ],
        )),
      ),
    );
  }

  void _showDialogPrinting(String title, bool isDismissible) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.22,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDismissible)
                        Image.asset(
                          'assets/warning.png',
                          width: 40,
                        ),
                      Text(
                        '$title',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
