import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenu/topupMasterCard.dart';
import 'package:dltb/pages/cundoctorMenu/topupPassengerCard.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/ticketingMenu/topupListPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CundoctorPage extends StatefulWidget {
  const CundoctorPage({super.key});

  @override
  State<CundoctorPage> createState() => _CundoctorPageState();
}

class _CundoctorPageState extends State<CundoctorPage> {
  fetchServices fetchservice = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  LoadingModal loadingModal = LoadingModal();
  TestPrinttt printservices = TestPrinttt();
  Map<String, dynamic> coopData = {};

  bool isNfcScanOn = false;
  @override
  void initState() {
    super.initState();
    coopData = fetchservice.fetchCoopData();
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
                          color: AppColors.primaryColor,
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
                                        Text('Serial Number:'),
                                        Text('${cardData[0]['sNo']}')
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

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => DashboardPage()));
        // logic
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
                          'CONDUCTOR MENU',
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TopUpPassengerCardPage()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.28,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/passenger.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                ),
                                                Align(
                                                  alignment: Alignment(3, 2),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFd9d9d9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Image.asset(
                                                      'assets/top-up.png',
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'TOP-UP\nPASSENGER',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //                 TopUpMasterCardPage()));
                              //   },
                              //   child: Container(
                              //     // height: MediaQuery.of(context).size.height * 0.28,
                              //     // width: MediaQuery.of(context).size.width * 0.4,
                              //     decoration: BoxDecoration(
                              //       color: AppColors.primaryColor,
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 16, vertical: 8),
                              //           child: Container(
                              //             height: 70,
                              //             width: 70,
                              //             decoration: BoxDecoration(
                              //               color: Color(0xFFd9d9d9),
                              //               borderRadius:
                              //                   BorderRadius.circular(100),
                              //             ),
                              //             child: Padding(
                              //               padding: const EdgeInsets.all(16.0),
                              //               child: Stack(
                              //                 children: [
                              //                   Image.asset(
                              //                     'assets/master-card.png',
                              //                     width: MediaQuery.of(context)
                              //                             .size
                              //                             .width *
                              //                         0.2,
                              //                   ),
                              //                   Align(
                              //                     alignment: Alignment(3, 2),
                              //                     child: Container(
                              //                       decoration: BoxDecoration(
                              //                           color: Color(0xFFd9d9d9),
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   10)),
                              //                       child: Image.asset(
                              //                         'assets/top-up.png',
                              //                         width: MediaQuery.of(context)
                              //                                 .size
                              //                                 .width *
                              //                             0.07,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 30,
                              //           child: FittedBox(
                              //             fit: BoxFit.scaleDown,
                              //             child: Text(
                              //               'TOP-UP\nMASTER CARD',
                              //               textAlign: TextAlign.center,
                              //               style: TextStyle(
                              //                   color: Colors.white,
                              //                   fontWeight: FontWeight.bold),
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 5,
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TopUpListPage()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.28,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/passenger.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                ),
                                                Align(
                                                  alignment: Alignment(3, 2),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFd9d9d9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Image.asset(
                                                      'assets/top-up.png',
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'TOP-UP\nLIST',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isNfcScanOn = true;
                                  });
                                  _startNFCReader('filipay');
                                  _checkBalanceDialog('filipay', context);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             TopUpPassengerCardPage()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.28,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/passenger.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                ),
                                                // Align(
                                                //   alignment: Alignment(3, 2),
                                                //   child: Container(
                                                //     decoration: BoxDecoration(
                                                //         color: Color(0xFFd9d9d9),
                                                //         borderRadius:
                                                //             BorderRadius.circular(
                                                //                 10)),
                                                //     child: Image.asset(
                                                //       'assets/top-up.png',
                                                //       width:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .width *
                                                //               0.12,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'CHECK BALANCE\nFILIPAY CARD',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isNfcScanOn = true;
                                  });
                                  _startNFCReader('mastercard');
                                  _checkBalanceDialog('mastercard', context);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             TopUpMasterCardPage()));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.28,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/master-card.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                ),
                                                // Align(
                                                //   alignment: Alignment(3, 2),
                                                //   child: Container(
                                                //     decoration: BoxDecoration(
                                                //         color: Color(0xFFd9d9d9),
                                                //         borderRadius:
                                                //             BorderRadius.circular(
                                                //                 10)),
                                                //     child: Image.asset(
                                                //       'assets/top-up.png',
                                                //       width:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .width *
                                                //               0.12,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'CHECK BALANCE\nMASTER CARD',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
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
                          SizedBox(height: 20),
                          SizedBox(
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
                          SizedBox(height: 20),
                        ],
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
}

class ticketingMenuFirst extends StatelessWidget {
  const ticketingMenuFirst({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => TicketingPage()));
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFd9d9d9),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/tickets.png',
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'TICKETING',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => TicketListingPage()));
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFd9d9d9),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/history.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                            Align(
                              alignment: Alignment(1.5, 1.5),
                              child: Image.asset(
                                'assets/ticket.png',
                                width: MediaQuery.of(context).size.width * 0.14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'TOP-UP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
    );
  }
}
