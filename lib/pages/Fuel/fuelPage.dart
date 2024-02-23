import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dltb/backend/checkcards/checkCards.dart';
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
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/ticketingMenu/checkinPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key, required this.fuelAttendantData});
  final fuelAttendantData;
  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  final _myBox = Hive.box('myBox');
  httprequestService httpRequestServices = httprequestService();
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  TextEditingController ticketNoController = TextEditingController();
  GeneratorServices generatorServices = GeneratorServices();
  timeServices timeService = timeServices();
  fetchServices fetchService = fetchServices();
  HiveService hiveService = HiveService();
  TestPrinttt printService = TestPrinttt();
  LoadingModal loadinglmodal = LoadingModal();
  final _formKey = GlobalKey<FormState>();
  bool isFullTank = false;
  String torNo = "";
  bool isNfcScanOn = false;
  // fuel controller
  TextEditingController fuelStationController = TextEditingController();

  List<String> suggestions = ['Apple', 'Banana', 'Orange', 'Grapes', 'Mango'];
  TextEditingController fuelLitersController = TextEditingController();
  TextEditingController fuelPricePerLiterController =
      TextEditingController(text: "0");
  TextEditingController fuelAmountController = TextEditingController(text: "0");

  // end fuel controller
  Map<String, dynamic> FuelAttendantData = {};
  List<Map<String, dynamic>> torTrip = [];
  Map<String, dynamic> coopData = {};
  Map<String, dynamic> session = {};
  bool isOffline = false;
  String control_no = '';
  bool isExpenses = false;
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    session = _myBox.get('SESSION');
    FuelAttendantData = widget.fuelAttendantData;
    torTrip = _myBox.get('torTrip');
    torNo = torTrip[session['currentTripIndex']]['tor_no'];
    control_no = torTrip[session['currentTripIndex']]['control_no'];
    coopData = fetchService.fetchCoopData();
    print('FuelAttendantData: $FuelAttendantData');
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Opacity(opacity: 0.5, child: Image.asset("assets/citybg.png")),
          ),
          SingleChildScrollView(
            child: Column(children: [
              appbar(),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'FUEL MENU',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height + 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (coopData['_id'] !=
                                    "655321a339c1307c069616e9")
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: fuelStationController,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.primaryColor),
                                      decoration: InputDecoration(
                                          hintText: 'FUEL STATION',
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      AppColors.primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                SizedBox(
                                  height: 5,
                                ),
                                if (coopData['_id'] ==
                                    "655321a339c1307c069616e9")
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TypeAheadField<City>(
                                          suggestionsCallback: (search) =>
                                              CityService.of(context)
                                                  .find(search),
                                          builder:
                                              (context, controller, focusNode) {
                                            return TextField(
                                                textAlign: TextAlign.center,
                                                controller:
                                                    fuelStationController,
                                                focusNode: focusNode,
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: "FUEL STATION"));
                                          },
                                          itemBuilder: (context, city) {
                                            return ListTile(
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              title: Text(
                                                city.name,
                                                textAlign: TextAlign.center,
                                              ),
                                              subtitle: Text(
                                                city.country,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                          onSelected: (city) {
                                            setState(() {
                                              fuelStationController.text =
                                                  city.name.toString();
                                            });

                                            print(
                                                "fuelStationController:  ${fuelStationController.text}");
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                // Container(
                                //     alignment: Alignment.center,
                                //     child: EasyAutocomplete(
                                //         controller: fuelStationController,
                                //         suggestions: [
                                //           'LEVERIZA',
                                //           'STA. CRUZ',
                                //           'TALIPAN',
                                //           'REYMER OLD',
                                //           'REYMER NEW',
                                //           'NASUGBU',
                                //           'BATANGAS',
                                //         ],
                                //         cursorColor: AppColors.primaryColor,
                                //         decoration: InputDecoration(
                                //             hintText:
                                //                 '                                FUEL STATION',

                                //             contentPadding: EdgeInsets.symmetric(
                                //                 vertical: 0, horizontal: 10),
                                //             focusedBorder: OutlineInputBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(5),
                                //                 borderSide: BorderSide(
                                //                     color: AppColors.primaryColor,
                                //                     style: BorderStyle.solid)),
                                //             enabledBorder: OutlineInputBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(5),
                                //                 borderSide: BorderSide(
                                //                     color: AppColors.primaryColor,
                                //                     style: BorderStyle.solid))),
                                //         suggestionBuilder: (data) {
                                //           return Container(
                                //               margin: EdgeInsets.all(1),
                                //               padding: EdgeInsets.all(5),
                                //               decoration: BoxDecoration(
                                //                   color: AppColors.primaryColor,
                                //                   borderRadius:
                                //                       BorderRadius.circular(5)),
                                //               alignment: Alignment.center,
                                //               transformAlignment:
                                //                   Alignment.center,
                                //               child: Text(data,
                                //                   textAlign: TextAlign.center,
                                //                   style: TextStyle(
                                //                       color: Colors.white)));
                                //         },
                                //         onChanged: (value) {
                                //           setState(() {
                                //             fuelStationController.text = value;
                                //           });
                                //         })),

                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: fuelLitersController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                    decoration: InputDecoration(
                                        hintText: 'FUEL LITERS',
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AppColors.primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      updateAmount();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: fuelPricePerLiterController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                    decoration: InputDecoration(
                                        hintText: 'FUEL PRICE PER LITER',
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AppColors.primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    validator: (value) {
                                      if (isExpenses) {
                                        if (value!.isEmpty) {
                                          return 'Required';
                                        } else if (double.parse(value) == 0) {
                                          return 'Required';
                                        }
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      updateAmount();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: fuelAmountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                    decoration: InputDecoration(
                                        hintText: 'Enter Amount',
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: AppColors.primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    validator: (value) {
                                      if (isExpenses) {
                                        if (value!.isEmpty) {
                                          return 'Required';
                                        } else if (double.parse(value) == 0) {
                                          return 'Required';
                                        }
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Full Tank',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: Checkbox(
                                          activeColor:
                                              Color.fromARGB(255, 0, 80, 109),
                                          value: isFullTank,
                                          onChanged: (value) {
                                            setState(() {
                                              isFullTank = !isFullTank;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Expenses',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: Checkbox(
                                          activeColor:
                                              Color.fromARGB(255, 0, 80, 109),
                                          value: isExpenses,
                                          onChanged: (value) {
                                            setState(() {
                                              isExpenses = !isExpenses;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                // Container(
                                //   decoration: BoxDecoration(
                                //       border: Border.all(
                                //           width: 1,
                                //           color: AppColors.primaryColor),
                                //       borderRadius:
                                //           BorderRadius.circular(10)),
                                //   child: DropdownButton<String>(
                                //     isExpanded: true,
                                //     hint: const Row(
                                //       children: [
                                //         SizedBox(width: 4),
                                //         Expanded(
                                //           child: Text(
                                //             'FULL TANK',
                                //             textAlign: TextAlign.center,
                                //             style: TextStyle(
                                //               fontSize: 14,
                                //               fontWeight:
                                //                   FontWeight.bold,
                                //               color: AppColors.primaryColor,
                                //             ),
                                //             overflow:
                                //                 TextOverflow.ellipsis,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     value: selectedValue,
                                //     onChanged: (newValue) {
                                //       setState(() {
                                //         selectedValue = newValue!;
                                //       });
                                //     },
                                //     items: <String>['Yes', 'No']
                                //         .map<DropdownMenuItem<String>>(
                                //             (String value) {
                                //       return DropdownMenuItem<String>(
                                //         value: value,
                                //         child: Center(
                                //           child: Text(
                                //             value.toUpperCase(),
                                //             textAlign: TextAlign.center,
                                //             style: const TextStyle(
                                //               fontSize: 14,
                                //               fontWeight:
                                //                   FontWeight.bold,
                                //               color: AppColors.primaryColor,
                                //             ),
                                //             overflow:
                                //                 TextOverflow.ellipsis,
                                //           ),
                                //         ),
                                //       );
                                //     }).toList(),

                                //   ),
                                // )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DashboardPage()));
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
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              child: ElevatedButton(
                                onPressed: () async {
                                  double particularAmount = 0.0;
                                  double fuelLiters = 0.0;
                                  double fuelamount = 0.0;
                                  double fuelpriceperliter = 0.0;

                                  if (!_formKey.currentState!.validate()) {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.info,
                                            title: "INCOMPLETE",
                                            text: "PLEASE COMPLETE THE FORM"));
                                    return;
                                  } else {
                                    final coopData =
                                        fetchService.fetchCoopData();
                                    final session = _myBox.get('SESSION');
                                    String uuid =
                                        generatorServices.generateUuid();
                                    // String controlNo =
                                    //     torTrip[session['currentTripIndex']]
                                    //         ['control_no'];
                                    final currentTorTrip =
                                        torTrip[session['currentTripIndex']];
                                    try {
                                      particularAmount = double.parse(
                                          fuelAmountController.text);
                                    } catch (e) {
                                      particularAmount = 0;
                                    }
                                    try {
                                      fuelLiters = double.parse(
                                          fuelLitersController.text);
                                    } catch (e) {
                                      fuelLiters = 0;
                                    }
                                    try {
                                      fuelamount = double.parse(
                                          fuelAmountController.text);
                                    } catch (e) {
                                      fuelamount = 0;
                                    }
                                    try {
                                      fuelpriceperliter = double.parse(
                                          fuelPricePerLiterController.text);
                                    } catch (e) {
                                      fuelpriceperliter = 0;
                                    }

                                    String dateOfTrip =
                                        timeService.dateofTrip2();
                                    String dateTimeNow =
                                        timeService.departedTime2();

                                    final myLocation = _myBox.get('myLocation');

                                    Map<String, dynamic>
                                        requestBodyItemTorTrip = {
                                      "coopId": "${coopData['_id']}",
                                      "UUID": "$uuid",
                                      "device_id": "${session['serialNumber']}",
                                      "control_no":
                                          "${currentTorTrip['control_no']}",
                                      "tor_no": "${session['torNo']}",
                                      "date_of_trip": "$dateOfTrip",
                                      "bus_no": "${currentTorTrip['bus_no']}",
                                      "route": "${currentTorTrip['route']}",
                                      "route_code":
                                          "${currentTorTrip['route_code']}",
                                      "bound": "${currentTorTrip['bound']}",
                                      "trip_no": currentTorTrip['trip_no'],
                                      "refuel_date": "$dateTimeNow",
                                      "refuel_time": "$dateTimeNow",
                                      "fuel_station":
                                          "${fuelStationController.text}",
                                      "fuel_liters": fuelLiters,
                                      "fuel_amount": fuelamount,
                                      "fuel_price_per_liter": fuelpriceperliter,
                                      "fuel_attendant":
                                          "${FuelAttendantData['lastName']}, ${FuelAttendantData['firstName']} ${FuelAttendantData['middleName']}",
                                      "full_tank": isFullTank ? "YES" : "NO",
                                      "timestamp": "$dateTimeNow",
                                      "lat":
                                          '${myLocation?['latitude'] ?? 0.00}',
                                      "long":
                                          '${myLocation?['longitude'] ?? 0.00}',
                                      "remarks": ""
                                    };

                                    setState(() {
                                      isNfcScanOn = true;
                                    });
                                    _verificationCard(
                                      requestBodyItemTorTrip,
                                      particularAmount,
                                      fuelLiters,
                                      fuelamount,
                                      fuelpriceperliter,
                                    );
                                    _showTapVerificationCard(context);
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
                                    'SUBMIT',
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
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              )
            ]),
          ),
        ],
      )),
    );
  }

  void updateAmount() {
    double Liters = 0;
    double pricePerLiters = 0;
    if (fuelLitersController.text != "" &&
        fuelPricePerLiterController.text != "") {
      Liters = double.parse(fuelLitersController.text);
      pricePerLiters = double.parse(fuelPricePerLiterController.text);

      setState(() {
        fuelAmountController.text = (Liters * pricePerLiters).toString();
      });
    }
  }

  void _verificationCard(
      Map<String, dynamic> requestBodyItemTorTrip,
      double particularAmount,
      double fuelLiters,
      double fuelamount,
      double fuelpriceperliter) async {
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
              emptype.toLowerCase().contains("driver")) {
            loadinglmodal.showLoading(context);
            Map<String, dynamic> addTorFuel =
                await httpRequestServices.addTorFuel(requestBodyItemTorTrip);
            if (addTorFuel['messages'][0]['code'].toString() == "0") {
              Navigator.of(context).pop();
              if (isExpenses) {
                bool isAddedExpenses = await hiveService.addExpenses({
                  'particular': "Fuel",
                  'amount': particularAmount,
                  'tor_no': torNo,
                  "control_no": control_no
                });
              }

              bool isprintDone =
                  await printService.printFuel(requestBodyItemTorTrip);
              ArtSweetAlert.show(
                      context: context,
                      barrierDismissible: false,
                      artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.success,
                          title: "SUCCESS",
                          text: "Added Successfully"))
                  .then((alertresult) {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => DashboardPage()));
              });
            } else if (addTorFuel['messages'][0]['code'].toString() == "500") {
              Navigator.of(context).pop();
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

                        print('addOfflineFuel: $isOffline');
                      },
                      onDeny: () {
                        print('deny');

                        Navigator.of(context).pop();
                        return;
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                        return;
                      },
                      text:
                          "Are you sure you would like to use Offline mode?"));
            } else {
              ArtSweetAlert.show(
                  context: context,
                  barrierDismissible: false,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.warning,
                      title: "ERROR",
                      text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
            }

            if (isOffline) {
              setState(() {
                isNfcScanOn = true;
              });

              bool isAddOfflineFuel =
                  await hiveService.addOfflineFuel(requestBodyItemTorTrip);
              if (isAddOfflineFuel) {
                bool isprintDone =
                    await printService.printFuel(requestBodyItemTorTrip);
                if (isExpenses) {
                  bool isAddedExpenses = await hiveService.addExpenses({
                    'particular': "Fuel",
                    'amount': particularAmount,
                    'tor_no': torNo,
                    "control_no": control_no
                  });
                }
                ArtSweetAlert.show(
                        context: context,
                        barrierDismissible: false,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.success,
                            title: "SUCCESS",
                            text: "Added Successfully"))
                    .then((alertresult) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => DashboardPage()));
                });
              } else {
                ArtSweetAlert.show(
                    context: context,
                    barrierDismissible: false,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.warning,
                        title: "ERROR",
                        text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
              }
            }
          }
        }
      }
    } catch (e) {}
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
}

class CityService {
  // Replace this with your actual data-fetching logic.
  List<City> find(String search) {
    // For demonstration purposes, returning a static list.
    return [
      City(name: 'LEVERIZA', country: 'TANK 1'),
      City(name: 'STA. CRUZ', country: 'TANK 2'),
      City(name: 'TALIPAN', country: 'TANK 3'),
      City(name: 'REYMER OLD', country: 'TANK 4'),
      City(name: 'REYMER NEW', country: 'TANK 5'),
      City(name: 'NASUGBU', country: 'TANK 6'),
      City(name: 'BATANGAS', country: 'TANK 7'),
      // Add more cities as needed.
    ];
  }

  static CityService of(BuildContext context) {
    // Implement this method if you are using a service locator or dependency injection.
    // For simplicity, returning a new instance for demonstration purposes.
    return CityService();
  }
}

class City {
  final String name;
  final String country;

  City({required this.name, required this.country});
}

class CityPage extends StatelessWidget {
  final City city;

  CityPage({required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('City: ${city.name}'),
            Text('Country: ${city.country}'),
          ],
        ),
      ),
    );
  }
}
