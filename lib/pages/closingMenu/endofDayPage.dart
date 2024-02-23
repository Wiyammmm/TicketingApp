import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:dltb/pages/syncingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EndofDayPage extends StatefulWidget {
  const EndofDayPage(
      {super.key,
      required this.cashierData,
      required this.finalRemitt,
      required this.shortOver,
      required this.puncherTR,
      required this.puncherTC,
      required this.puncherBR,
      required this.puncherBC});
  final cashierData;
  final finalRemitt;
  final shortOver;
  final double puncherTR;
  final double puncherTC;
  final double puncherBR;
  final double puncherBC;
  @override
  State<EndofDayPage> createState() => _EndofDayPageState();
}

class _EndofDayPageState extends State<EndofDayPage> {
  final _myBox = Hive.box('myBox');
  HiveService hiveService = HiveService();
  fetchServices fetchService = fetchServices();
  timeServices basicservices = timeServices();
  TestPrinttt printService = TestPrinttt();
  bool isTripReport = true;
  Map<String, dynamic> SESSION = {};
  List<Map<String, dynamic>> employeeList = [];
  Map<String, dynamic> cashierData = {};
  List<Map<String, dynamic>> torTrip = [];
  List<Map<String, dynamic>> torTicket = [];
  List<Map<String, dynamic>> prePaidPassenger = [];
  List<Map<String, dynamic>> prePaidBaggage = [];
  String conductorName = '';
  String driverName = '';
  String dispatcherName = '';
  String vehicleNo = '';
  int totalBaggage = 0;
  int totalDiscounted = 0;
  int regularCount = 0;
  String cashierName = '';
  double totalPassengerAmount = 0;
  double finalRemitt = 0.0;
  double shortOver = 0.0;

  @override
  void initState() {
    super.initState();
    finalRemitt = widget.finalRemitt;
    shortOver = widget.shortOver;
    SESSION = _myBox.get('SESSION');
    prePaidPassenger = _myBox.get('prepaidTicket');
    prePaidBaggage = _myBox.get('prepaidBaggage');
    torTrip = _myBox.get('torTrip');
    torTicket = _myBox.get('torTicket');
    print('torTicket: $torTicket');
    cashierData = widget.cashierData;
    totalBaggage = fetchService.allBaggageCount();
    // totalBaggage = totalBaggage =
    //     torTicket.where((item) => (item['baggage'] ?? 0) > 0).length;
    //
    totalDiscounted = fetchService.discountedCount();
    regularCount = fetchService.regularCount();

    totalPassengerAmount = fetchService.totalpassengerFareAmount();

    employeeList = fetchService.fetchEmployeeList();

    driverName = fetchService.driverName();
    conductorName = fetchService.conductorName();

    cashierName =
        '${cashierData['firstName']} ${cashierData['middleName'] != '' ? cashierData['middleName'][0] : ''}. ${cashierData['lastName']}';
    // vehicleNo = torTrip[SESSION['currentTripIndex'] - 1]['bus_no'];
  }

  @override
  Widget build(BuildContext context) {
    final datenow = basicservices.formatDateNow();
    return WillPopScope(
      onWillPop: () async {
        return false;
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
                            'END OF DAY',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isTripReport = true;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: isTripReport
                                            ? AppColors.primaryColor
                                            : Color(0xffd9d9d9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: isTripReport
                                                ? Colors.white
                                                : Colors.black,
                                            width: 5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Trip Summary',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: isTripReport
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       isTripReport = false;
                                //     });
                                //   },
                                //   child: Container(
                                //     width: MediaQuery.of(context).size.width,
                                //     decoration: BoxDecoration(
                                //         color: isTripReport
                                //             ? Color(0xffd9d9d9)
                                //             : Color(0xff46aef2),
                                //         borderRadius: BorderRadius.circular(10),
                                //         border: Border.all(
                                //             color: Colors.white, width: 5)),
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(16.0),
                                //       child: Text(
                                //         'Trip Summary',
                                //         textAlign: TextAlign.center,
                                //         style: TextStyle(
                                //             color: isTripReport
                                //                 ? Colors.black
                                //                 : Colors.white,
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.bold),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isPrintDone = false;
                        _showDialogPrinting('PRINTING PLEASE WAIT...', false);

                        // if (isTripReport) {
                        isPrintDone = await printService.printTripReport(
                            // '${torTrip[SESSION['currentTripIndex'] - 1]['tor_no']}',
                            // '$vehicleNo',
                            // '$conductorName',
                            // '$driverName',
                            // '$dispatcherName',
                            '$cashierName',
                            // regularCount,
                            // totalDiscounted,
                            // totalBaggage,
                            // '${torTrip[SESSION['currentTripIndex'] - 1]['route']}',
                            // torTicket.length,
                            // totalPassengerAmount,
                            torTrip,
                            torTicket,
                            prePaidPassenger,
                            prePaidBaggage,
                            finalRemitt,
                            shortOver,
                            widget.puncherTR,
                            widget.puncherTC,
                            widget.puncherBR,
                            widget.puncherBC);
                        // } else {
                        //   isPrintDone = printService.printTripSummary();
                        // }
                        const duration = Duration(
                            seconds:
                                3); // Adjust the duration as needed (3 seconds in this example).
                        await Future.delayed(duration);
                        if (isPrintDone) {
                          // bool isUpdateClosing = true;
                          bool isUpdateClosing =
                              await hiveService.updateClosing(true);
                          if (isUpdateClosing) {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SyncingMenuPage()));
                          } else {
                            Navigator.of(context).pop();
                            ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.danger,
                                    title: "SOMETHING WENT WRONG",
                                    text: "Please try again"));
                          }
                          // _showDialogPrinting(
                          //     'Are you sure you would like to close\nthe transaction?',
                          //     true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors
                            .primaryColor, // Background color of the button

                        padding: EdgeInsets.symmetric(horizontal: 24.0),

                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Colors.black),

                          borderRadius:
                              BorderRadius.circular(10.0), // Border radius
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'FINALIZE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
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
                      if (isDismissible)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
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
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'NO',
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
                                  bool isUpdateClosing =
                                      await hiveService.updateClosing(true);
                                  if (isUpdateClosing) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SyncingMenuPage()));
                                  } else {
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "SOMETHING WENT WRONG",
                                            text: "Please try again"));
                                  }
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
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'YES',
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
              ),
            ),
          );
        });
  }
}
