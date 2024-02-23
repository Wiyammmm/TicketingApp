import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class TopUpListPage extends StatefulWidget {
  const TopUpListPage({super.key});

  @override
  State<TopUpListPage> createState() => _TopUpListPageState();
}

class _TopUpListPageState extends State<TopUpListPage> {
  fetchServices fetchservices = fetchServices();
  final _myBox = Hive.box('myBox');
  int total = 0;
  List<Map<String, dynamic>> topUpList = [];

  @override
  void initState() {
    super.initState();
    topUpList = _myBox.get('topUpList');
    total = topUpList.length;
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
                        'TOP-UP LISTING',
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                  color: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.primaryColor, width: 2)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'TOTAL $total',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (topUpList.isEmpty)
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'NO DATA',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              )),
                        if (topUpList.isNotEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                                itemCount: topUpList.length,
                                itemBuilder: (context, index) {
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'MASTER CARD OWNER: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '${fetchservices.getEmpName(topUpList[index]['response']['mastercard']['empNo'].toString())}',
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
                                                  'REFERENCE NUMBER: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${topUpList[index]['response']['referenceNumber']}',
                                                      style: TextStyle(
                                                        color: lightbg
                                                            ? Colors.white
                                                            : Color(0xff58595b),
                                                      ),
                                                    ),
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
                                                  'AMOUNT: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '₱${topUpList[index]['response']['mastercard']['previousBalance'] - topUpList[index]['response']['mastercard']['newBalance']}',
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'MASTERCARD',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                // Text(
                                                //   '₱${topUpList[index]['response']['mastercard']['previousBalance'] - topUpList[index]['response']['mastercard']['newBalance']}',
                                                //   style: TextStyle(
                                                //     color: lightbg
                                                //         ? Colors.white
                                                //         : Color(0xff58595b),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'PREV BALANCE: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '₱${topUpList[index]['response']['mastercard']['previousBalance']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: !lightbg
                                                        ? Colors.blue[900]
                                                        : Colors.lightBlue,
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
                                                  'NEW BALANCE: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '-₱${topUpList[index]['response']['mastercard']['newBalance']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: !lightbg
                                                        ? Color.fromARGB(
                                                            255, 110, 0, 0)
                                                        : Colors.redAccent,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'FILIPAY CARD',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'PREV BALANCE: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '₱${topUpList[index]['response']['filipayCard']['previousBalance']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: lightbg
                                                        ? Colors.blue[900]
                                                        : Colors.lightBlue,
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
                                                  'NEW BALANCE: ',
                                                  style: TextStyle(
                                                      color: lightbg
                                                          ? Colors.white
                                                          : Color(0xff58595b),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '+₱${topUpList[index]['response']['filipayCard']['newBalance']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: !lightbg
                                                        ? Color.fromARGB(
                                                            255, 0, 110, 4)
                                                        : Colors.lightGreen,
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
                          height: 10,
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
        ),
      ),
    );
  }
}
