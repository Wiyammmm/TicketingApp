import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/cundoctorPage.dart';
import 'package:dltb/pages/ticketingMenu/checkinPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrepaidPage extends StatefulWidget {
  const PrepaidPage({super.key});

  @override
  State<PrepaidPage> createState() => _PrepaidPageState();
}

class _PrepaidPageState extends State<PrepaidPage> {
  httprequestService httpRequestServices = httprequestService();
  TextEditingController ticketNoController = TextEditingController();
  LoadingModal loadinglmodal = LoadingModal();
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
        child: Column(children: [
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
                    child: Text(
                      'PREPAID MENU',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Text(
                  'INPUT TICKET NUMBER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: ticketNoController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                    )),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () async {
                      loadinglmodal.showProcessing(context);
                      Map<String, dynamic> bookingData =
                          await httpRequestServices
                              .verifyBooking(ticketNoController.text);
                      if (bookingData['messages'][0]['code'].toString() ==
                          '0') {
                        if (bookingData['response']['data'][0]['fieldData']
                                ['checkIn'] ==
                            "") {
                          Navigator.of(context).pop();
                          print('bookingData: $bookingData');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CheckInPage(bookingData: bookingData)));
                        } else {
                          Navigator.of(context).pop();
                          ArtSweetAlert.show(
                              context: context,
                              artDialogArgs: ArtDialogArgs(
                                  type: ArtSweetAlertType.warning,
                                  title: "ALREADY IN USED",
                                  text: "THIS TICKET IS ALREADY IN USED"));
                        }
                      } else {
                        Navigator.of(context).pop();
                        ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.warning,
                                title: "ERROR",
                                text:
                                    "${bookingData['messages'][0]['message'].toString().toUpperCase()}"));
                      }
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
                        'SUBMIT',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
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
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          )
        ]),
      )),
    );
  }
}
