import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:dltb/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TopUpMasterCardPage extends StatefulWidget {
  const TopUpMasterCardPage({super.key, required this.cashierData});
  final cashierData;
  @override
  State<TopUpMasterCardPage> createState() => _TopUpMasterCardPageState();
}

class _TopUpMasterCardPageState extends State<TopUpMasterCardPage> {
  fetchServices fetchService = fetchServices();
  GeneratorServices generatorServices = GeneratorServices();
  TestPrinttt printServices = TestPrinttt();
  NFCReaderBackend backend = NFCReaderBackend();
  TextEditingController amountController = TextEditingController();
  LoadingModal loadingModal = LoadingModal();
  String masterCardId = '';
  httprequestService httpRequestServices = httprequestService();

  bool isNfcScanOn = false;

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  void _startNFCReader() async {
    if (!isNfcScanOn) {
      return;
    }
    try {
      List<Map<String, dynamic>> cardList = [];

      cardList = fetchService.fetchMasterCardList();

      final result =
          await backend.startNFCReader().timeout(Duration(seconds: 30));
      if (result != null) {
        loadingModal.showProcessing(context);
        bool isCardIDExisting = cardList.any((card) =>
            card['cardId'].toString() == result.toString() ||
            card['cardID'].toString() == result.toString());
        if (isCardIDExisting) {
          var cardData = cardList.firstWhere(
              (card) =>
                  card['cardId'].toString() == result.toString() ||
                  card['cardID'].toString() == result.toString(),
              orElse: () => <String, Object>{});
          print('cardData: $cardData');
          print('cardid: $result');
          if (mounted) {
            setState(() {
              masterCardId = result;
              isNfcScanOn = false;
              print('mastercardid: $masterCardId');
            });
          }
          Map<String, dynamic> isUpdateBalance =
              await httpRequestServices.updateOnlineCardBalance(
                  result,
                  double.parse(amountController.text),
                  false,
                  'mastercard',
                  false);
          if (isUpdateBalance['messages'][0]['code'].toString() != '0') {
            Navigator.of(context).pop();
            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.danger,
                    title: "ERROR",
                    text:
                        "${isUpdateBalance['messages'][0]['message'].toString().toUpperCase()}"));
            return;
          } else {
            String referenceNumber = generatorServices.referenceNumber();
            String cardOwner =
                fetchService.getEmpName(cardData['empNo'].toString());
            String cashierName =
                '${widget.cashierData['firstName']} ${widget.cashierData['middleName']} ${widget.cashierData['lastName']}';
            bool isPrintdone = await printServices.printTopUpMasterCard(
                "${cardData['sNo']}",
                cardOwner,
                double.parse(amountController.text),
                double.parse(
                    isUpdateBalance['response']['previousBalance'].toString()),
                double.parse(
                    isUpdateBalance['response']['newBalance'].toString()),
                referenceNumber,
                cashierName);
          }
          Navigator.of(context).pop();
          ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      title: "SUCCESSFULLY RECHARGE",
                      text: "THANK YOU"))
              .then((alertresult) {
            Navigator.of(context).pop();

            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => CundoctorPage()));
          });
        } else {
          Navigator.of(context).pop();
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "INVALID",
                  text: "PLEASE TAP VALID CARD"));
          _startNFCReader();
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (isNfcScanOn) {
        _startNFCReader();
      }
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
                        'TOP-UP MASTERCARD CARD',
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
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits (0-9)
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Prevent line breaks
                                ],
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF00558d)),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Enter Amount',
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Color(0xFF00558d)),
                                        borderRadius:
                                            BorderRadius.circular(10))),
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
                                        if (mounted) {
                                          setState(() {
                                            isNfcScanOn = true;
                                          });
                                        }

                                        _showDialognfcScan(context,
                                            'MASTER CARD', 'master-card.png');

                                        _startNFCReader();
                                      } else {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "ERROR",
                                                text:
                                                    "Please put valid amount"));
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
                                    'TAP MASTER CARD',
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
                    // Navigator.of(context).pop();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClosingMenuPage(
                                cashierData: widget.cashierData)));
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
          ),
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
      if (mounted) {
        setState(() {
          isNfcScanOn = false;
        });
      }
    });
  }
}
