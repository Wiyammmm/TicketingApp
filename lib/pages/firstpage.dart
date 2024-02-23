import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';

import 'package:dltb/backend/nfcreader.dart';

import 'package:dltb/backend/printer/connectToPrinter.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/main.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:dltb/pages/specialtrip.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hive/hive.dart';
import 'package:location/location.dart';

import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _myBox = Hive.box('myBox');

  NFCReaderBackend backend = NFCReaderBackend();
  fetchServices fetchservice = fetchServices();
  EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  PrinterController connectToPrinter = PrinterController();

  double progressbar = 0.5;
  String progressText = 'fetching data...';
  @override
  void initState() {
    super.initState();

    _fetchingdata();
  }

  void _fetchingdata() async {
    final torTrip = _myBox.get('torTrip');
    // if (torTrip.isEmpty) {
    bool isfetchdata = await fetchservice.fetchdata();
    if (isfetchdata) {
      startLocationTracking();
      _connectToPrinter();
    } else {
      ArtSweetAlert.show(
              context: context,
              barrierDismissible: false,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "SOMETHING WENT WRONG",
                  text: "CLICK OK TO FETCH DATA AGAIN"))
          .then((value) {
        _fetchingdata();
      });
    }
    // _connectToPrinter();
    // } else {
    //   _connectToPrinter();
    // }
  }

  Future<void> startLocationTracking() async {
    final _myBox = await Hive.openBox('myBox');

    final coopData = _myBox.get('coopData');
    final session = _myBox.get('SESSION');
    httprequestService httpRequestServices = httprequestService();
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Enable background mode
    try {
      await location.enableBackgroundMode(enable: true);
      location.onLocationChanged.listen((LocationData newLocation) async {
        httprequestService httprequestservice = httprequestService();
        // Got a new connectivity status!
        final offlineTicket = _myBox.get('offlineTicket');
        final offlineUpdateAdditionalFare =
            _myBox.get('offlineUpdateAdditionalFare');
        final offlineInspection = _myBox.get('offlinetorInspection');

        final offlinetorViolation = _myBox.get('offlinetorViolation');
        final offlinetorFuel = _myBox.get('offlineFuel');
        print('offlineInspection: $offlineInspection');
        print('offlinetorViolation: $offlinetorViolation');
        print('offlineUpdateAdditionalFare: $offlineUpdateAdditionalFare');
        // if (torTicket.isNotEmpty) {
        //   List<Map<String, dynamic>> offlineDataList =
        //       torTicket.where((data) => data['isOffline'] == true).toList();
        //   print('connection offlineDataList: $offlineDataList');
        // }

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

            // if (offlineTicket.isEmpty) {
            //   return;
            // }
          }
          _myBox.put('offlineTicket', offlineTicket);
        }

        if (offlineUpdateAdditionalFare.isNotEmpty) {
          for (var itemAdditionalFare
              in List.from(offlineUpdateAdditionalFare)) {
            print('connection offlineTicket item: $itemAdditionalFare');
            itemAdditionalFare['isNegative'] = true;

            Map<String, dynamic> offlineAdditionalFare =
                await httprequestservice.updateAdditionalFare(
                    itemAdditionalFare, true);
            try {
              if (offlineAdditionalFare['messages'][0]['code'].toString() ==
                  "0") {
                print("offlineUpdateAdditionalFare success");
                offlineUpdateAdditionalFare.remove(itemAdditionalFare);
              } else {
                print(
                    'offlineUpdateAdditionalFare ${offlineAdditionalFare['messages']['message']}');
                print("failed");
              }
            } catch (e) {
              print("offlineUpdateAdditionalFare error: $e");
            }

            // if (offlineUpdateAdditionalFare.isEmpty) {
            //   return;
            // }
          }
          _myBox.put(
              'offlineUpdateAdditionalFare', offlineUpdateAdditionalFare);
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
            // if (offlineInspection.isEmpty) {
            //   continue;
            // }
          }
        }

        if (offlinetorViolation.isNotEmpty) {
          for (var item in List.from(offlinetorViolation)) {
            print('connection offlinetorViolation item: $item');
            Map<String, dynamic> resultofflineViolation =
                await httprequestservice.addViolation(item);
            try {
              if (resultofflineViolation['messages'][0]['code'].toString() ==
                  "0") {
                print("connection offlinetorViolation success");
                offlinetorViolation.remove(item);
              } else {
                print(
                    "connection offlinetorViolation failed ${resultofflineViolation['messages']['message']}");
              }
            } catch (e) {
              print('connection offlinetorViolation $e');
            }

            // if (offlinetorViolation.isEmpty) {
            //   return;
            // }
          }
          _myBox.put('offlinetorViolation', offlinetorViolation);
        }
        if (offlinetorFuel.isNotEmpty) {
          for (var item in List.from(offlinetorFuel)) {
            print('connection offlinetorFuel item: $item');
            Map<String, dynamic> resultofflineFuel =
                await httprequestservice.addTorFuel(item);

            try {
              if (resultofflineFuel['messages'][0]['code'].toString() == "0") {
                print("connection offlinetorFuel success");
                print('connection offlinetorFuel: $resultofflineFuel');
                offlinetorFuel.remove(item);
              } else {
                print(
                    "connection offlinetorFuel failed ${resultofflineFuel['messages']['message']}");
              }
            } catch (e) {
              print('connection offlinetorFuel $e');
            }

            // if (offlinetorViolation.isEmpty) {
            //   return;
            // }
          }
          _myBox.put('offlineFuel', offlinetorFuel);
        } else {
          print('connection offlinetorFuel empty');
        }

        _myBox.put('myLocation', {
          "latitude": "${newLocation.latitude}",
          "longitude": "${newLocation.longitude}"
        });
        print(
            "Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}");
        // Perform actions based on location change.
        if (coopData != null) {
          Map<String, dynamic> updateLocation =
              await httpRequestServices.updateLocation({
            "coopId": "${coopData['_id']}",
            "latitude": newLocation.latitude,
            "longitude": newLocation.longitude,
            "deviceId": "${session['serialNumber']}"
          });
        }
      });
    } catch (e) {
      print('getting location error: $e');
    }
  }

  void _connectToPrinter() async {
    try {
      const duration = Duration(
          seconds:
              2); // Adjust the duration as needed (3 seconds in this example).
      await Future.delayed(duration);
      setState(() {
        progressText = 'Checking & Preparing Printer...';
      });
      final resultprinter = await connectToPrinter.connectToPrinter();

      if (resultprinter != null) {
        print('resultprinter: $resultprinter');
        if (resultprinter) {
          getSerialNumber();
        } else {
          ArtDialogResponse response = await ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Can't connect to printer",
                  text: "Open Bluetooth to automatically connect"));
          print('response: $response');
          if (response.isTapConfirmButton) {
            _connectToPrinter();
          }
        }
      } else {
        ArtDialogResponse response = await ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Can't connect to printer",
                text: "Open Bluetooth to automatically connect"));
        print('else resultprinter: $resultprinter');
        print('response: $response');
        if (response.isTapConfirmButton) {
          _connectToPrinter();
        }
      }
      _refreshController.finishRefresh();
    } catch (e) {
      print(e);
    }
  }

  void getSerialNumber() async {
    final torTrip = _myBox.get('torTrip');
    final SESSION = _myBox.get('SESSION');
    const duration = Duration(
        seconds:
            2); // Adjust the duration as needed (3 seconds in this example).
    await Future.delayed(duration);
    setState(() {
      progressText = 'Preparing NFC Reader...';
    });

    // final resultNFC = await backend.startNFCReader();
    setState(() {
      progressText = 'Checking GPS...';
    });
    // try {
    //   Position position = await Geolocator.getCurrentPosition(
    //           desiredAccuracy: LocationAccuracy.high)
    //       .timeout(const Duration(seconds: 60));
    //   print('latitude: ${position.latitude}');
    //   print('longitude: ${position.longitude}');
    if (mounted) {
      setState(() {
        progressbar = 1;
      });
    }

    // await Future.delayed(
    //     const Duration(seconds: 1)); // Adjust the duration if needed
    if (torTrip.isEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      if ((SESSION['currentTripIndex'] + 1) == torTrip.length) {
        if (SESSION['tripType'] == "special") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SpecialTripPage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardPage()));
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }

    // } catch (e) {
    //   print('Error getting location: $e');
    //   ArtSweetAlert.show(
    //           context: context,
    //           artDialogArgs: ArtDialogArgs(
    //               type: ArtSweetAlertType.danger,
    //               title: "ERROR",
    //               text: "Can't get GPS, restart the application..."))
    //       .then((value) {
    //     print('error gps');
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => LoginPage()));
    //     // SystemNavigator.pop();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here, or return false to prevent it
        return false;
      },
      child: EasyRefresh(
        onRefresh: () async {
          _connectToPrinter();
        },
        controller: _refreshController,
        header: MaterialHeader(),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$progressText',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SimpleAnimationProgressBar(
                  height: 30,
                  width: 300,
                  backgroundColor: AppColors.secondaryColor,
                  foregrondColor: AppColors.primaryColor,
                  ratio: progressbar,
                  direction: Axis.horizontal,
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: const Duration(seconds: 5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
