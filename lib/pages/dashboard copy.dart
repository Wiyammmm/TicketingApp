import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/pages/Fuel/FuelPage.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:dltb/pages/dispatcherPage.dart';
import 'package:dltb/pages/inspectorMenuPage.dart';
import 'package:dltb/pages/syncingMenuPage.dart';
import 'package:dltb/pages/ticketingMenu/ticketingPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _myBox = Hive.box('myBox');
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  fetchServices fetchService = fetchServices();
  String vehicleNo = '';

  bool isnfcOn = true;
  String driverName = '';
  String conductorName = '';
  String routeid = '';
  String tripType = '';
  Map<dynamic, dynamic> torDispatch = {};
  List<Map<dynamic, dynamic>> employeeList = [];
  dynamic torTrip = [];
  List<Map<dynamic, dynamic>> torTicket = [];
  List<Map<dynamic, dynamic>> torInspection = [];
  List<Map<dynamic, dynamic>> stations = [];

  Map<dynamic, dynamic> SESSION = {};
  bool isShowClosingMenu = false;
  bool isconductorModalshow = false;
  int onboardPassenger = 0;
  int onboardBaggage = 0;
  Map<String, dynamic> coopData = {};
  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    torDispatch = _myBox.get('torDispatch');
    torTrip = _myBox.get('torTrip');
    SESSION = _myBox.get('SESSION');
    torTicket = fetchService.fetchAllTorTicketTrip();
    torInspection = fetchService.fetchAllTorInspectionTrip();
    tripType = SESSION['tripType'];
    routeid = SESSION['routeID'];
    stations = getFilteredStations(fetchService.fetchStationList());
    employeeList = fetchService.fetchEmployeeList();
    // int currentKM = stations[SESSION['currentStationIndex']]['km'];
    // print('currentKM: ${stations[SESSION['currentStationIndex']]['km']}');

    onboardPassenger = fetchService.onBoardPassenger();
    // torTicket.where((item) {
    //   final kmRun = item['to_km'];

    //   if (kmRun == null) {
    //     return false; // Handle missing "km_run" data
    //   }

    //   final kmRunValue = int.tryParse(kmRun.toString());

    //   if (kmRunValue == null) {
    //     return false; // Handle non-integer "km_run" values
    //   }

    //   return kmRunValue > currentKM;
    // }).length;
    onboardBaggage = fetchService.onBoardBaggage();
    // torTicket
    //     .where((item) =>
    //         (item['to_km'] is int && item['to_km'] > currentKM) &&
    //         (item['baggage'] is double && item['baggage'] > 0))
    //     .length;
    print('onboardPassenger: $onboardPassenger');
    // if (torTrip['arrived_dispatcher_id'] != null) {
    //   isShowClosingMenu = true;
    //   print('not null');
    // }
    if (torTrip[SESSION['currentTripIndex']]['arrived_dispatcher_id'] != "") {
      isShowClosingMenu = true;
      print('this is null but with double quote');
    }
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

    vehicleNo = torDispatch['vehicleNo'];
    print('torDispatch: $torDispatch');
    print('employeeList: $employeeList');

    _startNFCReaderDashboard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredStations(
      List<Map<String, dynamic>> stationList) {
    return stationList
        .where((station) => station['routeID'] == routeid)
        .toList();
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  void _startNFCReaderDashboard() async {
    print('nfc refresh');
    if (!isnfcOn) {
      return;
    }
    try {
      final result =
          await backend.startNFCReader().timeout(Duration(seconds: 30));
      if (result != null) {
        print('result: $result');
        final isCardExistingResult = isCardExisting.isCardExisting(result);
        if (isCardExistingResult != null) {
          print('isCardExistingResult22: $isCardExistingResult');
          if (isCardExistingResult.isEmpty || isCardExistingResult == null) {
            print('this is null');
            return;
          }
          String emptype = isCardExistingResult['designation'];
          print('emptype: $emptype');
          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("driver")) {}
          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("dispatcher")) {
            // if (!isShowClosingMenu) {
            setState(() {
              isnfcOn = false;
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DispatcherPage(dispatcherData: isCardExistingResult)));
            // }
          }
          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("cashier")) {
            print('isShowClosingMenu: $isShowClosingMenu');
            if (isShowClosingMenu && !SESSION['isClosed']) {
              setState(() {
                isnfcOn = false;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClosingMenuPage(
                            cashierData: isCardExistingResult,
                          )));
            }
            if (SESSION['isClosed']) {
              setState(() {
                isnfcOn = false;
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SyncingMenuPage()));
            }
          }

          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("inspector")) {
            _showDialogInspector(context, isCardExistingResult);
          }

          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("fuel")) {
            setState(() {
              isnfcOn = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FuelPage(fuelAttendantData: isCardExistingResult)));
          }
          if (isCardExistingResult['accessPrivileges']
              .toString()
              .toLowerCase()
              .contains("conductor")) {
            if (isCardExistingResult['empNo'].toString() ==
                torDispatch['conductorEmpNo'].toString()) {
              if (!isShowClosingMenu) {
                if (!isconductorModalshow) {
                  setState(() {
                    isconductorModalshow = true;
                    isnfcOn = false;
                  });
                  print('go to');
                  if (coopData['coopType'] == "Jeepney") {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TicketingPage()));
                  } else {
                    _showDialog(context);
                  }
                }
              }
            }
          } else {
            if (mounted) {
              // Check if the widget is still mounted
              print('Hi There');
            }
          }
        }
      }
      _startNFCReaderDashboard();
    } catch (e) {
      print('error _startNFCReaderDashboard: $e');
      _startNFCReaderDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // logic
      },
      child: RefreshIndicator(
        onRefresh: () async {
          // _startNFCReaderDashboard();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardPage()));
        },
        child: Scaffold(
          body: SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$formattedDate',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xFF46aef2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'VEHICLE NO.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFd9d9d9),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          '$vehicleNo',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFF00558d),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          employeeWidget(
                              title: 'DRIVER', conductorName: driverName),
                          SizedBox(
                            height: 10,
                          ),
                          employeeWidget(
                              title: 'CONDUCTOR', conductorName: conductorName),
                          SizedBox(
                            height: 10,
                          ),
                          if (!fetchService.getIsNumeric())
                            dashboardWidget(
                                title: 'CURRENT TRIP TICKETS',
                                number: onboardPassenger),
                          dashboardWidget(
                              title: 'ALL TICKETS', number: torTicket.length),
                          if (!fetchService.getIsNumeric())
                            dashboardWidget(
                                title: 'CURRENT TRIP BAGGAGE',
                                number: onboardBaggage),
                          if (coopData['coopType'] == "Jeepney" &&
                              fetchService.getIsNumeric())
                            dashboardWidget(
                                title: 'ALL TRIP BAGGAGE',
                                number: fetchService.baggageCount()),
                          dashboardWidget(
                              title: 'INSPECTION MADE',
                              number: torInspection.length),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xFF00558d),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '${tripType.toUpperCase()} TRIP',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Container(
                          //   width: MediaQuery.of(context).size.width,
                          //   decoration: BoxDecoration(
                          //       color: Color(0xff46aef2),
                          //       borderRadius: BorderRadius.circular(10)),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Text(
                          //       SESSION['isClosed']
                          //           ? 'CLOSED'
                          //           : (torTrip[SESSION['currentTripIndex']]
                          //                       ['arrived_dispatcher_id'] ==
                          //                   ""
                          //               ? 'DISPATCHED'
                          //               : 'ARRIVED'),
                          //       textAlign: TextAlign.center,
                          //       style: TextStyle(
                          //           color: Colors.white,
                          //           fontWeight: FontWeight.bold,
                          //           fontSize:
                          //               MediaQuery.of(context).size.width *
                          //                   0.07),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
                color: Color(0xFF46aef2),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'CHOOSE PAGE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.07,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isnfcOn = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TicketingMenuPage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(
                                        0xFF00adee), // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Ticketing Menu',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.07,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isnfcOn = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CundoctorPage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(
                                        0xFF00adee), // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Top-up Menu',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            )
                          ]),
                    ),
                  )
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
    ).then((value) {
      setState(() {
        isconductorModalshow = false;
        isnfcOn = true;
      });
      _startNFCReaderDashboard();
    });
  }

  void _showDialogInspector(
      BuildContext context, Map<String, dynamic> inspectorData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
                color: Color(0xFF46aef2),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'CHOOSE POSITION',
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      isnfcOn = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InspectorMenuPage(
                                                  inspectorData: inspectorData,
                                                )));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(
                                        0xFF00adee), // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Inspector',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            Stack(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        // setState(() {
                                        //   isnfcOn = false;
                                        // });
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             CundoctorPage()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(
                                            0xFF00adee), // Background color of the button
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Border radius
                                        ),
                                      ),
                                      child: Text(
                                        'Controller',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(99, 0, 0, 0),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: Text(
                                    'NOT AVAILABLE',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                )
                              ],
                            )
                          ]),
                    ),
                  )
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
    ).then((value) {
      _startNFCReaderDashboard();
    });
  }
}

class employeeWidget extends StatelessWidget {
  const employeeWidget(
      {super.key, required this.conductorName, required this.title});

  final String conductorName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.person,
            color: Color(0xFF4294ff),
            size: MediaQuery.of(context).size.width * 0.13,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$conductorName',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class dashboardWidget extends StatelessWidget {
  const dashboardWidget({super.key, required this.title, required this.number});
  final String title;
  final int number;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
                color: Color(0XFF46aef2),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16),
              child: Text(
                '$title',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                  color: Color(0XFFd9d9d9),
                  borderRadius: BorderRadius.circular(50)),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '$number',
                      style: TextStyle(
                          color: Color(0xFF00558d),
                          fontSize: MediaQuery.of(context).size.width * 0.07),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
