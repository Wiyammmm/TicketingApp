import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TopUpPassengerCardPage extends StatefulWidget {
  const TopUpPassengerCardPage({super.key});

  @override
  State<TopUpPassengerCardPage> createState() => _TopUpPassengerCardPageState();
}

class _TopUpPassengerCardPageState extends State<TopUpPassengerCardPage> {
  fetchServices fetchService = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  GeneratorServices generatorServices = GeneratorServices();
  HiveService hiveservicers = HiveService();
  checkCards isCardExisting = checkCards();
  TestPrinttt printServices = TestPrinttt();
  httprequestService httpRequestServices = httprequestService();
  TextEditingController amountController = TextEditingController();
  LoadingModal loadingModal = LoadingModal();
  var MasterCardData = {};
  var FilipayCardData = {};
  String masterCardId = '';
  String passengerCardId = '';
  bool isNfcScanOn = false;
  bool isEnableInput = true;
  String vehicleNo = '';

  @override
  void initState() {
    super.initState();
    vehicleNo = fetchService.getCurrentVehicleNo();
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  void _startNFCReader(String typeCard) async {
    if (!isNfcScanOn) {
      return;
    }
    try {
      List<Map<String, dynamic>> cardList = [];
      if (typeCard == 'passenger') {
        cardList = fetchService.fetchFilipayCardList();
        // cardList = cardList
        //     .where((station) => station['cardType'] == typeCard)
        //     .toList();
      } else if (typeCard == 'mastercard') {
        cardList = fetchService.fetchMasterCardList();
        cardList = cardList
            .where((station) => station['cardType'] == typeCard)
            .toList();
      } else {
        return;
      }

      final result = await backend.startNFCReader();
      if (result != null) {
        loadingModal.showProcessing(context);
        bool isCardIDExisting =
            cardList.any((card) => card['cardID'] == result);

        if (isCardIDExisting) {
          var cardData = cardList.firstWhere((card) => card['cardID'] == result,
              orElse: () => <String, Object>{});
          print('cardid: $result');
          print('cardData: $cardData');
          if (masterCardId == '') {
            MasterCardData = cardData;
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.success,
                    title: "SUCCESS",
                    text: ""));
          } else {
            FilipayCardData = cardData;
            passengerCardId = result;

            loadingModal.showProcessing(context);
            Map<String, dynamic> isTopupPassenger =
                await httpRequestServices.topUpPassenger(passengerCardId,
                    masterCardId, double.parse(amountController.text));

            // await Future.delayed(Duration(seconds: 3));
            if (isTopupPassenger['messages'][0]['code'].toString() == "0") {
              String referenceNumber = generatorServices.referenceNumber();
              Map<String, dynamic> requestBody = {
                "messages": [
                  {
                    'code': isTopupPassenger['messages'][0]['code'],
                    'message': 'OK',
                    'dateTime': 'Mon Nov-27-2023, 02:18 PM',
                  }
                ],
                'response': {
                  'referenceNumber': referenceNumber,
                  'mastercard': {
                    'previousBalance': isTopupPassenger['response']
                        ['mastercard']['previousBalance'],
                    'newBalance': isTopupPassenger['response']['mastercard']
                        ['newBalance'],
                    'empNo': '${MasterCardData['empNo']}',
                  },
                  'filipayCard': {
                    'previousBalance': isTopupPassenger['response']
                        ['filipayCard']['previousBalance'],
                    'newBalance': isTopupPassenger['response']['filipayCard']
                        ['newBalance'],
                  }
                }
              };
              bool isAddTopup = await hiveservicers.addToup(requestBody);
              if (!isAddTopup) {
                ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.success,
                        title: "ERROR",
                        text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));

                return;
              }
              bool isPrintDone = await printServices.printTopUpPassengerReceipt(
                  "${FilipayCardData['sNo']}",
                  "${MasterCardData['sNo']}",
                  vehicleNo,
                  double.parse(amountController.text),
                  double.parse(isTopupPassenger['response']['filipayCard']
                          ['previousBalance']
                      .toString()),
                  double.parse(isTopupPassenger['response']['filipayCard']
                          ['newBalance']
                      .toString()),
                  double.parse(isTopupPassenger['response']['mastercard']
                          ['previousBalance']
                      .toString()),
                  double.parse(isTopupPassenger['response']['mastercard']
                          ['newBalance']
                      .toString()),
                  referenceNumber);

              ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.success,
                          title: "SUCCESSFULLY RECHARGE",
                          text: "THANK YOU"))
                  .then((alertresult) {
                if (mounted) {
                  setState(() {
                    isNfcScanOn = false;
                  });
                }

                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => CundoctorPage()));
              });
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "ERROR",
                      text: "${isTopupPassenger['messages'][0]['message']}"));
            }
          }
          // Navigator.of(context).pop();
          // ArtSweetAlert.show(
          //         context: context,
          //         artDialogArgs: ArtDialogArgs(
          //             type: ArtSweetAlertType.success,
          //             title: "SUCCESS",
          //             text: ""))
          //     .then((alertresult) async {
          //   if (masterCardId == '') {
          //     Navigator.of(context).pop();
          //   }

          // });
          setState(() {
            if (masterCardId == '') {
              masterCardId = result;
              isEnableInput = false;
            }
            print('isEnableInput: $isEnableInput');
            print('mastercardid: $masterCardId');
            print('passengercardid: $passengerCardId');
          });
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INVALID",
                  text: "PLEASE TAP VALID CARD"));
        }
      }
      _startNFCReader(typeCard);
      return;
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "ERROR",
              text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
    }
    // _startNFCReaderDashboard();
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
              child: Column(
            children: [
              appbar(),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TOP-UP PASSENGER CARD',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.85,
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
                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              controller: amountController,
                              enabled: isEnableInput,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter
                                    .digitsOnly, // Allow only digits (0-9)
                                FilteringTextInputFormatter
                                    .digitsOnly, // Prevent line breaks
                              ],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.primaryColor),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter Amount',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: AppColors.primaryColor),
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (amountController.text != '') {
                                    double amount =
                                        double.parse(amountController.text);
                                    if (amount > 0) {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      String cardType = '';

                                      if (masterCardId == '') {
                                        cardType = 'mastercard';
                                        _showDialognfcScan(context,
                                            'MASTER CARD', 'master-card.png');
                                      } else {
                                        cardType = 'passenger';
                                        _showDialognfcScan(
                                            context,
                                            'PASSENGER CARD',
                                            'FILIPAY Cards - Regular.png');
                                      }

                                      _startNFCReader(cardType);
                                    } else {
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "ERROR",
                                              text: "Please put valid amount"));
                                    }
                                  } else {
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "MISSING",
                                            text: "Please put amount first"));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors
                                      .primaryColor, // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: Text(
                                  masterCardId == ''
                                      ? 'TAP MASTER CARD'
                                      : 'TAP PASSENGER CARD',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
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
                            builder: (context) => CundoctorPage()));
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
    );
  }

  void _showDialognfcScan(
      BuildContext context, String cardType, String cardImg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TAP YOUR CARD',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/$cardImg',
                                    width: 200,
                                    height: 200,
                                  )),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/nfc.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${cardType.toUpperCase()}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      setState(() {
        isNfcScanOn = false;
      });
    });
  }
}
