import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/pages/settings/printerPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nfc_manager/nfc_manager.dart';

class appbar extends StatelessWidget {
  const appbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _myBox = Hive.box('myBox');
    fetchServices fetchservice = fetchServices();
    int tickets = fetchservice.fetchAllPassengerCount();
    final torTrip = _myBox.get('torTrip');
    final coopData = _myBox.get('coopData');

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
        decoration: BoxDecoration(color: Color(0xFF00558d)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.5),
                          offset: Offset(0, 0),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${torTrip.length}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Trip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Center(
                  child: Text(
                    // 'DEL MONTE LAND TRANSPORT\nBUS COMPANY, INC.',
                    '${breakString(coopData['cooperativeName'], 24)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                )),
            Expanded(
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.5),
                          offset: Offset(0, 0),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${tickets}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Passenger\nCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
