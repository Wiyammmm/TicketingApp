import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrePaidListingPage extends StatefulWidget {
  const PrePaidListingPage({super.key});

  @override
  State<PrePaidListingPage> createState() => _PrePaidListingPageState();
}

class _PrePaidListingPageState extends State<PrePaidListingPage> {
  fetchServices fetchService = fetchServices();
  List<Map<String, dynamic>> prePaidTicketList = [];
  List<Map<String, dynamic>> prePaidBaggageList = [];
  List<Map<String, dynamic>> selectedList = [];
  bool isPrepaidBaggage = false;
  int total = 0;
  @override
  void initState() {
    super.initState();
    prePaidTicketList = fetchService.fetchPrepaidTicket();
    prePaidBaggageList = fetchService.fetchPrepaidBaggage();
    total = prePaidTicketList.fold(
      0,
      (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
    );
    selectedList = prePaidTicketList;
  }

  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
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
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'PREPAID TICKET LISTING',
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
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPrepaidBaggage = !isPrepaidBaggage;
                                        if (isPrepaidBaggage) {
                                          selectedList = prePaidBaggageList;
                                        } else {
                                          selectedList = prePaidTicketList;
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: isPrepaidBaggage
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                          border: Border.all(
                                              width: 2,
                                              color: isPrepaidBaggage
                                                  ? AppColors.primaryColor
                                                  : Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isPrepaidBaggage
                                              ? 'TICKET'
                                              : 'BAGGAGE',
                                          style: TextStyle(
                                              color: isPrepaidBaggage
                                                  ? AppColors.primaryColor
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isPrepaidBaggage ? 'BAGGAGE' : 'TICKET',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'TOTAL',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '$total',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView.builder(
                            itemCount: selectedList.length,
                            itemBuilder: (context, index) {
                              double totalAmount = double.parse(
                                  selectedList[index]['totalAmount']
                                      .toString());
                              bool lightbg = false;
                              if (index % 2 == 1) {
                                lightbg = true;
                              }
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: lightbg
                                        ? AppColors.primaryColor
                                        : AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'TICKET NO: ',
                                              style: TextStyle(
                                                  color: lightbg
                                                      ? Colors.white
                                                      : Color(0xff58595b),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '₱${selectedList[index]['ticketNo']}',
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'TOTAL AMOUNT: ',
                                              style: TextStyle(
                                                  color: lightbg
                                                      ? Colors.white
                                                      : Color(0xff58595b),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '₱${totalAmount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: lightbg
                                                    ? Colors.white
                                                    : Color(0xff58595b),
                                              ),
                                            )
                                          ],
                                        ),
                                        if (!isPrepaidBaggage)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'TOTAL PASSENGER: ',
                                                style: TextStyle(
                                                    color: lightbg
                                                        ? Colors.white
                                                        : Color(0xff58595b),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${selectedList[index]['totalPassenger']}',
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'FROM: ',
                                              style: TextStyle(
                                                  color: lightbg
                                                      ? Colors.white
                                                      : Color(0xff58595b),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${selectedList[index]['from']}',
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'TO: ',
                                              style: TextStyle(
                                                  color: lightbg
                                                      ? Colors.white
                                                      : Color(0xff58595b),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${selectedList[index]['to']}',
                                              style: TextStyle(
                                                color: lightbg
                                                    ? Colors.white
                                                    : Color(0xff58595b),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TicketingMenuPage()));
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
