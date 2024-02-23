import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';

import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/backend/validator/validator.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/closingMenu/topupMasterCard.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/specialtrip.dart';
import 'package:dltb/pages/syncingMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:nfc_manager/nfc_manager.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../backend/nfcreader.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _myBox = Hive.box('myBox');
  httprequestService httpRequestServices = httprequestService();
  LoadingModal loadingModal = LoadingModal();
  timeServices dateService = timeServices();
  HiveService hiveService = HiveService();
  GeneratorServices generatorService = GeneratorServices();
  String serialNumber = '';

  TextEditingController torNoController = TextEditingController();

  bool isManualTor = false;
  bool isRegularTrip = true;
  bool isViceVersa = false;
  bool isDriverLogin = false;
  bool isDispatcherLogin = false;
  bool isConductorLogin = false;

  String? driverName;
  String? dispatcherName;
  String? conductorName;

  String? selectedBound;
  // bool isPreparing = true;
  fetchServices fetchservice = fetchServices();

  NFCReaderBackend backend = NFCReaderBackend();
  TestPrinttt DispatchPrint = TestPrinttt();
  DeviceInfoService DeviceInfo = DeviceInfoService();
  checkCards isCardExisting = checkCards();
  ServiceValidator validator = ServiceValidator();
  List<Map<String, dynamic>> stationList = [];
  List<Map<String, dynamic>> routeList = [];
  List<Map<String, dynamic>> vehicleList = [];
  List<Map<String, dynamic>> vehicleListDB = [];
  List<Map<String, dynamic>> cardList = [];
  Map<String, dynamic> SESSION = {};
  List<Map<String, dynamic>> torTrip = [];
  String? code;

  String? selectedRoute;

  String? selectedVehicle;
  String? dispatcherEmpNo;
  String? driverEmpNo;
  String? conductorEmpNo;
  TextEditingController textEditingController = TextEditingController();
  // Map<String, dynamic> allInfo = {};
  bool isExit = false;
  String selectedRouteID = '';
  String torNo = '';
  bool isRepeatTOR = false;

  bool isDriverRepeat = false;
  bool isConductorRepeat = false;
  int flag = 0;
  Map<String, dynamic> coopData = {};
  String departedPlace = "";
  List<String> uniqueBounds = [];
  @override
  void initState() {
    super.initState();

    torNo = generatorService.generateTorNo();
    SESSION = _myBox.get('SESSION');
    torTrip = _myBox.get('torTrip');
    stationList = fetchservice.fetchStationList();
    coopData = fetchservice.fetchCoopData();
    // print('torTrip: $torTrip');
    // print('SESSION: $SESSION');
    routeList = fetchservice.fetchRouteList();
    vehicleList = fetchservice.fetchVehicleList();
    vehicleListDB = fetchservice.fetchVehicleListDB();
    cardList = fetchservice.fetchCardList();
    // _showLoading();
    uniqueBounds = routeList
        .map((route) => route['bound'].toString()) // Access 'bound' key
        .toSet()
        .toList();
    _startNFCReader();
    // Printy();
  }

  // @override
  // void dispose() {
  //   textEditingController.dispose();
  //   isExit = true;
  //   super.dispose();
  // }

  void _checkRepeatDriverTor(String employeeID) {
    try {
      if (torTrip[SESSION['currentTripIndex'] - 1]['driver_id'].toString() ==
          employeeID) {
        print(
            'driverid TOR: ${torTrip[SESSION['currentTripIndex'] - 1]['driver_id']}');
        setState(() {
          if (!isDriverRepeat) {
            flag++;
          }
          isDriverRepeat = true;
        });
      } else {
        print(
            'driverid TOR: ${torTrip[SESSION['currentTripIndex'] - 1]['driver_id']}');
        setState(() {
          if (isDriverRepeat) {
            flag--;
            torNoController.text = '';
          }

          isDriverRepeat = false;
        });
      }
      print('passed empno : $employeeID');
      if (flag == 2) {
        setState(() {
          torNoController.text = SESSION['torNo'];
        });
      } else {
        if (isManualTor) {
          setState(() {
            isManualTor = !isManualTor;
          });
        }
      }
      print(flag);
    } catch (e) {
      print(e);
    }
  }

  void _checkRepeatConductorTor(String employeeID) {
    try {
      if (torTrip[SESSION['currentTripIndex'] - 1]['conductor_id'].toString() ==
          employeeID) {
        print(
            'conductorid tor: ${torTrip[SESSION['currentTripIndex'] - 1]['conductor_id']}');
        setState(() {
          if (!isConductorRepeat) {
            flag++;
          }
          isConductorRepeat = true;
        });
      } else {
        print(
            'conductorid tor: ${torTrip[SESSION['currentTripIndex'] - 1]['conductor_id']}');
        setState(() {
          if (isConductorRepeat) {
            flag--;
            torNoController.text = '';
          }

          isConductorRepeat = false;
        });
      }
      print('passed empno : $employeeID');

      if (flag == 2) {
        setState(() {
          torNoController.text = SESSION['torNo'];
        });
      }
      print(flag);
    } catch (e) {
      print(e);
    }
  }

  void _startNFCReader() async {
    print('started nfc');

    if (isExit) {
      return;
    }
    try {
      // await backend.checkNFC();
      String? result;
      // final result = await backend.startNFCReader();
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print('${tag.data}');
          // Do something with an NfcTag instance.
          String tagId = fetchservice.extractTagId(tag);
          // setState(() {

          result = tagId;
          print('tagid: $result');
          if (result != null) {
            if (isManualTor) {
              setState(() {
                torNoController.text =
                    "$selectedVehicle-${generatorService.generateTorNo()}";
              });
            }

            // Update the serialNumber with the UID (serial number)
            if (mounted) {
              setState(() {
                serialNumber = result!;
              });
            }

            final isCardExistingResult = isCardExisting.isCardExisting(result!);
            print("isCardExistingResult: $isCardExistingResult");
            if (isCardExistingResult != null &&
                isCardExistingResult.isNotEmpty) {
              print('isCardExistingResult: $isCardExistingResult');
              print(
                  'name: ${isCardExistingResult['firstName']} ${isCardExistingResult['middleName'].toString()} ${isCardExistingResult['lastName']}');
              String emptype = isCardExistingResult['designation'];
              if (emptype.toLowerCase().contains("driver")) {
                if (mounted) {
                  _checkRepeatDriverTor(
                      isCardExistingResult['empNo'].toString());
                  setState(() {
                    driverEmpNo = isCardExistingResult['empNo'].toString();
                    driverName =
                        "${isCardExistingResult['firstName']} ${isCardExistingResult['middleName'].toString()} ${isCardExistingResult['lastName']}";
                    isDriverLogin = true;
                  });
                }
              } else if (emptype.toLowerCase().contains("dispatcher")) {
                if (mounted) {
                  setState(() {
                    dispatcherEmpNo = isCardExistingResult['empNo'].toString();
                    print('dispatcherEmpNo: $dispatcherEmpNo');
                    dispatcherName =
                        "${isCardExistingResult['firstName']} ${isCardExistingResult['middleName'].toString()} ${isCardExistingResult['lastName']}";
                    isDispatcherLogin = true;
                  });
                }
              } else if (emptype.toLowerCase().contains("conductor")) {
                conductorEmpNo = isCardExistingResult['empNo'].toString();
                if (mounted) {
                  _checkRepeatConductorTor(
                      isCardExistingResult['empNo'].toString());
                  setState(() {
                    conductorName =
                        "${isCardExistingResult['firstName']} ${isCardExistingResult['middleName'].toString()} ${isCardExistingResult['lastName']}";
                    isConductorLogin = true;
                  });
                }
              } else if (emptype.toLowerCase().contains("cashier")) {
                // if (torTrip.isNotEmpty) {
                if (SESSION['isClosed']) {
                  NfcManager.instance.stopSession();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SyncingMenuPage()));
                } else {
                  NfcManager.instance.stopSession();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClosingMenuPage(
                                cashierData: isCardExistingResult,
                              )));
                }
              }
            } else {
              print('Card $result does not exist in the list.');
            }
            // if (mounted) {
            //   setState(() {
            //     isPreparing = false;
            //   });
            // }

            // _startNFCReader();

            return;

            // Handle other NFC operations as needed
            // For example, you can read NDEF records here.
          } else {
            print('null to');
            // if (mounted) {
            //   setState(() {
            //     isPreparing = false;
            //   });
            // }

            // _startNFCReader();

            return;
          }
          // });
        },
      );
      // allInfo = await DeviceInfo.getDeviceSerialNumber();
      // print('allinfo: $allInfo');
      // Printy();
    } catch (e) {
      print('e_startNFCReader: $e');
      // if (mounted) {
      //   setState(() {
      //     isPreparing = false;
      //   });
      // }

      // _startNFCReader();

      return;
    }
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
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
          _startNFCReader();

          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        child: Scaffold(
            body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height + 50,
            child: SingleChildScrollView(
              child: Column(children: [
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
                    child: SingleChildScrollView(
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
                            decoration: BoxDecoration(color: Color(0xFF46aef2)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'SELECT',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF00558d),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  items: vehicleList
                                                      .map((vehicle) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: vehicle[
                                                                'vehicle_no'],
                                                            child: Center(
                                                              child: Text(
                                                                '${vehicle['vehicle_no']!.toUpperCase()}: ${vehicle['plate_number']!.toUpperCase()}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xFF00558d),
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  value: selectedVehicle,
                                                  onChanged: (value) {
                                                    if (mounted) {
                                                      setState(() {
                                                        selectedVehicle =
                                                            value!;

                                                        String newTorNo = "";

                                                        if (isManualTor) {
                                                          newTorNo =
                                                              '$selectedVehicle-$torNo';
                                                        }
                                                        if (flag == 2) {
                                                          newTorNo =
                                                              SESSION['torNo'];
                                                        }
                                                        torNoController.text =
                                                            newTorNo;
                                                        print(
                                                            'selectedVehicle: $selectedVehicle');
                                                      });
                                                    }
                                                  },
                                                  buttonStyleData:
                                                      ButtonStyleData(
                                                    height: 50,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF00558d),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData:
                                                      const IconStyleData(
                                                    icon: Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                    ),
                                                    iconSize: 14,
                                                    iconEnabledColor:
                                                        Color(0xFF00558d),
                                                    iconDisabledColor:
                                                        Colors.grey,
                                                  ),

                                                  dropdownStyleData:
                                                      DropdownStyleData(
                                                    maxHeight: 200,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Color(
                                                              0xFF00558d)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white,
                                                    ),
                                                    offset:
                                                        const Offset(-20, 0),
                                                    scrollbarTheme:
                                                        ScrollbarThemeData(
                                                      radius:
                                                          const Radius.circular(
                                                              40),
                                                      thickness:
                                                          MaterialStateProperty
                                                              .all(6),
                                                      thumbVisibility:
                                                          MaterialStateProperty
                                                              .all(true),
                                                    ),
                                                  ),
                                                  menuItemStyleData:
                                                      const MenuItemStyleData(
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                  ),
                                                  dropdownSearchData:
                                                      DropdownSearchData(
                                                    searchController:
                                                        textEditingController,
                                                    searchInnerWidgetHeight: 50,
                                                    searchInnerWidget:
                                                        Container(
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
                                                            textEditingController,
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
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    searchMatchFn:
                                                        (item, searchValue) {
                                                      return item.value
                                                          .toString()
                                                          .contains(
                                                              searchValue);
                                                    },
                                                  ),
                                                  //This to clear the search value when you close the menu
                                                  onMenuStateChange: (isOpen) {
                                                    if (!isOpen) {
                                                      textEditingController
                                                          .clear();
                                                    }
                                                  },
                                                ),
                                              ),
                                              //     TextFormField(
                                              //   decoration: InputDecoration(
                                              //     filled: true,
                                              //     fillColor: Colors.white,
                                              //     contentPadding:
                                              //         EdgeInsets.symmetric(horizontal: 25),
                                              //     border: OutlineInputBorder(
                                              //       borderRadius: BorderRadius.circular(
                                              //           10.0), // Rounded border radius
                                              //       borderSide: BorderSide.none,
                                              //     ),
                                              //   ),
                                              // )
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          flag == 2
                                              ? '       SAME TOR'
                                              : (isManualTor
                                                  ? '           GENERATED TOR'
                                                  : '          TYPE TOR'),
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              activeColor: Color.fromARGB(
                                                  255, 0, 80, 109),
                                              value: isManualTor,
                                              onChanged: (value) {
                                                if (flag != 2) {
                                                  setState(() {
                                                    isManualTor = !isManualTor;
                                                    if (isManualTor) {
                                                      String newTorNo = "";

                                                      if (isManualTor) {
                                                        newTorNo =
                                                            '$selectedVehicle-${generatorService.generateTorNo()}';
                                                      }
                                                      if (flag == 2) {
                                                        newTorNo =
                                                            SESSION['torNo'];
                                                      }
                                                      torNoController.text =
                                                          newTorNo;
                                                    } else {
                                                      torNoController.text = '';
                                                    }
                                                  });
                                                }
                                              },
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: TextField(
                                                  controller: torNoController,
                                                  enabled: flag == 2
                                                      ? false
                                                      : !isManualTor,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (coopData['coopType'] == "Bus")
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: const Row(
                                        children: [
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Select Bound',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: uniqueBounds
                                          .map((bound) =>
                                              DropdownMenuItem<String>(
                                                value: bound,
                                                child: Text(
                                                  '${bound!.toUpperCase()}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: selectedBound,
                                      onChanged: (value) {
                                        if (mounted) {
                                          setState(() {
                                            selectedBound = value!;
                                            selectedRoute =
                                                null; // Reset the selected value when the bound changes
                                            print(
                                                'selectedBound: $selectedBound');
                                            print(
                                                'uniqueBounds: $uniqueBounds');
                                          });
                                        }
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        width: 160,
                                        padding: const EdgeInsets.only(
                                            left: 14, right: 14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          color: Color(0xFF00558d),
                                        ),
                                        elevation: 2,
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                        iconSize: 14,
                                        iconEnabledColor: Colors.white,
                                        iconDisabledColor: Colors.grey,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: Color(0xFF00558d),
                                        ),
                                        offset: const Offset(-20, 0),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(40),
                                          thickness:
                                              MaterialStateProperty.all(6),
                                          thumbVisibility:
                                              MaterialStateProperty.all(true),
                                        ),
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        height: 40,
                                        padding: EdgeInsets.only(
                                            left: 14, right: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Select Route',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: routeList
                                        .where((route) =>
                                            coopData['coopType'] == "Bus"
                                                ? route['bound'] ==
                                                    selectedBound
                                                : route['bound'] != "")
                                        .map((route) =>
                                            DropdownMenuItem<String>(
                                              value: isViceVersa
                                                  ? '${route['destination']} - ${route['origin']}'
                                                  : '${route['origin']} - ${route['destination']}',
                                              child: Text(
                                                isViceVersa
                                                    ? '${route['destination']} - ${route['origin']}'
                                                    : '${route['origin']} - ${route['destination']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedRoute,
                                    onChanged: (value) {
                                      if (mounted) {
                                        setState(() {
                                          selectedRoute = value;

                                          int selectedRouteIndex =
                                              routeList.indexWhere((route) =>
                                                  (isViceVersa
                                                      ? '${route['destination']} - ${route['origin']}'
                                                      : '${route['origin']} - ${route['destination']}') ==
                                                  value);

                                          selectedRouteID =
                                              '${routeList[selectedRouteIndex]['_id']}';
                                          departedPlace =
                                              '${routeList[selectedRouteIndex]['origin']}';
                                          print(
                                              'selected Route ID: ${routeList[selectedRouteIndex]['_id']}');
                                          selectedBound =
                                              '${routeList[selectedRouteIndex]['bound']}';
                                          print(
                                              'selectedRouteIndex: $selectedRouteIndex');
                                          print(
                                              'code: ${routeList[selectedRouteIndex]['code']}');
                                          code = routeList[selectedRouteIndex]
                                              ['code'];
                                          print(
                                              'selectedRoute: $selectedRoute');
                                        });
                                      }
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      width: 160,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                        color: Color(0xFF00558d),
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                      ),
                                      iconSize: 14,
                                      iconEnabledColor: Colors.white,
                                      iconDisabledColor: Colors.grey,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(14),
                                        color: Color(0xFF00558d),
                                      ),
                                      offset: const Offset(-20, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          NFCContainer(
                            type: 'dispatcher',
                            isLogin: isDispatcherLogin,
                            name: dispatcherName ?? '',
                          ),
                          NFCContainer(
                              type: 'driver',
                              isLogin: isDriverLogin,
                              name: driverName ?? ''),
                          NFCContainer(
                              type: 'conductor',
                              isLogin: isConductorLogin,
                              name: conductorName ?? ''),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      isRegularTrip = true;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: isRegularTrip
                                      ? Color(0xFF00558d)
                                      : Color(
                                          0xFFd9d9d9), // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'REGULAR TRIP',
                                    style: TextStyle(
                                        color: isRegularTrip
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      isRegularTrip = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: !isRegularTrip
                                      ? Color(0xFF00558d)
                                      : Color(
                                          0xFFd9d9d9), // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'SPECIAL TRIP',
                                    style: TextStyle(
                                        color: !isRegularTrip
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (torNoController.text == '') {
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.question,
                                          title: "MISSING",
                                          text:
                                              "PLEASE FILL UP THE TOR NUMBER"));
                                  return;
                                }
                                setState(() {
                                  isExit = true;

                                  // torNoController.text =
                                  //     "$selectedVehicle-${generatorService.generateTorNo()}";
                                });
                                Future<bool?> isDispatchValid =
                                    validator.isDispatchValid(
                                  selectedVehicle ?? '',
                                  selectedBound ?? '',
                                  selectedRoute ?? '',
                                  isDriverLogin,
                                  isDispatcherLogin,
                                  isConductorLogin,
                                );
                                bool? isValid = await isDispatchValid;

                                if (isValid != null && isValid) {
                                  loadingModal.showLoading(context);

                                  String dateofStrip =
                                      dateService.dateofTrip2();
                                  String departedTime =
                                      dateService.departedTime2();
                                  String departureTimeStamp =
                                      dateService.departureTimestamp2();
                                  final myLocation = _myBox.get('myLocation');
                                  String latitude =
                                      '${myLocation?['latitude'] ?? 0.00}';
                                  String longitude =
                                      '${myLocation?['longitude'] ?? 0.00}';
                                  // try {
                                  //   Position position =
                                  //       await Geolocator.getCurrentPosition(
                                  //               desiredAccuracy:
                                  //                   LocationAccuracy.high)
                                  //           .timeout(const Duration(seconds: 60));
                                  //   latitude = '${position.latitude}';
                                  //   longitude = '${position.longitude}';
                                  // } catch (e) {
                                  //   latitude = '14.00001';
                                  //   longitude = '15.00001';
                                  // }

                                  // Position position =
                                  //     await DeviceInfo.determinePosition();
                                  // print('device info position: $position');
                                  // print(
                                  //     'device info latitude: ${position.latitude}');
                                  // print(
                                  //     'device info longitude: ${position.longitude}');

                                  String serialNumber =
                                      await hiveService.getSerialNumber();
                                  String controlNo = await generatorService
                                      .generateControlNo();

                                  print(
                                      'device info serialNumber: $serialNumber');
                                  String plateNumber = vehicleList.firstWhere(
                                    (vehicle) =>
                                        vehicle['vehicle_no'] ==
                                        selectedVehicle,
                                    orElse: () => {'plate_number': ''},
                                  )['plate_number'];
                                  bool isaddDispatch =
                                      await hiveService.addDispatch({
                                    'driverEmpNo': driverEmpNo,
                                    'conductorEmpNo': conductorEmpNo,
                                    'dispatcher1': dispatcherEmpNo,
                                    'dispatcher2': '',
                                    'vehicleNo': '$selectedVehicle',
                                    'plate_number': '$plateNumber',
                                    'tor_no': '${torNoController.text}'
                                  });
                                  String uuid = generatorService.generateUuid();

                                  Map<String, dynamic> requestBodyItemTorTrip =
                                      {
                                    "UUID": "$uuid",
                                    "device_id": "$serialNumber",
                                    "control_no": "$controlNo",
                                    "tor_no": "${torNoController.text}",
                                    "date_of_trip": "$dateofStrip",
                                    "bus_no": "$selectedVehicle",
                                    "plate_number": "$plateNumber",
                                    "route": "$selectedRoute",
                                    "route_code": "$code",
                                    "bound": "$selectedBound",
                                    "trip_no": SESSION['currentTripIndex'] + 1,
                                    "departed_place": "$departedPlace",
                                    "departed_time": "$departedTime",
                                    "departed_dispatcher_id":
                                        "$dispatcherEmpNo",
                                    "departed_dispatcher": "$dispatcherName",
                                    "arrived_place": "",
                                    "arrived_time": "",
                                    "arrived_dispatcher_id": "",
                                    "arrived_dispatcher": "",
                                    "conductor_id": "$conductorEmpNo",
                                    "conductor": "$conductorName",
                                    "driver": "$driverName",
                                    "driver_id": "$driverEmpNo",
                                    "tripType":
                                        isRegularTrip ? 'regular' : 'special',
                                    "from_km": 0,
                                    "to_km": 0,
                                    "km_run": 0,
                                    "ticket_revenue_atm": 0,
                                    "ticket_count_atm": 0,
                                    "ticket_revenue_atm_passenger": 0,
                                    "ticket_revenue_atm_baggage": 0,
                                    "ticket_count_atm_passenger": 0,
                                    "ticket_count_atm_baggage": 0,
                                    "ticket_revenue_punch": 0,
                                    "ticket_count_punch": 0,
                                    "ticket_revenue_punch_passenger": 0,
                                    "ticket_revenue_punch_baggage": 0,
                                    "ticket_count_punch_passenger": 0,
                                    "ticket_count_punch_baggage": 0,
                                    "ticket_revenue_charter": 0,
                                    "ticket_count_charter": 0,
                                    "ticket_revenue_waybill": 0,
                                    "ticket_count_waybill": 0,
                                    "ticket_amount_cancelled": 0,
                                    "ticket_count_cancelled": 0,
                                    "ticket_amount_passes": 0,
                                    "ticket_count_passes": 0,
                                    "passenger_revenue": 0,
                                    "baggage_revenue": 0,
                                    "gross_revenue": 0,
                                    "passenger_count": 0,
                                    "baggage_count": 0,
                                    "departure_timestamp":
                                        "$departureTimeStamp",
                                    // "departure_lat": "14.4311",
                                    // "departure_long": "15.1231",
                                    "departure_lat": latitude,
                                    "departure_long": longitude,
                                    "arrival_timestamp": "",
                                    "arrival_lat": "",
                                    "arrival_long": "",
                                    "inspection_made": 0,
                                    "coopId": "${coopData['_id']}"
                                  };
                                  Map<String, dynamic> addTorTrip =
                                      await httpRequestServices
                                          .torTrip(requestBodyItemTorTrip);

                                  if (addTorTrip['messages'][0]['code']
                                          .toString() !=
                                      '0') {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "${addTorTrip['messages'][0]['message'].toString().toUpperCase()}"));
                                    return;
                                  }
                                  bool isAddedTrip = await hiveService
                                      .addTrip(requestBodyItemTorTrip);
                                  // bool isClose =
                                  //     await hiveService.updateClosing(false);
                                  // final isReadyNFC =
                                  //     await backend.startNFCReader();
                                  // _startNFCReader();
                                  Navigator.of(context).pop();
                                  if (isAddedTrip && isaddDispatch) {
                                    SESSION['routeID'] = '$selectedRouteID';
                                    SESSION['tripType'] =
                                        isRegularTrip ? 'regular' : 'special';
                                    SESSION['torNo'] =
                                        '${torNoController.text}';
                                    _myBox.put('SESSION', SESSION);

                                    final newSession = _myBox.get('SESSION');
                                    print('new SESSION: $newSession');

                                    DispatchPrint.printDispatch(
                                        '${torNoController.text}',
                                        driverName ?? '',
                                        conductorName ?? '',
                                        dispatcherName ?? '',
                                        isRegularTrip ? 'regular' : 'special',
                                        SESSION['currentTripIndex'] + 1,
                                        coopData['coopType'] == "Bus"
                                            ? selectedVehicle ?? ''
                                            : "$selectedVehicle:$plateNumber",
                                        selectedRoute ?? '',
                                        selectedBound ?? '');
                                    if (isRegularTrip) {
                                      NfcManager.instance.stopSession();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DashboardPage()));
                                    } else {
                                      NfcManager.instance.stopSession();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SpecialTripPage()));
                                    }
                                  } else {
                                    setState(() {
                                      isExit = false;
                                    });
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "SOMETHING WENT  WRONG",
                                            text: "Please try again"));
                                  }
                                } else {
                                  setState(() {
                                    isExit = false;
                                  });
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          title: "INCOMPLETE",
                                          text: "Please Fill all the data"));
                                  print('invalid po');
                                  // Invalid dispatch
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(
                                    0xFF00adee), // Background color of the button
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'DISPATCH',
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
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        )),
      ),
    );
  }
}

class NFCContainer extends StatelessWidget {
  const NFCContainer(
      {super.key,
      required this.type,
      required this.isLogin,
      required this.name});
  final String type;
  final bool isLogin;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: isLogin ? Color(0xFF2bc48a) : Color(0xFFd9d9d9),
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(Icons.person_4_sharp,
                    color: Color(0xFF46aef2),
                    size: MediaQuery.of(context).size.width * 0.15),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${type.toUpperCase()}',
                      style: TextStyle(
                          color: isLogin ? Colors.white : Color(0xFF4294ff),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  if (isLogin)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$name',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                ],
              ),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
