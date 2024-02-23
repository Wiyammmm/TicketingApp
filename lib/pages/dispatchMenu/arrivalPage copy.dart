import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:dltb/pages/specialtrip.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../backend/service/services.dart';

class ArrivalPage extends StatefulWidget {
  const ArrivalPage({super.key, required this.dispatcherData});
  final dispatcherData;
  @override
  State<ArrivalPage> createState() => _ArrivalPageState();
}

class _ArrivalPageState extends State<ArrivalPage> {
  final _myBox = Hive.box('myBox');

  LoadingModal loadingModal = LoadingModal();
  HiveService hiveService = HiveService();
  timeServices basicservices = timeServices();
  TestPrinttt printService = TestPrinttt();
  fetchServices fetchService = fetchServices();

  List<Map<String, dynamic>> employeeList = [];
  Map<String, dynamic> SESSION = {};
  Map<String, dynamic> torDispatch = {};
  Map<String, dynamic> dispatcherData = {};
  List<Map<String, dynamic>> torTrip = [];
  List<Map<String, dynamic>> torTicket = [];
  String conductorName = '';
  String driverName = '';
  String dispatcherName = '';
  String vehicleNo = '';
  int totalBaggage = 0;
  double totalBaggageAmount = 0;
  double totalPassengerAmount = 0;
  int totalbaggageonly = 0;
  int totalbaggagewithpassenger = 0;
  int totalpassengerCount = 0;
  // int fetchAllPassengerCount() {
  //   int allPassenger = 0;
  //   try {
  //     final prepaidTicket = _myBox.get('prepaidTicket');
  //     final torTicket = _myBox.get('torTicket');
  //     final session = _myBox.get('SESSION');
  //     final torTrip = _myBox.get('torTrip');

  //     print('all torTicket: $torTicket');

  //     String control_no = torTrip[session['currentTripIndex']]['control_no'];
  //     // print('torNo: $torNo');
  //     List<Map<String, dynamic>> currentTorTicket = torTicket
  //         .where((item) => item['control_no'] == control_no && item['fare'] > 0)
  //         .toList();
  //     List<Map<String, dynamic>> currentprepaidTicket = prepaidTicket
  //         .where((item) => item['control_no'] == control_no)
  //         .toList();
  //     int sumTotalPassenger = currentprepaidTicket.fold(
  //       0,
  //       (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
  //     );
  //     allPassenger = currentTorTicket.length + sumTotalPassenger;

  //     return allPassenger;
  //   } catch (e) {
  //     return allPassenger;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    SESSION = _myBox.get('SESSION');
    torDispatch = _myBox.get('torDispatch');
    torTrip = _myBox.get('torTrip');
    torTicket = fetchService.fetchTorTicket();
    totalpassengerCount = fetchService.fetchAllPassengerCount();
    print('SESSION: $SESSION');
    print('SESSION CURRENT TRIP: ${torTrip[SESSION['currentTripIndex']]}');
    totalbaggageonly = fetchService.baggageOnlyCount();
    totalbaggagewithpassenger = fetchService.baggageWithPassengerCount();

    dispatcherData = widget.dispatcherData;
    totalBaggage =
        torTicket.where((item) => (item['baggage'].round() ?? 0) > 0).length;

    // totalBaggageAmount =
    //     torTicket.fold(0.0, (double accumulator, Map<String, dynamic> item) {
    //   int baggage = item['baggage'] ?? 0;
    //   return accumulator + baggage;
    // });

    totalBaggageAmount = fetchService.totalBaggageperTrip();

    // totalPassengerAmount =
    //     torTicket.fold(0.0, (double accumulator, Map<String, dynamic> item) {
    //   int fare = item['fare'] ?? 0;
    //   return accumulator + fare;
    // });
    employeeList = fetchService.fetchEmployeeList();

    final driverData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() == torDispatch['driverEmpNo'].toString(),
    );
    print('driverData: $driverData');
    driverName = '${driverData['firstName']} ${driverData['lastName']}';

    final conductorData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() ==
          torDispatch['conductorEmpNo'].toString(),
    );
    print('conductorData: $conductorData');
    conductorName =
        '${conductorData['firstName']} ${conductorData['lastName']}';

    vehicleNo = '${torDispatch['vehicleNo']}:${torDispatch['plate_number']}';
  }

  @override
  Widget build(BuildContext context) {
    final datenow = basicservices.formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            appbar(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                  color: Color(0xFF00558d),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$datenow',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color(0xff46aef2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ARRIVAL MENU',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                          color: Color(0xfff4f7f9),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'OPENING:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  torTicket.isNotEmpty
                                      ? Text('${torTicket[0]['ticket_no']}')
                                      : Text('NO TICKET')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CLOSING:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  torTicket.isNotEmpty
                                      ? Text(
                                          '${torTicket[torTicket.length - 1]['ticket_no']}')
                                      : Text('NO TICKET')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL PASSENGER:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.fetchAllPassengerCount()}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BAGGAGE ONLY:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('$totalbaggageonly')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BAGGAGE W/ PASS:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('$totalbaggagewithpassenger')
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'TOTAL PASSES:',
                              //       style: TextStyle(fontWeight: FontWeight.bold),
                              //     ),
                              //     Text('0')
                              //   ],
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL FARE:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripFare().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BAGGAGE ONLY AMOUNT:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripBaggageOnly().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BAGGAGE WITH PASS AMOUNT:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripBaggagewithPassenger().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BAGGAGE AMOUNT:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${totalBaggageAmount.toInt()}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ADD FARE TOTAL:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalAddFare().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CARD SALES:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripCardSales().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CASH RECEIVED:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripCashReceived().toStringAsFixed(2)}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'GRAND TOTAL:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${fetchService.totalTripGrandTotal().toStringAsFixed(2)}')
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'TOTAL CARD SALES:',
                              //       style: TextStyle(fontWeight: FontWeight.bold),
                              //     ),
                              //     Text('0.00')
                              //   ],
                              // ),
                              Divider(thickness: 2, color: Colors.black),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'TRIP NO:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('\t\t${torTrip.length}')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('VEHICLE NO:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('\t\t$vehicleNo')
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'TOR NO:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                    child: Text(
                                        '\t\t${torTrip[SESSION['currentTripIndex']]['tor_no']}'),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'CONDUCTOR:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('$conductorName')))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DRIVER:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('$driverName')))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DISPATCHER:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                              '${dispatcherData['firstName']} ${dispatcherData['middleName'] != '' ? dispatcherData['middleName'][0] : ''}. ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}')))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ROUTE:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                              '${torTrip[SESSION['currentTripIndex']]['route']}')))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (SESSION['tripType'] == 'regular') {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DashboardPage()));
                              } else if (SESSION['tripType'] == 'special') {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SpecialTripPage()));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xFF00adee), // Background color of the button

                              padding: EdgeInsets.symmetric(horizontal: 24.0),

                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),

                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'BACK',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              loadingModal.showLoading(context);
                              final torTicket =
                                  fetchService.fetchallPerTripTicket();

                              final torTrip = _myBox.get('torTrip');
                              final session = _myBox.get('SESSION');
                              String control_no =
                                  torTrip[session['currentTripIndex']]
                                      ['control_no'];
                              String route =
                                  torTrip[SESSION['currentTripIndex']]['route']
                                      .toString();

                              // bool isUpdateTripIndex = true;
                              bool isUpdateTripIndex = await hiveService
                                  .updateCurrentTripIndex(dispatcherData);

                              if (isUpdateTripIndex) {
                                int totalBaggageCount = torTicket
                                    .where((item) =>
                                        (item['baggage'] is num &&
                                            item['baggage'] > 0) &&
                                        item['control_no'] == control_no)
                                    .length;

                                bool isprint = await printService.printArrival(
                                    torTicket.isNotEmpty
                                        ? '${torTicket[0]['ticket_no']}'
                                        : 'NO TICKET',
                                    torTicket.isNotEmpty
                                        ? '${torTicket[torTicket.length - 1]['ticket_no']}'
                                        : 'NO TICKET',
                                    totalpassengerCount,
                                    totalBaggageCount,
                                    totalPassengerAmount,
                                    totalBaggageAmount,
                                    torTrip.length,
                                    vehicleNo,
                                    conductorName,
                                    driverName,
                                    '${dispatcherData['firstName']} ${dispatcherData['middleName'] != '' ? dispatcherData['middleName'][0] : ''}. ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}',
                                    route ?? '',
                                    "${SESSION['torNo']}");
                                if (isprint) {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()));
                                } else {
                                  Navigator.of(context).pop();
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          title: "SOMETHING WENT  WRONG",
                                          text: "Please try again"));
                                }

                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => DashboardPage()));
                              } else {
                                Navigator.of(context).pop();
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.danger,
                                        title: "ERROR",
                                        text:
                                            "PLEASE CHECK YOUR INTERNET CONNECTION"));
                              }
                              // bool isUpdateArrived =
                              //     await hiveService.updateArrived();

                              // if (isUpdateArrived) {
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xFF00adee), // Background color of the button

                              padding: EdgeInsets.symmetric(horizontal: 24.0),

                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),

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
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
