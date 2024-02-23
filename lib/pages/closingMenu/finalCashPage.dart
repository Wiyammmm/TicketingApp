import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/container.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/closingMenu/editExpensesPage.dart';
import 'package:dltb/pages/closingMenu/endofDayPage.dart';
import 'package:dltb/pages/closingMenuPage.dart';
import 'package:dltb/pages/syncingMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FinalCashPage extends StatefulWidget {
  const FinalCashPage({super.key, required this.cashierData});
  final cashierData;
  @override
  State<FinalCashPage> createState() => _FinalCashPageState();
}

class _FinalCashPageState extends State<FinalCashPage> {
  final _myBox = Hive.box('myBox');
  LoadingModal loadingmodal = LoadingModal();
  DeviceInfoService deviceInfoService = DeviceInfoService();
  GeneratorServices generatorService = GeneratorServices();
  httprequestService httpRequestServices = httprequestService();
  timeServices basicservices = timeServices();
  fetchServices fetchService = fetchServices();
  TestPrinttt printService = TestPrinttt();
  HiveService hiveService = HiveService();
  final TextEditingController textEditingController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController finalRemittanceController = TextEditingController();
  TextEditingController shortController = TextEditingController(text: '0');
  // waybill
  TextEditingController waybillTicketRevenueController =
      TextEditingController(text: '0');
  TextEditingController waybillTicketCountController =
      TextEditingController(text: '0');
  // end waybill

  // puncher passenger
  TextEditingController puncherPassengerTicketRevenueController =
      TextEditingController(text: '0');
  TextEditingController puncherPassengerTicketCountController =
      TextEditingController(text: '0');
  // end puncher passenger

  // puncher baggage
  TextEditingController puncherBaggageTicketRevenueController =
      TextEditingController(text: '0');
  TextEditingController puncherBaggageTicketCountController =
      TextEditingController(text: '0');
  // end puncher baggage

  // charter
  TextEditingController charterTicketRevenueController =
      TextEditingController(text: '0');
  TextEditingController charterTicketCountController =
      TextEditingController(text: '0');
  // end charter
  List<dynamic> terminalList = [];
  List<Map<String, dynamic>> torTrip = [];
  String? selectedTerminal;
  bool isCoding = false;
  Map<String, dynamic> coopData = {};
  Map<dynamic, dynamic> sessionBox = {};
  List<Map<String, dynamic>> expenses = [];
  double cashRecieved = 0;
  double copyCashReceived = 0;
  double netCollections = 0;
  double totalCashRemitted = 0;
  double finalRemittance = 0;
  double overageShortage = 0;
  double totalExpenses = 0;
  bool isDltb = false;
  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    terminalList = fetchService.fetchTerminalList();
    terminalList = terminalList.toSet().toList();
    print('terminalList:  $terminalList');
    cashRecieved = hiveService.getCashReceived();
    copyCashReceived = hiveService.getCashReceived();
    remarksController.text = fetchService.getRemarks();
    torTrip = _myBox.get('torTrip');
    sessionBox = _myBox.get('SESSION');
    expenses = _myBox.get('expenses');
    print('terminalList: $terminalList');
    totalExpenses = expenses
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();
    cashRecieved -= totalExpenses;
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final datenow = basicservices.formatDateNow();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
                        'FINAL CASH (CLOSE TRIP)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                              color: Color(0xfff4f7f9),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                color: AppColors.primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'REMARKS',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: remarksController,
                                textAlign: TextAlign.center,
                                enabled: false,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Input Remarks',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400])),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DLTBContainer(
                            isTop: true,
                            isBottom: false,
                            label: "cash received",
                            value:
                                '${isDltb ? cashRecieved.round() : cashRecieved.toStringAsFixed(2)}'),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.primaryColor), // Set border
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Remittance',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '* ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                  Text(
                                                    'FINAL REMITTANCE',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      finalRemittanceController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      try {
                                                        shortController
                                                            .text = (double.parse(
                                                                    finalRemittanceController
                                                                        .text) -
                                                                cashRecieved)
                                                            .toString();
                                                      } catch (e) {
                                                        shortController.text =
                                                            "0";
                                                      }
                                                    });
                                                  },
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: DLTBContainer(
                                    isTop: false,
                                    isBottom: true,
                                    label: "short/over",
                                    value: "${shortController.text}"),
                              )
                              // Container(
                              //   decoration: BoxDecoration(
                              //       color: AppColors.primaryColor,
                              //       border: Border.all(
                              //           width: 2, color: Colors.white),
                              //       borderRadius: BorderRadius.circular(10)),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceAround,
                              //       children: [
                              //         Expanded(
                              //           child: Text(
                              //             'SHORT/OVER',
                              //             style: TextStyle(
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //         ),
                              //         Container(
                              //           width:
                              //               MediaQuery.of(context).size.width *
                              //                   0.3,
                              //           color: Color(0xffd9d9d9),
                              //           child: Padding(
                              //               padding: const EdgeInsets.all(8.0),
                              //               child:
                              //                   //  Text(
                              //                   //   '0.00',
                              //                   //   textAlign: TextAlign.center,
                              //                   //   style: TextStyle(fontWeight: FontWeight.bold),
                              //                   // ),
                              //                   SizedBox(
                              //                 height: 20,
                              //                 child: TextFormField(
                              //                   controller: shortController,
                              //                   keyboardType:
                              //                       TextInputType.number,
                              //                   enabled: false,
                              //                   textAlign: TextAlign.center,
                              //                   style: TextStyle(
                              //                       color: Colors.black),
                              //                   decoration: InputDecoration(
                              //                       contentPadding:
                              //                           EdgeInsets.only(
                              //                               bottom: 10),
                              //                       border: InputBorder.none,
                              //                       hintText: '****',
                              //                       hintStyle: TextStyle(
                              //                           color: Colors.black)),
                              //                 ),
                              //               )),
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.primaryColor), // Set border
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Text(
                              'EXPENSES',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              //expenses list
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: torTrip
                                            .length, // Number of items in the list
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          double totalExpenses = 0;
                                          totalExpenses = expenses
                                              .where((item) =>
                                                  item['control_no'] ==
                                                  "${torTrip[index]['control_no']}") // Add your condition here
                                              .map((item) => (item['amount'] ??
                                                  0.0) as num)
                                              .fold(
                                                  0.0,
                                                  (prev, amount) =>
                                                      prev + amount)
                                              .toDouble();
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditExpensesPage(
                                                              cashierData: widget
                                                                  .cashierData,
                                                              control_no:
                                                                  "${torTrip[index]['control_no']}",
                                                              torNo:
                                                                  "${torTrip[index]['tor_no']}")));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.primaryColor,
                                                  border: Border.all(
                                                      width: 2,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      'Trip ${index + 1}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'VIEW',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Total: $totalExpenses',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //
                              // for (int i = 0; i < torTrip.length; i++)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        AppColors.primaryColor), // Set border
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'WayBill',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Ticket Revenue',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20))),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    //  Text(
                                                    //   '0.00',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(fontWeight: FontWeight.bold),
                                                    // ),
                                                    SizedBox(
                                                  height: 20,
                                                  child: TextFormField(
                                                    controller:
                                                        waybillTicketRevenueController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '****',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Ticket Count',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(20))),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    //  Text(
                                                    //   '0.00',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(fontWeight: FontWeight.bold),
                                                    // ),
                                                    SizedBox(
                                                  height: 20,
                                                  child: TextFormField(
                                                    controller:
                                                        waybillTicketCountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '****',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              // Set border
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2, color: AppColors.primaryColor),
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Text(
                              'Puncher Passenger',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ticket Revenue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      puncherPassengerTicketRevenueController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                  onChanged: (value) {
                                                    double puncherPassengerRev =
                                                        0;
                                                    double puncherBaggageRev =
                                                        0;
                                                    try {
                                                      puncherPassengerRev =
                                                          double.parse(
                                                              puncherPassengerTicketRevenueController
                                                                  .text);
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    try {
                                                      puncherBaggageRev =
                                                          double.parse(
                                                              puncherBaggageTicketRevenueController
                                                                  .text);
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    setState(() {
                                                      cashRecieved =
                                                          copyCashReceived +
                                                              puncherPassengerRev +
                                                              puncherBaggageRev;
                                                    });
                                                  },
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ticket Count',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      puncherPassengerTicketCountController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  width: 2,
                                  color: AppColors.primaryColor), // Set border
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Text(
                              'Puncher Baggage',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ticket Revenue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      puncherBaggageTicketRevenueController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                  onChanged: (value) {
                                                    double puncherPassengerRev =
                                                        0;
                                                    double puncherBaggageRev =
                                                        0;
                                                    try {
                                                      puncherPassengerRev =
                                                          double.parse(
                                                              puncherPassengerTicketRevenueController
                                                                  .text);
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    try {
                                                      puncherBaggageRev =
                                                          double.parse(
                                                              puncherBaggageTicketRevenueController
                                                                  .text);
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    setState(() {
                                                      cashRecieved =
                                                          copyCashReceived +
                                                              puncherPassengerRev +
                                                              puncherBaggageRev;
                                                    });
                                                  },
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      border: Border.all(
                                          width: 2, color: Colors.white),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ticket Count',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  //  Text(
                                                  //   '0.00',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                                  // ),
                                                  SizedBox(
                                                height: 20,
                                                child: TextFormField(
                                                  controller:
                                                      puncherBaggageTicketCountController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      border: InputBorder.none,
                                                      hintText: '****',
                                                      hintStyle: TextStyle(
                                                          color: Colors
                                                              .grey[600])),
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (coopData['coopType'] == "Bus")
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        AppColors.primaryColor), // Set border
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              title: Text(
                                'Charter',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: AppColors.primaryColor,
                              collapsedIconColor: AppColors.primaryColor,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Ticket Revenue',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20))),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    //  Text(
                                                    //   '0.00',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(fontWeight: FontWeight.bold),
                                                    // ),
                                                    SizedBox(
                                                  height: 20,
                                                  child: TextFormField(
                                                    controller:
                                                        charterTicketRevenueController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '****',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Ticket Count',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(20))),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    //  Text(
                                                    //   '0.00',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(fontWeight: FontWeight.bold),
                                                    // ),
                                                    SizedBox(
                                                  height: 20,
                                                  child: TextFormField(
                                                    controller:
                                                        charterTicketCountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '****',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.secondaryColor,
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'CODING',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isCoding = false;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                        color: isCoding
                                            ? Color(0xffd9d9d9)
                                            : AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'NO',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: isCoding
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isCoding = true;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                        color: isCoding
                                            ? AppColors.primaryColor
                                            : Color(0xffd9d9d9),
                                        border: Border.all(
                                            width: 2,
                                            color: AppColors.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'YES',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: isCoding
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ClosingMenuPage(
                                                cashierData: widget.cashierData,
                                              )));
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors
                                      .primaryColor, // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Border radius
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'CANCEL',
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
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (finalRemittanceController.text.trim() !=
                                          "" &&
                                      shortController.text.trim() != "") {
                                    _showDialog();
                                  } else {
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "INCOMPLETE",
                                            text:
                                                "PLEASE COMPLETE ALL FIELDS"));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors
                                      .primaryColor, // Background color of the button
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
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
              ],
            )),
          ],
        )),
      ),
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Save End of day FINAL CASH?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: AppColors
                                  .primaryColor, // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CANCEL',
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
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                loadingmodal.showLoading(context);
                                final torMain = _myBox.get('torMain');
                                final torTicket = _myBox.get('torTicket');
                                final prePaidPassenger =
                                    _myBox.get('prepaidTicket');
                                final prePaidBaggage =
                                    _myBox.get('prepaidBaggage');
                                final expenses = _myBox.get('expenses');
                                print('tortriptest.length: ${torTrip.length}');
                                bool isProceed = false;

                                double totalDiesel = 0;
                                double totalOthers = 0;
                                double totalServices = 0;
                                double totalRepair = 0;
                                double totalToll = 0;
                                double totalParking = 0;
                                int flag = 0;

                                totalDiesel = expenses
                                    .where((item) =>
                                        item['particular'] == "DIESEL")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                totalToll = expenses
                                    .where(
                                        (item) => item['particular'] == "TOLL")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                totalParking = expenses
                                    .where((item) =>
                                        item['particular'] == "PARKING")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();
                                totalOthers = expenses
                                    .where((item) =>
                                        item['particular'] == "OTHERS")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                totalServices = expenses
                                    .where((item) =>
                                        item['particular'] == "SERVICES")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                totalRepair = expenses
                                    .where((item) =>
                                        item['particular'] == "REPAIR")
                                    .map((item) =>
                                        (item['amount'] ?? 0.0) as num)
                                    .fold(0.0, (prev, amount) => prev + amount)
                                    .toDouble();

                                String uuid = generatorService.generateUuid();
                                String deviceid = await deviceInfoService
                                    .getDeviceSerialNumber();
                                String controlNo =
                                    await generatorService.generateControlNo();

                                List<dynamic> listTorNo = torTrip
                                    .map((item) => item['tor_no']
                                        as String) // Extract tor_no values
                                    .toSet() // Convert to a set to eliminate duplicates
                                    .toList();
                                print('finalcashpage listTorNo: $listTorNo');
                                Map<String, dynamic> aggregatedData = {};

                                for (var item in torTrip) {
                                  print('item tortriptest: ${torTrip.length}');
                                  String torNo = item['tor_no'] as String;
                                  String control_no = "${item['control_no']}";
                                  double prePaidPassengerAmount =
                                      prePaidPassenger
                                          .where((entry) =>
                                              entry['control_no'] == control_no)
                                          .fold(
                                            0.0,
                                            (sum, entry) => sum +
                                                (entry['totalAmount'] ??
                                                    0.0) as double,
                                          );
                                  double prePaidBaggageAmount = prePaidBaggage
                                      .where((entry) =>
                                          entry['control_no'] == control_no)
                                      .fold(
                                        0.0,
                                        (sum, entry) =>
                                            sum + (entry['totalAmount'] ?? 0.0)
                                                as double,
                                      );
                                  double ticket_revenue_reserved =
                                      prePaidPassengerAmount +
                                          prePaidBaggageAmount;

                                  int ticket_count_reserved =
                                      prePaidPassenger.length +
                                          prePaidBaggage.length;
                                  double ticket_revenue_card = torTicket
                                      .where((fare) =>
                                          fare['control_no'] == control_no &&
                                          fare['cardType'] != "mastercard" &&
                                          fare['cardType'] != "cash")
                                      .map<num>((fare) =>
                                          (fare['fare'] as num).toDouble() +
                                          (fare['baggage'] as num).toDouble() +
                                          (fare['additionalFare'] as num)
                                              .toInt())
                                      .fold(
                                          0.0, (prev, amount) => prev + amount);

                                  int ticket_count_card = torTicket
                                      .where((item) =>
                                          item['cardType'] != 'mastercard' &&
                                          item['control_no'] == control_no)
                                      .length;
                                  double cashReceived =
                                      fetchService.grandTotalCashReceived() -
                                          totalExpenses;
                                  // Initialize data for tor_no if not present in the map

                                  aggregatedData.putIfAbsent(torNo, () {
                                    int indexToUpdate = torMain.indexWhere(
                                        (map) => map['tor_no'] == torNo);
                                    print(
                                        'item tortriptest putIfAbsent: ${torTrip.length}');
                                    return {
                                      "coopId": "${coopData['_id']}",
                                      "UUID":
                                          "${torMain[indexToUpdate]['UUID']}",
                                      "device_id": item['device_id'],
                                      "control_no": item['control_no'],
                                      "tor_no": torNo,
                                      "date_of_trip": item['date_of_trip'],
                                      "bound":
                                          "${torMain[indexToUpdate]['bound']}",
                                      "bus_no":
                                          "${torMain[indexToUpdate]['bus_no']}",
                                      "route":
                                          "${torMain[indexToUpdate]['route']}",
                                      "route_code":
                                          "${torMain[indexToUpdate]['route_code']}",
                                      "emp_no_driver_1":
                                          "${torMain[indexToUpdate]['emp_no_driver_1']}",
                                      "emp_no_driver_2": "",
                                      "emp_no_conductor":
                                          "${torMain[indexToUpdate]['emp_no_conductor']}",
                                      "emp_name_driver_1":
                                          "${torMain[indexToUpdate]['emp_name_driver_1']}",
                                      "emp_name_driver_2": "",
                                      "emp_name_conductor":
                                          "${torMain[indexToUpdate]['emp_name_conductor']}",
                                      "eskirol_id_driver": "",
                                      "eskirol_id_conductor": "",
                                      "eskirol_name_driver": "",
                                      "eskirol_name_conductor": "",
                                      "no_of_trips": torMain[indexToUpdate]
                                          ['no_of_trips'],
                                      "toll_fees": torMain[indexToUpdate]
                                          ['toll_fees'],
                                      "parking_fee": torMain[indexToUpdate]
                                          ['parking_fee'],
                                      "diesel": torMain[indexToUpdate]
                                          ['diesel'],
                                      "others": torMain[indexToUpdate]
                                          ['others'],
                                      "services": torMain[indexToUpdate]
                                          ['services'],
                                      "repair_maintenance":
                                          torMain[indexToUpdate]
                                              ['repair_maintenance'],
                                      "total_expenses": totalExpenses,
                                      "ticket_revenue_atm":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm'],
                                      "ticket_count_atm": torMain[indexToUpdate]
                                          ['ticket_count_atm'],
                                      "ticket_revenue_atm_passenger":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm_passenger'],
                                      "ticket_revenue_atm_baggage":
                                          torMain[indexToUpdate]
                                              ['ticket_revenue_atm_baggage'],
                                      "ticket_count_atm_passenger":
                                          torMain[indexToUpdate]
                                              ['ticket_count_atm_passenger'],
                                      "ticket_count_atm_baggage":
                                          torMain[indexToUpdate]
                                              ['ticket_count_atm_baggage'],
                                      "ticket_revenue_reserved":
                                          ticket_revenue_reserved,
                                      "ticket_count_reserved":
                                          ticket_count_reserved,
                                      "ticket_revenue_card":
                                          ticket_revenue_card,
                                      "ticket_count_card": ticket_count_card,
                                      "passenger_revenue": 0.0,
                                      "baggage_revenue": 0.0,
                                      "gross_revenue": 0.0,
                                      "passenger_count": torMain[indexToUpdate]
                                          ['passenger_count'],
                                      "baggage_count": 0,
                                      "net_collections": torMain[indexToUpdate]
                                          ['net_collections'],
                                      "total_cash_remitted": 0,
                                      "final_remittance": 0,
                                      "final_cash_remitted": double.parse(
                                          finalRemittanceController.text),
                                      "overage_shortage": 0,
                                      "tellers_id":
                                          "${widget.cashierData['empNo']}",
                                      "tellers_name":
                                          "${widget.cashierData['idName']}",
                                      "coding": isCoding ? "YES" : "NO",
                                      "cashReceived": torMain[indexToUpdate]
                                              ['cashReceived'] +
                                          double.parse(
                                              puncherPassengerTicketRevenueController
                                                  .text) +
                                          double.parse(
                                              puncherBaggageTicketRevenueController
                                                  .text),
                                      "cardSales": torMain[indexToUpdate]
                                          ['cardSales'],
                                      "remarks": "${remarksController.text}",
                                    };
                                  });
                                }
                                print(
                                    'item tortriptest after putIfAbsent: ${torTrip.length}');
                                for (int x = 0;
                                    x < aggregatedData.length;
                                    x++) {
                                  print(
                                      'aggregatedData $x: ${aggregatedData[x]}');
                                }
                                // for (var item in torTicket) {
                                //   String torNo = item['tor_no'] as String;

                                //   // Update aggregated data for the current tor_no
                                //   if (aggregatedData.containsKey(torNo)) {
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm'] +=
                                //         (item['subtotal'] ?? 0.0) +
                                //             (item['additionalFare'] ?? 0.0);
                                //     aggregatedData[torNo]['ticket_count_atm'] +=
                                //         1;
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm_passenger'] +=
                                //         (item['fare'] ?? 0.0) +
                                //             (item['additionalFare'] ?? 0.0);
                                //     aggregatedData[torNo]
                                //             ['ticket_revenue_atm_baggage'] +=
                                //         item['baggage'] ?? 0.0;
                                //     aggregatedData[torNo]
                                //             ['ticket_count_atm_passenger'] +=
                                //         (item['fare'] > 0) ? 1 : 0;
                                //     aggregatedData[torNo]
                                //             ['ticket_count_atm_baggage'] +=
                                //         (item['baggage'] > 0) ? 1 : 0;
                                //   }
                                // }

                                print(
                                    'finalcashpage aggregatedData: $aggregatedData');

                                for (int i = 0; i < listTorNo.length; i++) {
                                  print(
                                      'finalcashpage tor_no: ${listTorNo[i]}');

                                  // passenger revenue
                                  aggregatedData[listTorNo[i]]
                                      ['passenger_revenue'] = aggregatedData[
                                              listTorNo[i]]
                                          ['ticket_revenue_atm_passenger'] +
                                      double.parse(
                                          puncherPassengerTicketRevenueController
                                              .text) +
                                      double.parse(
                                          charterTicketRevenueController.text);
                                  // baggage revenue

                                  aggregatedData[listTorNo[i]]
                                      ['baggage_revenue'] = aggregatedData[
                                              listTorNo[i]]
                                          ['ticket_revenue_atm_baggage'] +
                                      double.parse(
                                          puncherBaggageTicketRevenueController
                                              .text) +
                                      double.parse(
                                          waybillTicketRevenueController.text);
                                  // gross revenue
                                  aggregatedData[listTorNo[i]]
                                          ['gross_revenue'] =
                                      aggregatedData[listTorNo[i]]
                                              ['passenger_revenue'] +
                                          aggregatedData[listTorNo[i]]
                                              ['baggage_revenue'];

                                  // net collections
                                  aggregatedData[listTorNo[i]]
                                      ['net_collections'] = aggregatedData[
                                              listTorNo[i]]
                                          ['ticket_revenue_atm_passenger'] +
                                      aggregatedData[listTorNo[i]]
                                          ['ticket_revenue_atm_baggage'] +
                                      (double.parse(
                                              puncherPassengerTicketRevenueController
                                                  .text) +
                                          double.parse(
                                              puncherBaggageTicketRevenueController
                                                  .text)) -
                                      totalExpenses;

                                  //  passenger count

                                  aggregatedData[listTorNo[i]]
                                      ['passenger_count'] += double.parse(
                                          puncherPassengerTicketCountController
                                              .text) +
                                      double.parse(
                                          charterTicketCountController.text) +
                                      double.parse(
                                          puncherPassengerTicketCountController
                                              .text);

                                  //  baggage count

                                  aggregatedData[listTorNo[i]]
                                      ['baggage_count'] = aggregatedData[
                                              listTorNo[i]]
                                          ['ticket_count_atm_baggage'] +
                                      double.parse(
                                          puncherBaggageTicketCountController
                                              .text) +
                                      double.parse(
                                          waybillTicketCountController.text);

                                  // final remittance
                                  aggregatedData[listTorNo[i]]
                                          ['final_remittance'] =
                                      aggregatedData[listTorNo[i]]
                                              ['net_collections'] -
                                          double.parse(
                                              finalRemittanceController.text);
                                  aggregatedData[listTorNo[i]]
                                          ['total_cash_remitted'] =
                                      double.parse(
                                          finalRemittanceController.text);

                                  // overage shortage
                                  aggregatedData[listTorNo[i]]
                                      ['overage_shortage'] = double.parse(
                                          finalRemittanceController.text) -
                                      aggregatedData[listTorNo[i]]
                                          ['net_collections'];

                                  Map<String, dynamic> isUpdateTorMain =
                                      await httpRequestServices.updateTorMain(
                                          aggregatedData[listTorNo[i]]);

                                  String uuidRem =
                                      generatorService.generateUuid();
                                  String datenow =
                                      await basicservices.departedTime();
                                  Map<String, dynamic> isAddTorRemittance =
                                      await httpRequestServices
                                          .addTorRemittance({
                                    "fieldData": {
                                      "coopId": "${coopData['_id']}",
                                      "UUID": "$uuidRem",
                                      "device_id":
                                          "${aggregatedData[listTorNo[i]]['device_id']}",
                                      "control_no":
                                          "${aggregatedData[listTorNo[i]]['control_no']}",
                                      "tor_no": "${listTorNo[i]}",
                                      "date_of_trip":
                                          "${aggregatedData[listTorNo[i]]['date_of_trip']}",
                                      "bus_no":
                                          "${aggregatedData[listTorNo[i]]['bus_no']}",
                                      "route":
                                          "${aggregatedData[listTorNo[i]]['route']}",
                                      "route_code":
                                          "${aggregatedData[listTorNo[i]]['route_code']}",
                                      "bound":
                                          "${aggregatedData[listTorNo[i]]['bound']}",
                                      "trip_no": aggregatedData[listTorNo[i]]
                                          ['no_of_trips'],
                                      "remittance_date": "$datenow",
                                      "remittance_time": "$datenow",
                                      "remittance_place": "$selectedTerminal",
                                      "remittance_amount": double.parse(
                                          finalRemittanceController.text),
                                      "shortOver":
                                          double.parse(shortController.text),
                                      "remittance_type": "FINAL",
                                      "ctr_no": "",
                                      "waybill_ticket_no": "",
                                      "cashier_emp_no":
                                          "${widget.cashierData['empNo']}",
                                      "cashier_emp_name":
                                          "${widget.cashierData['idName']}",
                                      "lat": "14.069637",
                                      "long": "120.632632",
                                      "timestamp": "$datenow",
                                    }
                                  });

                                  if (isUpdateTorMain['messages']['code']
                                          .toString() !=
                                      '0') {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "SLOW INTERNET CONNECTION, PLEASE TRY AGAIN"));
                                  }

                                  if (isAddTorRemittance['messages'][0]['code']
                                          .toString() !=
                                      '0') {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        barrierDismissible: false,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "SLOW INTERNET CONNECTION, PLEASE TRY AGAIN"));
                                  }
                                  flag++;
                                }

                                // Map<String, dynamic> item = {
                                //   "coopId": "${coopData['_id']}",
                                //   "UUID": "$uuid",
                                //   "device_id": "$deviceid",
                                //   "control_no": "$controlNo",
                                //   "tor_no": "${outputList[i][0]['tor_no']}",
                                //   "date_of_trip":
                                //       "${outputList[i][0]['date_of_trip']}",
                                //   "bus_no": " ${outputList[i][0]['bus_no']}",
                                //   "route": "${outputList[i][0]['route']}",
                                //   "route_code":
                                //       "${outputList[i][0]['route_code']}",
                                //   "emp_no_driver_1":
                                //       "${outputList[i][0]['driver_id']}",
                                //   "emp_no_driver_2": "",
                                //   "emp_no_conductor":
                                //       "${outputList[i][0]['conductor_id']}",
                                //   "emp_name_driver_1":
                                //       "${outputList[i][0]['driver']}",
                                //   "emp_name_driver_2": "",
                                //   "emp_name_conductor":
                                //       "${outputList[i][0]['conductor']}",
                                //   "eskirol_id_driver": "",
                                //   "eskirol_id_conductor": "",
                                //   "eskirol_name_driver": "",
                                //   "eskirol_name_conductor": "",
                                //   "no_of_trips": outputList[i].length,
                                //   "ticket_revenue_atm": grandTotal,
                                //   "ticket_count_atm": totalTickets,
                                //   "ticket_revenue_atm_passenger":
                                //       tickerRevenuePassenger,
                                //   "ticket_revenue_atm_baggage": baggageCount,
                                //   "ticket_count_atm_passenger":
                                //       ticket_count_atm_passenger,
                                //   "ticket_count_atm_baggage":
                                //       ticket_count_atm_baggage,
                                //   "ticket_revenue_punch": 0,
                                //   "ticket_count_punch": 0,
                                //   "ticket_revenue_punch_passenger": 0,
                                //   "ticket_revenue_punch_baggage": 0,
                                //   "ticket_count_punch_passenger": 0,
                                //   "ticket_count_punch_baggage": 0,
                                //   "ticket_revenue_charter": 0,
                                //   "ticket_count_charter": 0,
                                //   "ticket_revenue_waybill": 0,
                                //   "ticket_count_waybill": 0,
                                //   "ticket_amount_cancelled": 0.0,
                                //   "ticket_count_cancelled": 0.0,
                                //   "ticket_amount_passes": "",
                                //   "ticket_count_passes": "",
                                //   "passenger_revenue": 0.0,
                                //   "baggage_revenue": 0.0,
                                //   "gross_revenue": 0.0,
                                //   "passenger_count": 0.0,
                                //   "baggage_count": 0,
                                //   "commission_driver1_passenger": "",
                                //   "auto_commission_driver1_passenger": 0,
                                //   "commission_driver1_baggage": "",
                                //   "auto_commission_driver1_baggage": 0,
                                //   "commission_driver1": 0.0,
                                //   "auto_commission_driver1": 0.0,
                                //   "commission_driver2_passenger": "",
                                //   "auto_commission_driver2_passenger": 0.0,
                                //   "commission_driver2_baggage": "",
                                //   "auto_commission_driver2_baggage": 0.0,
                                //   "commission_driver2": 0.0,
                                //   "auto_commission_driver2": "",
                                //   "commission_conductor_passenger": "",
                                //   "auto_commission_conductor_passenger": 0,
                                //   "commission_conductor_baggage": "",
                                //   "auto_commission_conductor_baggage": 0,
                                //   "commission_conductor": 0.0,
                                //   "auto_commission_conductor": 0,
                                //   "incentive_driver1": 0.0,
                                //   "incentive_driver2": 0.0,
                                //   "incentive_conductor": 0.0,
                                //   "allowance_driver1": 0.0,
                                //   "allowance_driver2": 0.0,
                                //   "allowance_conductor": 0.0,
                                //   "eskirol_commission_driver": 0,
                                //   "eskirol_commission_conductor": 0,
                                //   "eskirol_cash_bond_driver": 0,
                                //   "eskirol_cash_bond_conductor": 0,
                                //   "toll_fees": 0.0,
                                //   "parking_fee": 0.0,
                                //   "diesel": 0.0,
                                //   "diesel_no_of_liters": 0,
                                //   "others": 0.0,
                                //   "services": 0.0,
                                //   "callers_fee": 0.0,
                                //   "employee_benefits": 0.0,
                                //   "repair_maintenance": 0.0,
                                //   "materials": 0.0,
                                //   "representation": 0.0,
                                //   "total_expenses": 0.0,
                                //   "net_collections": 0.0,
                                //   "total_cash_remitted": 0.0,
                                //   "final_remittance": 0.0,
                                //   "final_cash_remitted": 0.0,
                                //   "overage_shortage": 0.0,
                                //   "tellers_id":
                                //       "${widget.cashierData['empNo']}",
                                //   "tellers_name":
                                //       "${widget.cashierData['idName']}",
                                //   "coding": isCoding ? "YES" : "NO",
                                //   "remarks": "${remarksController.text}"
                                // };
                                // Map<String, dynamic> addTorMain =
                                //     await httpRequestServices.addTorMain(item);
                                // if (addTorMain['messages'][0]['code']
                                //         .toString() !=
                                //     "0") {
                                //   print(
                                //       'error: ${addTorMain['messages'][0]['message']}');
                                //   return;
                                // } else {
                                //   print('success ito');
                                // }

                                // }
                                if (flag == listTorNo.length) {
                                  bool isPrintDone = false;
                                  _showDialogPrinting(
                                      'PRINTING PLEASE WAIT...', false);

                                  // if (isTripReport) {
                                  isPrintDone =
                                      await printService.printTripReport(
                                    // '${torTrip[SESSION['currentTripIndex'] - 1]['tor_no']}',
                                    // '$vehicleNo',
                                    // '$conductorName',
                                    // '$driverName',
                                    // '$dispatcherName',
                                    '${widget.cashierData['firstName']} ${widget.cashierData['middleName'] != '' ? widget.cashierData['middleName'][0] : ''}. ${widget.cashierData['lastName']}',
                                    // regularCount,
                                    // totalDiscounted,
                                    // totalBaggage,
                                    // '${torTrip[SESSION['currentTripIndex'] - 1]['route']}',
                                    // torTicket.length,
                                    // totalPassengerAmount,
                                    torTrip,
                                    torTicket,
                                    prePaidPassenger,
                                    prePaidBaggage,
                                    double.parse(
                                        finalRemittanceController.text),
                                    double.parse(shortController.text),
                                    double.parse(
                                        puncherPassengerTicketRevenueController
                                            .text),
                                    double.parse(
                                        puncherPassengerTicketCountController
                                            .text),
                                    double.parse(
                                        puncherBaggageTicketRevenueController
                                            .text),
                                    double.parse(
                                        puncherBaggageTicketCountController
                                            .text),
                                  );
                                  // } else {
                                  //   isPrintDone = printService.printTripSummary();
                                  // }
                                  const duration = Duration(
                                      seconds:
                                          3); // Adjust the duration as needed (3 seconds in this example).
                                  await Future.delayed(duration);
                                  if (isPrintDone) {
                                    // bool isUpdateClosing = true;
                                    bool isUpdateClosing =
                                        await hiveService.updateClosing(true);
                                    if (isUpdateClosing) {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SyncingMenuPage()));
                                    } else {
                                      Navigator.of(context).pop();
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "SOMETHING WENT WRONG",
                                              text: "Please try again"));
                                    }
                                    // _showDialogPrinting(
                                    //     'Are you sure you would like to close\nthe transaction?',
                                    //     true);
                                  }
                                  // Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => EndofDayPage(
                                  //               cashierData: widget.cashierData,
                                  //               finalRemitt: double.parse(
                                  //                   finalRemittanceController
                                  //                       .text),
                                  //               shortOver: double.parse(
                                  //                   shortController.text),
                                  //               puncherTR: double.parse(
                                  //                   puncherPassengerTicketRevenueController
                                  //                       .text),
                                  //               puncherTC: double.parse(
                                  //                   puncherPassengerTicketCountController
                                  //                       .text),
                                  //               puncherBR: double.parse(
                                  //                   puncherBaggageTicketRevenueController
                                  //                       .text),
                                  //               puncherBC: double.parse(
                                  //                   puncherBaggageTicketCountController
                                  //                       .text),
                                  //             )));
                                } else {
                                  print(
                                      'something went wrong in final cashpage');
                                }
                              } catch (e) {
                                print("final remit error: $e");
                                Navigator.of(context).pop();
                                ArtSweetAlert.show(
                                    context: context,
                                    barrierDismissible: false,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.danger,
                                        title: "ERROR",
                                        text: "INVALID INPUT"));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: AppColors
                                  .primaryColor, // Background color of the button
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              shape: RoundedRectangleBorder(
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

  void _showDialogPrinting(String title, bool isDismissible) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.22,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDismissible)
                        Image.asset(
                          'assets/warning.png',
                          width: 40,
                        ),
                      Text(
                        '$title',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isDismissible)
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
                                    'NO',
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
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  bool isUpdateClosing =
                                      await hiveService.updateClosing(true);
                                  if (isUpdateClosing) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SyncingMenuPage()));
                                  } else {
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "SOMETHING WENT WRONG",
                                            text: "Please try again"));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(
                                      0xFF00adee), // Background color of the button
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
                                    'YES',
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
            ),
          );
        });
  }
}
