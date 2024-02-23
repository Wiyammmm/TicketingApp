import 'dart:convert';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

class NFCReaderBackend {
  // Future<void> checkNFC() async {
  //   var availability = await FlutterNfcKit.nfcAvailability;
  //   if (availability != NFCAvailability.available) {
  //     print('NFC is not available');

  //     return;
  //   }

  //   try {
  //     var tag = await FlutterNfcKit.poll(
  //       timeout: Duration(seconds: 10),
  //       iosMultipleTagMessage: 'Multiple tags found!',
  //       iosAlertMessage: 'Scan your tag',
  //     );
  //     print(jsonEncode(tag));

  //     const duration = Duration(seconds: 5);
  //     if (tag.type == NFCTagType.iso7816) {
  //       var result =
  //           await FlutterNfcKit.transceive('00B0950000', timeout: duration);
  //       print(result);
  //     }

  //     await FlutterNfcKit.setIosAlertMessage('hi there!');

  //     if (tag.ndefAvailable!) {
  //       for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
  //         print(record.toString());
  //       }

  //       for (var record
  //           in await FlutterNfcKit.readNDEFRawRecords(cached: false)) {
  //         print(jsonEncode(record).toString());
  //       }
  //     }

  //     if (tag.ndefWritable!) {
  //       await FlutterNfcKit.writeNDEFRecords([
  //         ndef.UriRecord.fromString('https://github.com/nfcim/flutter_nfc_kit')
  //       ]);
  //       // await FlutterNfcKit.writeNDEFRawRecords([
  //       //   ndef.NDEFRecord('00', '0001', '0002', '0003', ndef.TypeNameFormat.unknown)
  //       // ]);
  //     }

  //     await FlutterNfcKit.finish(iosAlertMessage: 'Success');
  //   } catch (e) {
  //     print('Error checkNFC: $e');

  //     await FlutterNfcKit.finish(iosErrorMessage: 'Failed');
  //   }
  // }

  Future<String?> startNFCReader() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        // Handle the case when NFC is not available
        print('null');
        return null; // Indicate NFC not available
      }

      // Poll for NFC tags
      var tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 30));

      if (tag != null) {
        print('tag.id: ${tag.id}');
        // Return the UID (serial number)
        return tag.id.toUpperCase();
      }
    } catch (e) {
      print('error $e');
    }

    return null; // No tag found or error occurred
  }
}
