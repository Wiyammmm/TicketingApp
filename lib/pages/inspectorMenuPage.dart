import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/inspectorMenu/inspectionSummaryPage.dart';
import 'package:dltb/pages/inspectorMenu/violationPage.dart';
import 'package:flutter/material.dart';

class InspectorMenuPage extends StatefulWidget {
  const InspectorMenuPage({super.key, required this.inspectorData});
  final inspectorData;
  @override
  State<InspectorMenuPage> createState() => _InspectorMenuPageState();
}

class _InspectorMenuPageState extends State<InspectorMenuPage> {
  timeServices basicservices = timeServices();
  fetchServices fetchservice = fetchServices();
  Map<String, dynamic> inspectorData = {};
  Map<String, dynamic> coopData = {};
  @override
  void initState() {
    inspectorData = widget.inspectorData;
    coopData = fetchservice.fetchCoopData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final datenow = basicservices.formatDateNow();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashboardPage()));
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Center(
                                  child: Text(
                                'INSPECTION MENU',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InspectionSummaryPage(
                                                    inspectorData:
                                                        inspectorData,
                                                  )));
                                    },
                                    child: closingMenuButton(
                                      title: 'Inspection\nSummary',
                                      image: 'inspectionSummary.png',
                                      isAvailable: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViolationPage(
                                                    inspectorData:
                                                        inspectorData,
                                                  )));
                                    },
                                    child: closingMenuButton(
                                      title: 'Violation',
                                      image: 'violation.png',
                                      isAvailable: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: closingMenuButton(
                            //         title: 'Trouble',
                            //         image: 'trouble.png',
                            //         isAvailable: false,
                            //       ),
                            //     ),
                            //     SizedBox(
                            //       width: 10,
                            //     ),
                            //     Expanded(
                            //       child: closingMenuButton(
                            //         title: 'Reports',
                            //         image: 'reports.png',
                            //         isAvailable: false,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     SizedBox(
                            //       width:
                            //           MediaQuery.of(context).size.width * 0.5,
                            //       child: closingMenuButton(
                            //         title: 'Trip\nManifest',
                            //         image: 'tripmanifest.png',
                            //         isAvailable: false,
                            //       ),
                            //     ),
                            //     // Container(
                            //     //   height:
                            //     //       MediaQuery.of(context).size.height * 0.1,
                            //     //   width:
                            //     //       MediaQuery.of(context).size.width * 0.47,
                            //     //   decoration: BoxDecoration(
                            //     //       color: Color(0xff46aef2),
                            //     //       borderRadius: BorderRadius.circular(10),
                            //     //       border: Border.all(
                            //     //           width: 4, color: Color(0xffd9d9d9))),
                            //     //   child: Padding(
                            //     //     padding: const EdgeInsets.all(8.0),
                            //     //     child: Row(
                            //     //       mainAxisAlignment:
                            //     //           MainAxisAlignment.spaceAround,
                            //     //       children: [
                            //     //         FittedBox(
                            //     //           fit: BoxFit.scaleDown,
                            //     //           child: Text(
                            //     //             'Trip\nManifest',
                            //     //             textAlign: TextAlign.center,
                            //     //             style: TextStyle(
                            //     //                 fontWeight: FontWeight.bold),
                            //     //           ),
                            //     //         ),
                            //     //         Image.asset(
                            //     //           'assets/tripmanifest.png',
                            //     //           width: MediaQuery.of(context)
                            //     //                   .size
                            //     //                   .width *
                            //     //               0.14,
                            //     //         )
                            //     //       ],
                            //     //     ),
                            //     //   ),
                            //     // ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardPage()));
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
                        'BACK',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
