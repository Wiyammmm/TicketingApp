import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenu/endofDayPage.dart';
import 'package:dltb/pages/closingMenu/finalCashPage.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SyncingMenuPage extends StatefulWidget {
  const SyncingMenuPage({super.key});

  @override
  State<SyncingMenuPage> createState() => _SyncingMenuPageState();
}

class _SyncingMenuPageState extends State<SyncingMenuPage> {
  HiveService hiveService = HiveService();
  LoadingModal loadingModal = LoadingModal();

  Future<void> _offlineSyncting() async {
    final _myBox = await Hive.openBox('myBox');
    httprequestService httprequestservice = httprequestService();
    // Got a new connectivity status!
    final offlineTicket = _myBox.get('offlineTicket');
    final offlineUpdateAdditionalFare =
        _myBox.get('offlineUpdateAdditionalFare');
    final offlineInspection = _myBox.get('offlinetorInspection');

    final offlinetorViolation = _myBox.get('offlinetorViolation');

    print('offlineInspection: $offlineInspection');
    print('offlinetorViolation: $offlinetorViolation');
    // if (torTicket.isNotEmpty) {
    //   List<Map<String, dynamic>> offlineDataList =
    //       torTicket.where((data) => data['isOffline'] == true).toList();
    //   print('connection offlineDataList: $offlineDataList');
    // }
    if (offlinetorViolation.isNotEmpty) {
      for (var item in List.from(offlinetorViolation)) {
        print('connection offlinetorViolation item: $item');
        Map<String, dynamic> resultofflineViolation =
            await httprequestservice.addViolation(item);
        try {
          if (resultofflineViolation['messages'][0]['code'].toString() == "0") {
            print("connection offlinetorViolation success");
            offlinetorViolation.remove(item);
          } else {
            print(
                "connection offlinetorViolation failed ${resultofflineViolation['messages']['message']}");
          }
        } catch (e) {
          print('connection offlinetorViolation $e');
        }

        if (offlinetorViolation.isEmpty) {
          continue;
        }
      }
      _myBox.put('offlinetorViolation', offlinetorViolation);
    }

    if (offlineTicket.isNotEmpty) {
      for (var item in List.from(offlineTicket)) {
        print('connection offlineTicket item: $item');
        item['isNegative'] = true;
        Map<String, dynamic> offlineTorTicket =
            await httprequestservice.torTicket(item);
        try {
          if (offlineTorTicket['messages']['code'].toString() == "0") {
            print("connection offlineTorTicket success");
            offlineTicket.remove(item);
          } else {
            print(
                "connection failed ${offlineTorTicket['messages']['message']}");
          }
        } catch (e) {
          print('connection $e');
        }

        if (offlineTicket.isEmpty) {
          continue;
        }
      }
      _myBox.put('offlineTicket', offlineTicket);
    }

    if (offlineUpdateAdditionalFare.isNotEmpty) {
      for (var itemAdditionalFare in List.from(offlineUpdateAdditionalFare)) {
        print('connection offlineTicket item: $itemAdditionalFare');
        itemAdditionalFare['isNegative'] = true;
        Map<String, dynamic> offlineAdditionalFare = await httprequestservice
            .updateAdditionalFare(itemAdditionalFare, true);
        try {
          if (offlineAdditionalFare['messages']['code'].toString() == "0") {
            print("offlineUpdateAdditionalFare success");
            offlineUpdateAdditionalFare.remove(itemAdditionalFare);
          } else {
            print("failed");
          }
        } catch (e) {
          print(e);
        }

        if (offlineUpdateAdditionalFare.isEmpty) {
          continue;
        }
      }
      _myBox.put('offlineUpdateAdditionalFare', offlineUpdateAdditionalFare);
    }

    if (offlineInspection.isNotEmpty) {
      for (var item in List.from(offlineInspection)) {
        print('connection offlineInspection item: $item');
        Map<String, dynamic> resultofflineInspection =
            await httprequestservice.addInspection(item);
        try {
          if (resultofflineInspection['messages'][0]['code'].toString() ==
              "0") {
            print("connection offlineInspection success");
            offlineInspection.remove(item);
          } else {
            print(
                "connection offlineInspection failed ${resultofflineInspection['messages']['message']}");
          }
        } catch (e) {
          print('connection offlineInspection $e');
        }
        _myBox.put('offlinetorInspection', offlineInspection);
        if (offlineInspection.isEmpty) {
          continue;
        }
      }
    }
  }

  // Map<String, dynamic> cashierData = {
  //   "lastName": "BOLA",
  //   "firstName": "ANTHONY",
  //   "middleName": "BRITANICO",
  //   "nameSuffix": "",
  //   'empNo': 1427,
  //   'empStatus': 'Active/Recalled',
  //   'empType': 'Regular',
  //   'idName': 'ANTHONY B. BOLA',
  //   'designation': 'Temporary GPS Section Staff Cashier',
  //   'idPicture':
  //       'https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/49F840081DA767BCF7CBF9CAA098BA426ADCA78817C5AA98F79C7D4E1C5CB088.png?RCType=EmbeddedRCFileProcessor, idSignature: https://fms.dltbbus.com.ph/Streaming_SSL/MainDB/BF76BDA3BD65F0ED8917A7C8EBF7F1C9DA1623991618DF0DCE78A9D64C831A2F.png?RCType=EmbeddedRCFileProcessor',
  //   'JTI_RFID': 'YES',
  //   'accessPrivileges': 'Cashier',
  //   'JTI_RFID_RequestDate': ''
  // };
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
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
                          'SYNCING MENU',
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.535,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      loadingModal.showSyncing(context);

                                      await Future.delayed(
                                          Duration(seconds: 3));
                                      await _offlineSyncting();
                                      bool resetTrip =
                                          await hiveService.resetTrip();
                                      Navigator.of(context).pop();
                                      if (resetTrip) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()));
                                      } else {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "SOMETHING WENT  WRONG",
                                                text: "Please try again"));
                                      }
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFd9d9d9),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Image.asset(
                                                  'assets/sync-folder.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'SYNCING',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 20),
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width,
                            //   height: 60,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       Navigator.pushReplacement(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) => LoginPage()));
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       primary: Color(
                            //           0xFF00adee), // Background color of the button
                            //       padding: EdgeInsets.symmetric(horizontal: 24.0),
                            //       shape: RoundedRectangleBorder(
                            //         side: BorderSide(width: 1, color: Colors.black),
                            //         borderRadius:
                            //             BorderRadius.circular(10.0), // Border radius
                            //       ),
                            //     ),
                            //     child: FittedBox(
                            //       fit: BoxFit.scaleDown,
                            //       child: Text(
                            //         'BACK',
                            //         style: TextStyle(
                            //             color: Colors.white,
                            //             fontSize:
                            //                 MediaQuery.of(context).size.width * 0.05,
                            //             fontWeight: FontWeight.bold),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
