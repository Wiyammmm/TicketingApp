import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenu/finalCashPage.dart';
import 'package:dltb/pages/closingMenu/topupMasterCard.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ClosingMenuPage extends StatefulWidget {
  const ClosingMenuPage({super.key, required this.cashierData});
  final cashierData;
  @override
  State<ClosingMenuPage> createState() => _ClosingMenuPageState();
}

class _ClosingMenuPageState extends State<ClosingMenuPage> {
  final _myBox = Hive.box('myBox');
  timeServices basicservices = timeServices();
  fetchServices fetchservice = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  LoadingModal loadingModal = LoadingModal();
  TestPrinttt printservices = TestPrinttt();
  Map<String, dynamic> coopData = {};

  List<Map<String, dynamic>> torTrip = [];

  bool isNfcScanOn = false;
  @override
  void initState() {
    super.initState();
    coopData = fetchservice.fetchCoopData();

    torTrip = _myBox.get('torTrip');
  }

  @override
  Widget build(BuildContext context) {
    print('cashierData: ${widget.cashierData}');
    final datenow = basicservices.formatDateNow();
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
                        'CLOSING MENU',
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isNfcScanOn = true;
                                            });
                                            _startNFCReader("mastercard");
                                            _checkBalanceDialog(
                                                'mastercard', context);
                                          },
                                          child: closingMenuButton(
                                            title: 'CHECK BALANCE\nMASTER CARD',
                                            image: 'master-card.png',
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
                                            setState(() {
                                              isNfcScanOn = true;
                                            });
                                            _startNFCReader('filipay');
                                            _checkBalanceDialog(
                                                'filipay', context);
                                          },
                                          child: closingMenuButton(
                                            title:
                                                'CHECK BALANCE\nFILIPAY CARD',
                                            image:
                                                'FILIPAY Cards - Regular.png',
                                            isAvailable: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
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
                                                        TopUpMasterCardPage(
                                                            cashierData: widget
                                                                .cashierData)));
                                          },
                                          child: closingMenuButton(
                                            title: 'TOP-UP\n MASTERCARD',
                                            image: 'master-card.png',
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
                                            if (torTrip.isNotEmpty) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FinalCashPage(
                                                            cashierData: widget
                                                                .cashierData,
                                                          )));
                                            } else {
                                              ArtSweetAlert.show(
                                                  context: context,
                                                  artDialogArgs: ArtDialogArgs(
                                                      type: ArtSweetAlertType
                                                          .danger,
                                                      title: "NO TRIP YET",
                                                      text:
                                                          "THERE IS NO TRIP FOUND"));
                                            }
                                          },
                                          child: closingMenuButton(
                                            title: 'FINAL CASH\n(CLOSE TRIP)',
                                            image: 'finalcash.png',
                                            isAvailable: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     SizedBox(
                          //       width: MediaQuery.of(context).size.width * 0.5,
                          //       child: closingMenuButton(
                          //         title: 'VIEW ALL',
                          //         image: 'viewall.png',
                          //         isAvailable: false,
                          //       ),
                          //     ),
                          //     // Container(
                          //     //   height: MediaQuery.of(context).size.height * 0.1,
                          //     //   width: MediaQuery.of(context).size.width * 0.47,
                          //     //   decoration: BoxDecoration(
                          //     //       color: Color(0xff46aef2),
                          //     //       borderRadius: BorderRadius.circular(10),
                          //     //       border: Border.all(
                          //     //           width: 4, color: Color(0xffd9d9d9))),
                          //     //   child: Padding(
                          //     //     padding: const EdgeInsets.all(8.0),
                          //     //     child: Row(
                          //     //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //     //       children: [
                          //     //         FittedBox(
                          //     //           fit: BoxFit.scaleDown,
                          //     //           child: Text(
                          //     //             'VIEW ALL',
                          //     //             textAlign: TextAlign.center,
                          //     //             style:
                          //     //                 TextStyle(fontWeight: FontWeight.bold),
                          //     //           ),
                          //     //         ),
                          //     //         Image.asset(
                          //     //           'assets/viewall.png',
                          //     //           width:
                          //     //               MediaQuery.of(context).size.width * 0.14,
                          //     //         )
                          //     //       ],
                          //     //     ),
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => LoginPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: AppColors
                                    .primaryColor, // Background color of the button
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
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  void _checkBalanceDialog(String cardType, context) {
    String cardImg = '';
    if (cardType == 'filipay') {
      cardImg = 'FILIPAY Cards - Regular.png';
    }
    if (cardType == 'mastercard') {
      cardImg = 'master-card.png';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                  color: Color(0xFF00558d),
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
                                          color: Color(0xff00558d),
                                          borderRadius:
                                              BorderRadius.circular(100)),
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
                    ]),
              ),
            ),
          );
        }).then((value) {
      setState(() {
        isNfcScanOn = false;
      });
    });
  }

  void _startNFCReader(String typeCard) async {
    if (!isNfcScanOn) {
      return;
    }
    List<Map<String, dynamic>> cardList = [];
    if (typeCard == 'filipay') {
      cardList = fetchservice.fetchFilipayCardList();
      cardList = cardList
          .where((station) =>
              station['cardType'] == 'regular' ||
              station['cardType'] == 'discounted')
          .toList();
    } else if (typeCard == 'mastercard') {
      cardList = fetchservice.fetchMasterCardList();
      cardList =
          cardList.where((station) => station['cardType'] == typeCard).toList();
    } else {
      return;
    }
    final result = await backend.startNFCReader();
    if (result != null) {
      loadingModal.showProcessing(context);
      bool isCardIDExisting = cardList.any((card) => card['cardID'] == result);
      if (isCardIDExisting) {
        print('cardList: $cardList');
        print('Card ID $result exists in the list.');
        List<Map<String, dynamic>> cardData =
            cardList.where((card) => card['cardID'] == result).toList();
        print('cardData:$cardData');
        Map<String, dynamic> responseBalance = await fetchservice.fetchBalance(
            '${cardData[0]['cardID']}',
            '${cardData[0]['cardType']}',
            '${coopData['_id']}');

        if (responseBalance.containsKey('error')) {
          print('responseBalance: $responseBalance');
          Navigator.of(context).pop();
        } else {
          if (responseBalance['messages'][0]['code'] == 0) {
            print('responseBalance: $responseBalance');
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            bool printCheckingBalance =
                await printservices.printCheckingBalance(
                    "${cardData[0]['sNo']}",
                    double.parse(
                        responseBalance['response']['balance'].toString()));
            if (!printCheckingBalance) {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "ERROR",
                      text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
              return;
            }
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                          color: Color(0xFF00558d),
                          border: Border.all(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'CHECKING BALANCE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('CARD ID:'),
                                        Text('$result')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Remaining Balance:'),
                                        Text(
                                            '₱${double.parse(responseBalance['response']['balance'].toString()).toStringAsFixed(2)}')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => LoginPage()));
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
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });

            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //         'REMAINING BALANCE: ${responseBalance['response']['balance']}'),
            //     duration: Duration(seconds: 5), // Adjust the duration as needed
            //     behavior: SnackBarBehavior.floating,
            //   ),
            // );
          } else {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            if (responseBalance.containsKey('error')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('NO INTERNET CONNECTION'),
                  duration:
                      Duration(seconds: 5), // Adjust the duration as needed
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('INVALID CARD'),
                  duration:
                      Duration(seconds: 5), // Adjust the duration as needed
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('INVALID CARD'),
            duration: Duration(seconds: 5), // Adjust the duration as needed
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    //  else {

    //   Navigator.of(context).pop();
    //   Navigator.of(context).pop();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('INVALID CARD'),
    //       duration: Duration(seconds: 5), // Adjust the duration as needed
    //       behavior: SnackBarBehavior.floating,
    //     ),
    //   );
    // }
  }
}

class closingMenuButton extends StatelessWidget {
  const closingMenuButton(
      {super.key,
      required this.image,
      required this.title,
      required this.isAvailable});
  final String image;
  final String title;
  final bool isAvailable;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 4, color: Color(0xffd9d9d9))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        '$title',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor),
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/$image',
                  width: MediaQuery.of(context).size.width * 0.10,
                )
              ],
            ),
          ),
        ),
        if (!isAvailable)
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: const Color.fromARGB(90, 0, 0, 0)),
            child: Center(
              child: Text(
                'NOT AVAILABLE',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }
}
