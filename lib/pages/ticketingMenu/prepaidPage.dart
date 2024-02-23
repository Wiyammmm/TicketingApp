import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
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
          child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Opacity(opacity: 0.5, child: Image.asset("assets/citybg.png")),
          ),
          SingleChildScrollView(
            child: Column(children: [
              appbar(),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Text(
                  'PREPAID MENU',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Text(
                      'INPUT TICKET NUMBER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: ticketNoController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: '* * * * * * *',
                              hintStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2))),
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
                                      builder: (context) => CheckInPage(
                                          bookingData: bookingData)));
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
                            'SUBMIT',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
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
                  ]),
                ),
              )
            ]),
          ),
        ],
      )),
    );
  }
}
