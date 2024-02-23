import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/ticketingMenu/ticketingPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class TicketListingPage extends StatefulWidget {
  const TicketListingPage({super.key});

  @override
  State<TicketListingPage> createState() => _ticketListingPageState();
}

class _ticketListingPageState extends State<TicketListingPage> {
  final _myBox = Hive.box('myBox');
  Map<String, dynamic> coopData = {};
  fetchServices fetchService = fetchServices();
  httprequestService httprequestservice = httprequestService();
  List<Map<String, dynamic>> ticketList = [];
  List<Map<String, dynamic>> ticketListCopy = [];
  List<bool>? selectedItems;
  TestPrinttt printService = TestPrinttt();
  HiveService hiveService = HiveService();
  NFCReaderBackend backend = NFCReaderBackend();
  LoadingModal loadingModal = LoadingModal();

  TextEditingController additionalFareController = TextEditingController();
  bool isSelect = false;
  String filterTicketNo = '';
  bool isNfcScanOn = false;
  bool isDiscounted = false;
  bool isNoMasterCard = false;
  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    if (coopData['modeOfPayment'] == "cash") {
      isNoMasterCard = true;
    }
    ticketList = fetchService.fetchTorTicket();
    ticketListCopy = List.from(ticketList);
    selectedItems =
        List<bool>.generate(ticketListCopy.length, (index) => false);
    for (int i = 0; i < ticketListCopy.length; i++) {
      print('Item $i: ${ticketListCopy[i]}');
    }
    ticketListCopy = ticketListCopy.reversed.toList();
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  void _startNFCReader(String typeCard, Map<String, dynamic> item) async {
    String? result;
    bool isCardIDExisting = false;
    List<Map<String, dynamic>> cardList = [];
    List<Map<String, dynamic>> cardData = [];
    String modeOfPayment = coopData['modeOfPayment'];
    if (!isNoMasterCard ||
        (typeCard == "regular" || typeCard == "discounted")) {
      if (!isNfcScanOn) {
        return;
      }
      result = await backend.startNFCReader();
      // try {

      if (typeCard == 'discounted' || typeCard == 'regular') {
        cardList = fetchService.fetchFilipayCardList();
        // cardList =
        //     cardList.where((station) => station['cardType'] == typeCard).toList();
      } else if (typeCard == 'mastercard') {
        cardList = fetchService.fetchMasterCardList();
        cardList = cardList
            .where((station) => station['cardType'] == typeCard)
            .toList();
      } else {
        return;
      }
      isCardIDExisting = cardList.any((card) => card['cardID'] == result);
      if (isCardIDExisting) {
        print('cardList: $cardList');
        print('Card ID $result exists in the list.');

        cardData = cardList.where((card) => card['cardID'] == result).toList();
        print('cardData: $cardData');
      }

      print('cardList: $cardList');
      modeOfPayment = "cashless";
    } else {
      modeOfPayment = "cash";
      isCardIDExisting = true;
      result = "";
    }

    if (result != null) {
      if (isCardIDExisting) {
        loadingModal.showProcessing(context);

        // int lastadditionalFare = item['additionalFare'];

        item['additionalFareCardType'] =
            '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}';
        int additionalFare = int.parse(additionalFareController.text.trim());
        // item['additionalFare'] = additionalFare;
        // item['additionalFare'] =
        //     int.parse(item['additionalFare'].toString()) + additionalFare;
        // item['additionalFare'] =
        //     additionalFare + int.parse(item['additionalFare'].toString());

        print('valid go proceed');

        Map<String, dynamic> newitem = {
          "amount": additionalFare,
          "cardType":
              '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}',
          "cardId": "$result",
          "isNegative": false,
          "modeOfPayment": "$modeOfPayment",
          "coopId": "${item['coopId']}",
          "items": item
        };

        print('newitem: $newitem');
        print('newitem sa items: ${newitem['items']}');

        Map<String, dynamic> isUpdateAdditionalFare =
            await httprequestservice.updateAdditionalFare(newitem, false);
        if (isUpdateAdditionalFare['messages']['code'].toString() != '0') {
          Navigator.of(context).pop();
          if (typeCard == 'mastercard') {
            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.danger,
                    title: 'OFFLINE',
                    showCancelBtn: true,
                    confirmButtonText: 'YES',
                    cancelButtonText: 'NO',
                    onConfirm: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      bool isAddedOfflineAdditionalFare =
                          await hiveService.addOfflineAdditionalFare(newitem);

                      bool isprintdone = await printService.printAdditionalFare(
                          item, additionalFare.toDouble());
                      if (isprintdone) {
                        ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.success,
                                    title: 'SUCCESS',
                                    text: "SUCCESFULLY ADDED ADDITIONAL FARE"))
                            .then((value) {
                          Navigator.of(context).pop();
                        });
                      } else {
                        ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.danger,
                                    title: 'ERROR',
                                    text: "SOMETHING WENT WRONG IN PRINTER"))
                            .then((value) {
                          Navigator.of(context).pop();
                        });
                      }
                      print('choose payment method');
                    },
                    onDeny: () {
                      Navigator.of(context).pop();

                      // item['additionalFare'] = lastadditionalFare;
                      print('offlineUpdateAdditionalFare denyyyyy');
                      if (mounted) {
                        setState(() {
                          ticketListCopy = fetchService.fetchTorTicket();
                          ticketListCopy = List.from(ticketListCopy);
                          ticketListCopy = ticketListCopy.reversed.toList();
                        });
                      }
                      return;
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                      // item['additionalFare'] = lastadditionalFare;
                      print('offlineUpdateAdditionalFare denyyyyy');
                    },
                    text:
                        "Do you want to use offline mode?\nNote:It may negative your balance"));
          } else {
            // item['additionalFare'] = lastadditionalFare;
            if (mounted) {
              setState(() {
                ticketListCopy = fetchService.fetchTorTicket();
                ticketListCopy = List.from(ticketListCopy);
                ticketListCopy = ticketListCopy.reversed.toList();
              });
            }
            if (isUpdateAdditionalFare['messages']['code'].toString() ==
                '200') {
              Navigator.of(context).pop();
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: 'OFFLINE',
                      text:
                          "FILIPAY CARD IS NOT AVAILABLE FOR NOW\nNote: Check your internet connection"));
            } else {
              Navigator.of(context).pop();
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: 'ERROR',
                      text:
                          "${isUpdateAdditionalFare['messages']['message']}"));
            }
          }
        }
        if (isUpdateAdditionalFare['messages']['code'].toString() == '0') {
          Navigator.of(context).pop();

          ticketListCopy.forEach((torTicketitem) {
            if (torTicketitem['ticket_no'] == item['ticket_no']) {
              // torTicketitem['additionalFare'] =
              //     int.parse(item['additionalFare'].toString()) + additionalFare;
              torTicketitem['additionalFareCardType'] =
                  '${cardData.isNotEmpty ? cardData[0]['cardType'] ?? "cash" : "cash"}';
            }
          });
          _myBox.put('torTicket', ticketListCopy);

          bool isprintdone = await printService.printAdditionalFare(
              item, additionalFare.toDouble());
          if (isprintdone) {
            ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.success,
                        title: 'SUCCESS',
                        text: "SUCCESFULLY ADDED ADDITIONAL FARE"))
                .then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          } else {
            ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: 'ERROR',
                        text: "SOMETHING WENT WRONG IN PRINTER"))
                .then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        isNfcScanOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
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
                child: Column(children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$formattedDate',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xff46aef2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       isSelect = !isSelect;
                          //     });
                          //   },
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         color: isSelect
                          //             ? Colors.white
                          //             : Color(0xFF00adee),
                          //         border: Border.all(
                          //             width: 2,
                          //             color: isSelect
                          //                 ? Color(0xFF00adee)
                          //                 : Colors.white),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Text(
                          //         'SELECT',
                          //         style: TextStyle(
                          //             color: isSelect
                          //                 ? Color(0xFF00adee)
                          //                 : Colors.white),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Text(
                            'TICKET LISTING',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          // SizedBox(
                          //   width: 20,
                          // )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 10),
                        hintText: 'Search by Ticket No...',
                        hintStyle: TextStyle(color: Color(0xff5f6062)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          filterTicketNo = value;
                        });
                      },
                    ),
                  ),
                  if (ticketListCopy.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text(
                          'NO DATA',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  if (ticketListCopy.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: ticketListCopy.length,
                        itemBuilder: (context, index) {
                          final ticket = ticketListCopy[index];
                          bool lightbg = false;
                          if (index % 2 == 1) {
                            lightbg = true;
                          }
                          if (ticket['ticket_no'].contains(filterTicketNo)) {
                            return GestureDetector(
                              onTap: () {
                                // Toggle the selection when an item is tapped
                                // setState(() {
                                //   selectedItems![index] = !selectedItems![index];
                                // });
                              },
                              onLongPress: () {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.question,
                                        title: "ADDITIONAL FARE",
                                        text:
                                            "Are you certain that you want to add additional Fare?",
                                        denyButtonText: "NO",
                                        confirmButtonText: 'YES',
                                        onConfirm: () {
                                          Navigator.of(context).pop();
                                          _showDialogAdditionaFare(ticket);
                                        },
                                        onDeny: () {
                                          Navigator.of(context).pop();
                                        }));
                              },
                              child: Row(
                                children: [
                                  if (isSelect)
                                    Checkbox(
                                      activeColor: Color(0xFF00adee),
                                      value: selectedItems![index],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedItems![index] = value!;
                                        });
                                      },
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: lightbg
                                              ? Color.fromARGB(
                                                  202, 137, 192, 238)
                                              : Color(0xffd9d9d9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Grand Total: ',
                                                    style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '₱${ticket['subtotal']}',
                                                    style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Fare: ',
                                                    style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '₱${ticket['fare']}',
                                                    style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Baggage: ',
                                                    style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '₱${ticket['baggage']}',
                                                    style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Additional Fare: ',
                                                    style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '₱${ticket['additionalFare']}',
                                                    style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Ticket No: ',
                                                    style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text('${ticket['ticket_no']}',
                                                      style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                      ))
                                                ],
                                              ),
                                              if (!fetchService.getIsNumeric())
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'From: ',
                                                      style: TextStyle(
                                                          color: lightbg
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff58595b),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        '${ticket['from_place']}',
                                                        style: TextStyle(
                                                          color: lightbg
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff58595b),
                                                        ))
                                                  ],
                                                ),
                                              if (!fetchService.getIsNumeric())
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'To: ',
                                                      style: TextStyle(
                                                          color: lightbg
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff58595b),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        '${ticket['to_place']}',
                                                        style: TextStyle(
                                                          color: lightbg
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff58595b),
                                                        ))
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TicketingMenuPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xFF00adee), // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),
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
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // Expanded(
                      //   child: SizedBox(
                      //     height: 60,
                      //     child: ElevatedButton(
                      //       onPressed: () async {
                      //         if (isSelect) {
                      //           if (selectedItems != null &&
                      //               selectedItems!.isNotEmpty) {
                      //             List<Map<String, dynamic>> selectedTickets =
                      //                 [];

                      //             for (int i = 0;
                      //                 i < selectedItems!.length;
                      //                 i++) {
                      //               if (selectedItems![i]) {
                      //                 selectedTickets.add(ticketListCopy[i]);
                      //               }
                      //             }

                      //             // Print the selected items

                      //             if (selectedTickets.isNotEmpty) {
                      //               // print('Selected Items: $selectedTickets');
                      //               bool isPrintdone = await printService
                      //                   .printListticket(selectedTickets);
                      //             } else {
                      //               ArtSweetAlert.show(
                      //                   context: context,
                      //                   artDialogArgs: ArtDialogArgs(
                      //                       type: ArtSweetAlertType.danger,
                      //                       title: "INCOMPLETE",
                      //                       text:
                      //                           "PLEASE SELECT ATLEAST ONE(1)"));
                      //             }
                      //           }
                      //         } else {}
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         primary: Color(
                      //             0xFF00adee), // Background color of the button
                      //         padding: EdgeInsets.symmetric(horizontal: 24.0),
                      //         shape: RoundedRectangleBorder(
                      //           side: BorderSide(width: 1, color: Colors.black),
                      //           borderRadius: BorderRadius.circular(
                      //               10.0), // Border radius
                      //         ),
                      //       ),
                      //       child: FittedBox(
                      //         fit: BoxFit.scaleDown,
                      //         child: Text(
                      //           'PRINT',
                      //           style: TextStyle(
                      //               color: Colors.white,
                      //               fontSize:
                      //                   MediaQuery.of(context).size.width *
                      //                       0.05,
                      //               fontWeight: FontWeight.bold),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ]),
              ),
            )
          ],
        ),
      )),
    );
  }

  void _showDialogAdditionaFare(Map<String, dynamic> item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                  color: Color(0xFF00558d),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ADDITIONAL FARE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ticket No:',
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${item['ticket_no']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Route:',
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${item['route']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!fetchService.getIsNumeric())
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Origin:',
                                style: TextStyle(color: Colors.white),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${item['from_place']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (!fetchService.getIsNumeric())
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Destination:',
                                style: TextStyle(color: Colors.white),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${item['to_place']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // Text('Route:\t$route',
                        //     style: TextStyle(color: Colors.white)),
                        // Text('Origin:\t$origin',
                        //     style: TextStyle(color: Colors.white)),
                        // Text('Destination:\t$destination',
                        //     style: TextStyle(color: Colors.white)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: additionalFareController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 10),
                              hintText: 'Enter Additional Fare',
                              hintStyle: TextStyle(color: Color(0xff5f6062)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),
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
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Navigator.of(context).pop();
                              if (additionalFareController.text
                                  .trim()
                                  .isEmpty) {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.info,
                                        title: 'INVALID',
                                        text: "PLEASE INPUT ADDITIONAL FARE"));
                                print('empty');
                              } else {
                                if (int.parse(
                                        additionalFareController.text.trim()) >
                                    0) {
                                  _showDialogTypeCards(item);
                                } else {
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.info,
                                          title: 'INVALID',
                                          text: "MUST HAVE GREATER THAN 0"));
                                  print('must have value greater than 0');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(
                                  0xFF00adee), // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'SAVE',
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
          );
        });
  }

  void _showDialogTypeCards(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: MediaQuery.of(context).size.height * 0.35,
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
                      'SELECT TYPE OF CARDS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _startNFCReader('mastercard', item);
                                    if (!isNoMasterCard) {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      _showDialognfcScan(context, 'MASTER CARD',
                                          'master-card.png');
                                    }
                                  },
                                  child: typeofCardsWidget(
                                      title: isNoMasterCard
                                          ? 'CASH'
                                          : 'MASTER CARD',
                                      image: isNoMasterCard
                                          ? 'cash.png'
                                          : 'master-card.png'),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              if (!isDiscounted)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      _startNFCReader('regular', item);
                                      _showDialognfcScan(
                                          context,
                                          'FILIPAY CARD',
                                          'FILIPAY Cards - Regular.png');
                                    },
                                    child: typeofCardsWidget(
                                        title: 'FILIPAY CARD',
                                        image: 'FILIPAY Cards - Regular.png'),
                                  ),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              if (isDiscounted)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isNfcScanOn = true;
                                      });
                                      _startNFCReader('discounted', item);
                                      _showDialognfcScan(
                                          context,
                                          'DISCOUNTED CARD',
                                          'FILIPAY Cards - Discounted.png');
                                    },
                                    child: typeofCardsWidget(
                                        title: 'DISCOUNTED CARD',
                                        image:
                                            'FILIPAY Cards - Discounted.png'),
                                  ),
                                ),
                            ],
                          ))),
                ],
              ),
            ),
          ),
        );
      },
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
