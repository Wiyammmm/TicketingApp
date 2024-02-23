import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/settings/printerPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class appbar extends StatelessWidget {
  const appbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _myBox = Hive.box('myBox');
    fetchServices fetchservice = fetchServices();
    timeServices timeservice = timeServices();
    int tickets = fetchservice.fetchAllPassengerCount();
    final torTrip = _myBox.get('torTrip');
    final coopData = _myBox.get('coopData');
    final SESSION = _myBox.get('SESSION');

    String torNo = "";
    try {
      torNo = "${torTrip[SESSION['currentTripIndex']]['tor_no']}";
    } catch (e) {
      print(e);
    }
    String breakString(String input, int maxLength) {
      List<String> words = input.split(' ');

      String firstLine = '';
      String secondLine = '';

      for (int i = 0; i < words.length; i++) {
        String word = words[i];

        if ((firstLine.length + 1 + word.length) <= maxLength) {
          // Add the word to the first line
          firstLine += (firstLine.isEmpty ? '' : ' ') + word;
        } else {
          // If the second line is still empty, add the word to it
          if (secondLine.isEmpty) {
            secondLine += word;
          } else {
            // Truncate the word if it exceeds the maxLength
            int remainingSpace = maxLength - secondLine.length - 1;
            secondLine += ' ' +
                (word.length > remainingSpace
                    ? word.substring(0, remainingSpace) + '..'
                    : word);
            break;
          }
        }
      }

      // Return the concatenated lines
      return '$firstLine\n$secondLine';
    }

    // print('ticket length: ${tickets.length}');
    return GestureDetector(
      onLongPress: () {
        // final myLocation = _myBox.get('myLocation');

        // print('my lat: ${myLocation['latitude']}');
        // print('my long: ${myLocation['longitude']}');
        ArtSweetAlert.show(
            context: context,
            barrierDismissible: false,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.question,
                showCancelBtn: true,
                confirmButtonText: 'YES',
                cancelButtonText: 'NO',
                title: "SETTINGS",
                onConfirm: () {
                  // NfcManager.instance.stopSession();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PrinterPage()));
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
                text: "OPEN PRINTER SETTINGS?"));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('${torTrip.length}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          Text(
                            'TRIP',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${timeservice.formatDateNow()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('AFCS Device ID: ${SESSION['serialNumber']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('${tickets}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'PASS\nCOUNT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (coopData['_id'] == "655321a339c1307c069616e9")
                      Image.asset(
                        'assets/dltblogo.png',
                        width: 80,
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        '${coopData['cooperativeCodeName'].toString().toUpperCase()}',
                        style: GoogleFonts.blackHanSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            letterSpacing: 5))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
