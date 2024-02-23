import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/dispatcherPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SpecialTripPage extends StatefulWidget {
  const SpecialTripPage({super.key});

  @override
  State<SpecialTripPage> createState() => _SpecialTripPageState();
}

class _SpecialTripPageState extends State<SpecialTripPage> {
  final _myBox = Hive.box('myBox');
  fetchServices fetchService = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  String vehicleNo = '';
  String driverName = '';
  String conductorName = '';
  bool isnfcOn = true;
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  Map<String, dynamic> torDispatch = {};
  List<Map<String, dynamic>> employeeList = [];
  @override
  void initState() {
    super.initState();
    torDispatch = _myBox.get('torDispatch');
    employeeList = fetchService.fetchEmployeeList();

    vehicleNo = torDispatch['vehicleNo'];
    final driverData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() == torDispatch['driverEmpNo'].toString(),
    );
    driverName =
        '${driverData['firstName']} ${driverData['middleName'] != "" ? "${driverData['middleName'][0]}." : ""} ${driverData['lastName']}';
    final conductorData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() ==
          torDispatch['conductorEmpNo'].toString(),
    );
    conductorName =
        '${conductorData['firstName']} ${conductorData['middleName'] != "" ? "${conductorData['middleName'][0]}." : ""} ${conductorData['lastName']}';

    _startNFCReaderDashboard();
  }

  void _startNFCReaderDashboard() async {
    if (!isnfcOn) {
      return;
    }
    try {
      final result =
          await backend.startNFCReader().timeout(Duration(seconds: 30));
      if (result != null) {
        final isCardExistingResult = isCardExisting.isCardExisting(result);
        if (isCardExistingResult != null) {
          String emptype = isCardExistingResult['designation'];
          if (emptype.toLowerCase().contains("dispatcher")) {
            setState(() {
              isnfcOn = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DispatcherPage(dispatcherData: isCardExistingResult)));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return WillPopScope(
        onWillPop: () async {
          // Handle the back button press here, or return false to prevent it
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _startNFCReaderDashboard();
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
                      height: MediaQuery.of(context).size.height * 0.85,
                      decoration: BoxDecoration(
                          color: Color(0xFF00558d),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              topLeft: Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$formattedDate',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFF46aef2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'VEHICLE NO.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                        ),
                                      ],
                                    ),
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
                                    title: 'CONDUCTOR',
                                    conductorName: conductorName),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Color(0xff46aef2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'SPECIAL TRIP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.07),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
          ),
        ));
  }
}
