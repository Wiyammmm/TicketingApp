import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketStopListPage extends StatefulWidget {
  const TicketStopListPage({super.key});

  @override
  State<TicketStopListPage> createState() => _TicketStopListPageState();
}

class _TicketStopListPageState extends State<TicketStopListPage> {
  fetchServices fetchService = fetchServices();
  List<Map<String, dynamic>> ticketList = [];
  Map<String, dynamic> coopData = {};
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  List<Map<String, dynamic>> ticketStops = [];

  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    ticketList = fetchService.fetchStopsTicket();

    // ticketStops = fetchService.fetchTicketStopList();

    final baggageSumMap = <String, int>{};
    final occurrenceCountMap = <String, int>{};
    // Filter data and sum baggage
    for (final item in ticketList) {
      final toPlace = item['to_place'] as String;
      final baggage = item['baggage'] as int;
      final fare = int.parse(item['fare'].toString()) as int;

      int baggagePlus = baggage > 0 ? 1 : 0;
      int passengerPlus = fare > 0 ? 1 : 0;

      baggageSumMap[toPlace] = (baggageSumMap[toPlace] ?? 0) + baggagePlus;
      occurrenceCountMap[toPlace] =
          (occurrenceCountMap[toPlace] ?? 0) + passengerPlus;
    }

    ticketStops = baggageSumMap.entries.map((entry) {
      final toPlace = entry.key;
      final baggageCount = entry.value;
      final passengerCount = occurrenceCountMap[toPlace] ?? 0;
      return {
        'location': toPlace,
        'baggageCount': baggageCount,
        'passengerCount': passengerCount
      };
    }).toList();

    // Output the filtered data with summed baggage

    // Output the filtered data
    print('Filtered Data with Summed Baggage: $ticketStops');
  }

  @override
  Widget build(BuildContext context) {
    print(ticketStops);
    final formattedDate = formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        children: [
          appbar(),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Color(0xFF00558d),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                      child: Text(
                        'TICKET STOPS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  if (ticketStops.isEmpty)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text(
                          'No Data',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (ticketStops.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: ticketStops.length,
                        itemBuilder: (context, index) {
                          final ticket = ticketStops[index];
                          bool lightbg = false;
                          if (index % 2 == 1) {
                            lightbg = true;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: lightbg
                                    ? Color.fromARGB(202, 137, 192, 238)
                                    : Color(0xffd9d9d9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    if (!fetchService.getIsNumeric())
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Location: ',
                                            style: TextStyle(
                                                color: lightbg
                                                    ? Colors.white
                                                    : Color(0xff58595b),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${ticket['location']}',
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
                                          'Pass: ',
                                          style: TextStyle(
                                              color: lightbg
                                                  ? Colors.white
                                                  : Color(0xff58595b),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('${ticket['passengerCount']}',
                                            style: TextStyle(
                                              color: lightbg
                                                  ? Colors.white
                                                  : Color(0xff58595b),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Baggage: ',
                                          style: TextStyle(
                                              color: lightbg
                                                  ? Colors.white
                                                  : Color(0xff58595b),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            '${ticket['baggageCount'].toInt()}',
                                            style: TextStyle(
                                              color: lightbg
                                                  ? Colors.white
                                                  : Color(0xff58595b),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(
                    height: 10,
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
                        primary:
                            Color(0xFF00adee), // Background color of the button
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
      ))),
    );
  }
}
