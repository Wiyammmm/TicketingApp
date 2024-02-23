// ignore_for_file: unused_import

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';

///Test printing
class TestPrinttt {
  fetchServices fetchservice = fetchServices();
  HiveService hiveService = HiveService();

  void customPrint3Column(
      String column1, String column2, String column3, int fontSize,
      [String separator = "   "]) {
    String output = "$column1$column2$column3";
    blue.BlueThermalPrinter bluetooth = blue.BlueThermalPrinter.instance;
    bluetooth.printCustom(output, fontSize, 1);
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // sample() async {
  //   //image max 300px X 300px

  //   ///image from File path
  // String filename = 'codehub.png';
  // ByteData bytesData = await rootBundle.load("assets/codehub.png");
  // String dir = (await getApplicationDocumentsDirectory()).path;
  // File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
  //     .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

  // ///image from Asset
  // ByteData bytesAsset = await rootBundle.load("assets/codehub.png");
  // Uint8List imageBytesFromAsset = bytesAsset.buffer
  //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

  // ///image from Network
  // var response = await http.get(Uri.parse("assets/codehub.png"));
  // Uint8List bytesNetwork = response.bodyBytes;
  // Uint8List imageBytesFromNetwork = bytesNetwork.buffer
  //     .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

  //   bluetooth.isConnected.then((isConnected) {
  //     if (isConnected == true) {
  //       // bluetooth.printNewLine();
  //       // bluetooth.printCustom("HEADER", Size.boldMedium.val, Align.center.val);
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImage(file.path); //path of your image/logo
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
  //       bluetooth.printNewLine();
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
  //           format:
  //               "%-15s %15s %n"); //15 is number off character from left or right
  //       bluetooth.printNewLine();
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
  //       bluetooth.printNewLine();
  //       bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
  //       bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
  //           format:
  //               "%-10s %10s %10s %n"); //10 is number off character from left center and right
  //       bluetooth.printNewLine();
  //       bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
  //       bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
  //           format: "%-8s %7s %7s %7s %n");
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align.center.val,
  //           charset: "windows-1250");
  //       bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val,
  //           charset: "windows-1250");
  //       bluetooth.printCustom("Body left", Size.bold.val, Align.left.val);
  //       bluetooth.printCustom("Body right", Size.medium.val, Align.right.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printQRcode(
  //           "Insert Your Own Text to Generate", 200, 200, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printNewLine();
  //       bluetooth
  //           .paperCut(); //some printer not supported (sometime making image not centered)
  //       //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
  //     }
  //   });
  // }
  sample() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printCustom("TEST", 1, 1);
        bluetooth.printCustom("TEST", 1, 1);
        bluetooth.printCustom("TEST", 1, 1);
        bluetooth.printCustom("TEST", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }

  printDispatch(
      String torNo,
      String driverName,
      String conductorName,
      String dispatcherName,
      String trip,
      int tripNo,
      String vehicleNo,
      String route,
      String bound) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    final formattedDate = formatDateNow();
    // String receipt = 'receipt123';
    // String name = 'customer name';
    // int tablenumber = 5;
    // String note = 'paki over heat';
    // double totalAmount = 99;
    // double grandtotal = 0.0;
    // List<dynamic> dataArray = [
    //   {
    //     'productId': '2pHK2RTUQdSL937VBeTt',
    //     'productName': 'ASD',
    //     'productPrice': 99.0,
    //     'quantity': 1,
    //     'note': ''
    //   }
    // ];
    // if (name.length > 12) {
    //   name = name.substring(0, 12) + "..";
    // }

    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        // bluetooth.printNewLine();

        if (driverName.length > 14) {
          driverName = driverName.substring(0, 14) + "..";
        }
        if (conductorName.length > 14) {
          conductorName = conductorName.substring(0, 14) + "..";
        }
        if (dispatcherName.length > 14) {
          dispatcherName = dispatcherName.substring(0, 14) + "..";
        }
        bluetooth.printCustom(
            breakString("${coopData['cooperativeName']}", 24), 1, 1);
        if (coopData['telephoneNumber'] != null) {
          bluetooth.printCustom(
              "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
        }

        // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
        // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);
        bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
        bluetooth.printCustom("DISPATCH REPORT", 1, 1);
        // bluetooth.print3Column("", "DISPATCH REPORT", " ", 1);
        bluetooth.printCustom("TOR#: $torNo", 1, 1);
        // bluetooth.printCustom("OT: 1234567890000012", 1, 1);

        // bluetooth.printLeftRight("ATM:", "PP352/190300749", 1);
        bluetooth.printCustom("DATE: $formattedDate", 1, 1);
        bluetooth.printLeftRight("TRIP NO.:", "$tripNo", 1);
        bluetooth.printLeftRight("VEHICLE NO.:", "$vehicleNo", 1);

        // bluetooth.print3Column('ATM', ':', 'PP352/190300749', 1);
        // bluetooth.print3Column('DATE', ':', '$formattedDate', 1);
        // bluetooth.print3Column('TRIP NO.', ':', '1', 1);
        // bluetooth.print3Column('VEHICLE NO.', ':', '401', 1);
        bluetooth.printCustom("---ROUTE NAME--", 1, 1);
        bluetooth.printCustom("$route", 1, 1);

        bluetooth.printLeftRight("PASS. COUNT.:", "0", 1);
        bluetooth.printLeftRight("DRIV. NAME.:", "$driverName", 1);
        bluetooth.printLeftRight("COND. NAME.:", "$conductorName", 1);
        bluetooth.printLeftRight("DISP. NAME.:", "$dispatcherName", 1);
        bluetooth.printLeftRight("TYPE:", "${trip.toUpperCase()} TRIP", 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
        bluetooth.printCustom("", 1, 1);
        bluetooth.printCustom("", 1, 1);
        bluetooth.printCustom("", 1, 1);

        bluetooth.paperCut();
      }
    });
  }

  String breakString(String input, int maxLength) {
    List<String> words = input.split(' ');

    String firstLine = '';
    String secondLine = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if ((firstLine.length + 1 + word.length) <= maxLength) {
        // Add the word to the first line
        firstLine += (firstLine == "" ? '' : ' ') + word;
      } else if (secondLine == "") {
        // If the second line is empty, add the word to it
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
    // Return the concatenated lines
    if (secondLine.trim() == "") {
      return "$firstLine";
    } else {
      return '$firstLine\n$secondLine';
    }
  }

  printTicket(
      String ticketNo,
      String cardType,
      double amount,
      double subtotal,
      double kmrun,
      String origin,
      String destination,
      String passengerType,
      bool isDiscounted,
      String vehicleNo,
      String from,
      String to,
      String route,
      double discountPercent,
      int pax,
      double newBalance) async {
    bool isDltb = false;
    bool isJeepney = false;
    final coopData = fetchservice.fetchCoopData();
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }

    if (coopData['coopType'] == "Jeepney") {
      isJeepney = true;
    }

    double discount = 0.0;
    if (cardType == 'mastercard' || cardType == 'cash') {
      cardType = 'CASH';
    } else {
      cardType = 'FILIPAY CARD';
    }
    if (isDiscounted) {
      discount = amount * discountPercent;
      // subtotal = subtotal - discount;
    }

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    // try {
    final formattedDate = formatDateNow();
    // if (route.length <= 16) {
    //   // route = route.substring(0, 12) + "..";
    //   isrouteLong = true;
    // } else if (route.length > 25) {
    //   isrouteLong = true;
    //   route = route.substring(0, 23) + "..";
    // }
    if (origin.length > 16) {
      origin = origin.substring(0, 13) + "..";
    }
    if (destination.length > 16) {
      destination = destination.substring(0, 13) + "..";
    }

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        // bluetooth.printNewLine();

        bluetooth.printCustom(
            breakString("${coopData['cooperativeName']}", 24), 1, 1);
        if (coopData['telephoneNumber'] != null) {
          bluetooth.printCustom(
              "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
        }
        // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

        bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
        bluetooth.printCustom("PASSENGER RECEIPT", 1, 1);
        // bluetooth.print3Column("", "PASSENGER RECEIPT", "\t", 1);
        // bluetooth.print4Column("", "PASSENGER RECEIPT", "", '', 1);

        bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
        // bluetooth.printCustom("Route: $route", 1, 1);
        // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);
        bluetooth.printLeftRight("MOP:", "$cardType", 1);

        bluetooth.printLeftRight(
            "PASS TYPE:", "${passengerType.toUpperCase()}", 1);
        // if (isrouteLong) {
        //   bluetooth.printCustom('Route: $route', 1, 0);
        // } else {
        //   bluetooth.printLeftRight("Route:", "$route", 1);
        // }
        bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
        // bluetooth.printLeftRight("TRAVEL:", "${from}KM - ${to}KM", 1);
        if (!fetchservice.getIsNumeric()) {
          bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
          bluetooth.printLeftRight("DESTINATION:", "$destination", 1);

          bluetooth.printLeftRight("KM Run:", "${kmrun.toInt()}", 1);
        }

        bluetooth.printCustom("DATE: $formattedDate", 1, 1);

        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printLeftRight("Baggage:", "$baggageAmount", 1);
        bluetooth.printLeftRight("Discount:",
            "${isDltb ? discount.round() : discount.toStringAsFixed(2)}", 1);
        bluetooth.printLeftRight("Amount:",
            "${isDltb ? amount.round() : amount.toStringAsFixed(2)}", 1);
        if (isJeepney) {
          bluetooth.printLeftRight("Pax:", "${pax}", 1);
        }
        if (cardType == 'FILIPAY CARD') {
          bluetooth.printLeftRight(
              "REM BAL:", "${newBalance.toStringAsFixed(2)}", 1);
        }

        bluetooth.printCustom("TOTAL AMOUNT", 2, 1);
        bluetooth.printCustom(
            "${isDltb ? subtotal.round() : subtotal.toStringAsFixed(2)}", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("PASSENGER'S COPY", 1, 1);
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
        // CONDUCTOR COPY
        bluetooth.printNewLine();
        // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
        // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

        // bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
        // bluetooth.printCustom("CONDUCTOR'S COPY RECEIPT", 1, 1);
        // bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);

        // bluetooth.printLeftRight("MOP:", "$cardType", 1);
        // bluetooth.printLeftRight(
        //     "PASS TYPE:", "${passengerType.toUpperCase()}", 1);

        // bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
        // bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
        // bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
        // bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

        // bluetooth.printCustom("DATE: $formattedDate", 1, 1);
        // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printLeftRight("Discount:", "${discount.round()}", 1);
        // bluetooth.printLeftRight("Amount:", "${amount.round()}", 1);
        // bluetooth.printCustom("TOTAL AMOUNT", 2, 1);
        // bluetooth.printCustom("${subtotal.round()}", 2, 1);
        // bluetooth.printNewLine();
        // bluetooth.printCustom("CONDUCTOR'S COPY", 1, 1);

        // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printNewLine();
        // bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
    // } catch (e) {
    //   print(e);
    // }
  }

  Future<bool> printListticket(List<Map<String, dynamic>> tickets) async {
    try {
      bool isDltb = false;
      final coopData = fetchservice.fetchCoopData();
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      for (int i = 0; i < tickets.length; i++) {
        print('ticket-$i: ${tickets[i]}');
        String origin = tickets[i]['from_place'];
        String destination = tickets[i]['to_place'];
        String ticketNo = tickets[i]['ticket_no'];
        String cardType = tickets[i]['cardType'];
        String passengerType = tickets[i]['passengerType'];
        String kmrun = tickets[i]['km_run'].toString();
        String dateString = tickets[i]['created_on'].toString();
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDate = DateFormat('MMM dd, yyyy EEE').format(dateTime);
        double discount = double.parse(tickets[i]['discount'].toString());

        double amount = double.parse(tickets[i]['fare'].toString()) +
            double.parse(tickets[i]['discount'].toString()) -
            double.parse(tickets[i]['baggage'].toString());
        double subtotal = double.parse(tickets[i]['fare'].toString()) -
            double.parse(tickets[i]['baggage'].toString());

        double baggageAmount = double.parse(tickets[i]['baggage'].toString());

        if (origin.length > 16) {
          origin = origin.substring(0, 13) + "..";
        }
        if (destination.length > 16) {
          destination = destination.substring(0, 13) + "..";
        }

        bluetooth.isConnected.then((isConnected) {
          if (isConnected == true) {
            // bluetooth.printNewLine();

            bluetooth.printCustom("DEL MONTE LAND", 1, 1);
            bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

            bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
            bluetooth.printCustom("RECEIPT", 1, 1);
            bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
            // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);
            bluetooth.printLeftRight("MOP:", "$cardType", 1);
            bluetooth.printLeftRight(
                "PASS TYPE:", "${passengerType.toUpperCase()}", 1);
            // if (isrouteLong) {
            //   bluetooth.printCustom('Route: $route', 1, 0);
            // } else {
            //   bluetooth.printLeftRight("Route:", "$route", 1);
            // }
            bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
            bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
            bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

            bluetooth.printCustom("DATE: $formattedDate", 1, 1);

            bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
            // bluetooth.printLeftRight("Baggage:", "$baggageAmount", 1);
            bluetooth.printLeftRight(
                "Discount:", "${isDltb ? discount.round() : discount}", 1);
            bluetooth.printLeftRight(
                "Amount:", "${isDltb ? amount.round() : amount}", 1);
            bluetooth.printCustom("TOTAL AMOUNT", 2, 1);
            bluetooth.printCustom("${subtotal.toStringAsFixed(2)}", 2, 1);

            bluetooth.printNewLine();
            bluetooth.printNewLine();
            bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
            bluetooth.printNewLine();
            bluetooth.printNewLine();

            if (baggageAmount > 0) {
              bluetooth.printCustom(
                  breakString("${coopData['cooperativeName']}", 24), 1, 1);
              if (coopData['telephoneNumber'] != null) {
                bluetooth.printCustom(
                    "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
              }
              // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
              // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);
              bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
              bluetooth.printCustom("BAGGAGE RECEIPT", 1, 1);
              bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
              // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);

              // if (isrouteLong) {
              //   bluetooth.printCustom('Route: $route', 1, 0);
              // } else {
              //   bluetooth.printLeftRight("Route:", "$route", 1);
              // }
              bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
              bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
              bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

              bluetooth.printCustom("DATE: $formattedDate", 1, 1);

              bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
              bluetooth.printLeftRight("Baggage:",
                  "${isDltb ? baggageAmount.round() : baggageAmount}", 1);

              bluetooth.printNewLine();
              bluetooth.printNewLine();
              bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
              bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
              bluetooth.printNewLine();
              // bluetooth.printNewLine();

              bluetooth.paperCut();
            }
          }
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  printBaggage(
      String ticketNo,
      String cardType,
      double baggageAmount,
      double kmrun,
      String origin,
      String destination,
      String vehicleNo,
      String from,
      String to,
      String route) {
    bool isDltb = false;
    final coopData = fetchservice.fetchCoopData();
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
    if (cardType == 'mastercard' || cardType == 'cash') {
      cardType = 'CASH';
    } else {
      cardType = 'FILIPAY CARD';
    }
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }
      if (origin.length > 16) {
        origin = origin.substring(0, 13) + "..";
      }
      if (destination.length > 16) {
        destination = destination.substring(0, 13) + "..";
      }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          bluetooth.printCustom("BAGGAGE RECEIPT", 1, 1);
          bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);
          bluetooth.printLeftRight("MOP:", "$cardType", 1);

          // bluetooth.printLeftRight("Ticket#:", "$ticketNo", 1);

          // if (isrouteLong) {
          //   bluetooth.printCustom('Route: $route', 1, 0);
          // } else {
          //   bluetooth.printLeftRight("Route:", "$route", 1);
          // }
          bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
          if (!fetchservice.getIsNumeric()) {
            bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
            bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
          }

          bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

          bluetooth.printCustom("DATE: $formattedDate", 1, 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printLeftRight("Baggage:",
              "${isDltb ? baggageAmount.round() : baggageAmount}", 1);
          bluetooth.printNewLine();
          bluetooth.printCustom("PASSENGER'S COPY", 1, 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          // CONDUCTORS COPY
          bluetooth.printNewLine();
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          // bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          // bluetooth.printCustom("CONDUCTOR COPY BAGGAGE RECEIPT", 1, 1);
          // bluetooth.printCustom("Ticket#:   $ticketNo", 1, 1);

          // bluetooth.printLeftRight("ORIGIN:", "$origin", 1);
          // bluetooth.printLeftRight("DESTINATION:", "$destination", 1);
          // bluetooth.printLeftRight("KM Run:", "$kmrun", 1);

          // bluetooth.printCustom("DATE: $formattedDate", 1, 1);

          // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("Baggage:", "${baggageAmount.round()}", 1);
          // bluetooth.printNewLine();
          // bluetooth.printCustom("CONDUCTOR'S COPY", 1, 1);

          // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  printExpenses(List<Map<String, dynamic>> expensesList, String vehicleNo) {
    final coopData = fetchservice.fetchCoopData();
    bool isDltb = false;
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          bluetooth.printCustom("EXPENSES", 1, 1);
          // bluetooth.print3Column("", "EXPENSES", "", 1);

          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          if (vehicleNo != "") {
            bluetooth.printCustom("VEHICLE NO: $vehicleNo", 1, 1);
          }
          List<Map<String, dynamic>> othersExpenses = [];
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printLeftRight("PARTICULAR:", "AMOUNT", 1);
          double totalExpenses = 0;
          for (var expense in expensesList) {
            totalExpenses += expense['amount'];
            String expenseDescription = expense['particular'];
            double expenseAmount = double.parse(expense['amount'].toString());
            // bluetooth.printLeftRight(
            //     "PARTICULAR:", "${expenseDescription.toUpperCase()}", 1);
            if (expense['particular'] == "SERVICES" ||
                expense['particular'] == "CALLER'S FEE" ||
                expense['particular'] == "EMPLOYEE BENEFITS" ||
                expense['particular'] == "MATERIALS" ||
                expense['particular'] == "REPRESENTATION" ||
                expense['particular'] == "REPAIR") {
              othersExpenses.add(expense);
            } else {
              bluetooth.printLeftRight(
                  "$expenseDescription",
                  "${isDltb ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
                  1);
            }
          }
          if (othersExpenses.isNotEmpty) {
            bluetooth.printLeftRight("OTHERS", "", 1);
            for (var expense in othersExpenses) {
              String expenseDescription = expense['particular'];
              double expenseAmount = double.parse(expense['amount'].toString());
              bluetooth.printLeftRight(
                  "  ${expenseDescription}",
                  "${isDltb ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
                  1);
            }
          }
          bluetooth.printLeftRight(
              "TOTAL EXPENSES", "${totalExpenses.toStringAsFixed(2)}", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printNewLine();
          // bluetooth.printNewLine();
          // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          // bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> printArrival(
      String opening,
      String closing,
      int totalPassenger,
      int totalBaggage,
      double totalPassengerAmount,
      double totalBaggageAmount,
      int tripNo,
      String vehicleNo,
      String conductorName,
      String driverName,
      String dispatcherName,
      String route,
      String torNo) async {
    final _myBox = Hive.box('myBox');
    // final SESSION = _myBox.get('SESSION');
    final coopData = fetchservice.fetchCoopData();
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    final torTicket = _myBox.get('torTicket');
    String control_no = "";
    try {
      control_no = torTrip[session['currentTripIndex'] - 1]['control_no'];
    } catch (e) {
      control_no = torTrip[session['currentTripIndex']]['control_no'];
    }
    List<Map<String, dynamic>> filteredTickets = torTicket
        .where((ticket) => ticket['control_no'] == control_no)
        .toList();

    // int baggageWithPassengerCount = fetchservice.baggageWithPassengerCount();
    int baggageWithPassengerCount() {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] > 0))
          .length;
      return totalBaggageCount;
    }

    int baggageOnlyCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] == 0))
          .length;
      return totalBaggageCount;
    }

    double totalTripBaggageOnly() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] == 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    double totalTripBaggagewithPassenger() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] > 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    int cardSalesCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['cardType'] != 'mastercard' &&
                  item['cardType'] != 'cash') &&
              item['control_no'] == control_no)
          .length;
      return totalBaggageCount;
    }

    double totalBaggageperTrip() {
      final torTicket = _myBox.get('torTicket');

      double sumOfBaggage = torTicket
          .where((fare) => fare['control_no'] == control_no)
          .map<double>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, baggage) => prev + baggage);

      return sumOfBaggage;
    }

    double totalTripCardSales() {
      final fareList = _myBox.get('torTicket');

      // String controlNumberToFilter = fetchservice.getCurrentControlNumber();

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] != "mastercard" && fare['cardType'] != "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] != "mastercard" &&
                  fare['additionalFareCardType'] != "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount;
    }

    double totalTripCashReceived() {
      final fareList = _myBox.get('torTicket');

      String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] == cardTypeToFilter ||
                  fare['cardType'] == "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] == cardTypeToFilter ||
                  fare['additionalFareCardType'] == "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount;
    }

    double totalTripGrandTotal() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble() +
              (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    double totalAddFare() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd,yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (conductorName.length > 16) {
      conductorName = conductorName.substring(0, 13) + "..";
    }
    if (driverName.length > 16) {
      driverName = driverName.substring(0, 13) + "..";
    }
    if (dispatcherName.length > 16) {
      dispatcherName = dispatcherName.substring(0, 13) + "..";
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          bluetooth.printCustom("ARRIVAL", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);

          bluetooth.printCustom("TOR#: $torNo", 1, 1);
          if (opening != 'NO TICKET') {
            bluetooth.printCustom("OPENING:    $opening", 1, 1);
          } else {
            bluetooth.printLeftRight(
                "OPENING:", "${filteredTickets[0]['ticket_no']}", 1);
          }
          if (closing != 'NO TICKET') {
            bluetooth.printCustom("CLOSING:    $closing", 1, 1);
          } else {
            bluetooth.printLeftRight("CLOSING:", "$closing", 1);
          }

          bluetooth.printLeftRight("TOTAL PASS:", "$totalPassenger", 1);
          // bluetooth.printLeftRight("BO ISSUED:", "${baggageOnlyCount()}", 1);
          // bluetooth.printLeftRight(
          //     "BWP ISSUED:", "${baggageWithPassengerCount()}", 1);
          bluetooth.printLeftRight("TOTAL BAGGAGE:", "${totalBaggage}", 1);
          // bluetooth.printLeftRight(
          //     "BO TOTAL:", "${totalTripBaggageOnly().toStringAsFixed(2)}", 1);
          // bluetooth.printLeftRight("BWP TOTAL:",
          //     "${totalTripBaggagewithPassenger().toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight("CS ISSUED:", "${cardSalesCount()}", 1);

          // bluetooth.printLeftRight("TOTAL PASSES:", "0", 1);
          bluetooth.printLeftRight("CARD SALES:", "${totalTripCardSales()}", 1);
          bluetooth.printLeftRight(
              "BAGGAGE AMOUNT:", "${totalBaggageperTrip()}", 1);
          bluetooth.printLeftRight("TOTAL FARE:",
              "${fetchservice.totalTripFare().toStringAsFixed(2)}", 1);

          bluetooth.printLeftRight(
              "ADD FARE:", "${totalAddFare().toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight("CASH RECEIVED:",
              "${totalTripCashReceived().toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "GRAND TOTAL:", "${totalTripGrandTotal().toStringAsFixed(2)}", 1);
          // bluetooth.printLeftRight("TOTAL CS:", "0", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printLeftRight("TRIP NO:", "$tripNo", 1);
          bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
          bluetooth.printLeftRight("CONDUCTOR:", "$conductorName", 1);
          bluetooth.printLeftRight("DRIVER:", "$driverName", 1);
          bluetooth.printLeftRight("DISPATCHER:", "$dispatcherName", 1);
          bluetooth.printCustom("ROUTE:     $route", 1, 1);
          bluetooth.printLeftRight("SN:", "${session['serialNumber']}", 1);
          // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTripReport(
      // String torNo,
      // String vehicleNo,
      // String conductorName,
      // String driverName,
      // String dispatcherName,
      String cashierName,
      // int regularCount,
      // int discountedCount,
      // int baggageCount,
      // String route,
      // int totalTickets,
      // double totalAmount,
      List<Map<String, dynamic>> torTrip,
      List<Map<String, dynamic>> torTicket,
      List<Map<String, dynamic>> prePaidPassenger,
      List<Map<String, dynamic>> prePaidBaggage,
      double finalRemitt,
      double shortOver,
      double puncherTR,
      double puncherTC,
      double puncherBR,
      double puncherBC) async {
    try {
      final expensesList = fetchservice.fetchExpensesList();

      final coopData = fetchservice.fetchCoopData();
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // final myBox = Hive.box('myBox');
          // final ticketList = myBox.get('torTicket');

          bool isPrinterReady = false;

          isPrinterReady = true;

          double grandTotal = 0;
          double grandBaggage = 0;
          double grandPrepaidPassengerTotal = 0;
          double grandPrepaidBaggageTotal = 0;
          double grandTotalCashRecived = 0;
          double additionalFare = 0;

          String formatDateNow() {
            final now = DateTime.now();
            final formattedDate =
                DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
            return formattedDate;
          }

          String dateConverter(String dateString) {
            DateTime dateTime = DateTime.parse(dateString);
            String formattedDateTime =
                DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
            return formattedDateTime;
          }

          final formattedDate = formatDateNow();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          bluetooth.printCustom("TRIP SUMMARY", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          //         bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);

          for (int i = 0; i < torTrip.length; i++) {
            print('tortrip[$i]: ${torTrip[i]}');
            String conductorName = torTrip[i]['conductor'].toString();
            String dispatcherName1 =
                torTrip[i]['departed_dispatcher'].toString();
            String dispatcherName2 =
                torTrip[i]['arrived_dispatcher'].toString();
            String driverName = torTrip[i]['driver'].toString();
            String control_no = torTrip[i]['control_no'].toString();
            String torNo = torTrip[i]['tor_no'].toString();
            String departed_date =
                dateConverter(torTrip[i]['departure_timestamp'].toString());
            String arrived_date =
                dateConverter(torTrip[i]['arrival_timestamp'].toString());
            String vehicleNo = torTrip[i]['bus_no'].toString();

            int regularCount = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no &&
                    (ticket['fare'] ?? 0) > 0 &&
                    ticket['discount'] == 0)
                .fold<int>(
                    0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

            print('ticketList: $torTicket');
            print('regularCount: $regularCount');
            int discountedCount = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no &&
                    (ticket['fare'] ?? 0) > 0 &&
                    ticket['discount'] > 0)
                .fold<int>(
                    0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);
            int pwdCount = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no &&
                    (ticket['fare'] ?? 0) > 0 &&
                    ticket['passengerType'] == "pwd")
                .fold<int>(
                    0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

            int studentCount = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no &&
                    (ticket['fare'] ?? 0) > 0 &&
                    ticket['passengerType'] == "student")
                .fold<int>(
                    0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

            int seniorCount = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no &&
                    (ticket['fare'] ?? 0) > 0 &&
                    ticket['passengerType'] == "senior")
                .fold<int>(
                    0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

            int baggageCounter = torTicket
                .where((ticket) =>
                    ticket['control_no'] == control_no && ticket['baggage'] > 0)
                .length;

            int prePaidPassengerCount = prePaidPassenger
                .where((entry) => entry['control_no'] == control_no)
                .fold(
                  0,
                  (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
                );
            int prePaidBaggageCount = prePaidBaggage
                .where((ticket) => ticket['control_no'] == control_no)
                .length;

            double prePaidPassengerAmount = prePaidPassenger
                .where((entry) => entry['control_no'] == control_no)
                .fold(
                  0.0,
                  (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
                );
            double cardSales = torTicket
                .where((entry) =>
                    entry['control_no'] == control_no &&
                    (entry['cardType'] != "mastercard" &&
                        entry['cardType'] != "cash"))
                .fold(
                    0.0,
                    (sum, entry) =>
                        sum +
                        (double.parse(entry['fare'].toString() ?? "0.0") *
                            entry['pax']) +
                        double.parse(entry['baggage'].toString() ?? "0.0"));

            cardSales += torTicket
                .where((entry) =>
                    entry['control_no'] == control_no &&
                    (entry['additionalFareCardType'] != "mastercard" &&
                        entry['additionalFareCardType'] != "cash"))
                .fold(
                    0.0,
                    (sum, entry) =>
                        sum +
                        double.parse(
                            entry['additionalFare'].toString() ?? "0.0"));
            double cashR = torTicket
                .where((entry) =>
                    entry['control_no'] == control_no &&
                    (entry['cardType'] == "mastercard" ||
                        entry['cardType'] == "cash"))
                .fold(
                    0.0,
                    (sum, entry) =>
                        sum +
                        (double.parse(
                            entry['fare'].toString() ?? "0.0" * entry['pax'])) +
                        double.parse(entry['baggage'].toString() ?? "0.0"));

            cashR += torTicket
                .where((entry) =>
                    entry['control_no'] == control_no &&
                    (entry['additionalFareCardType'] == "mastercard" ||
                        entry['additionalFareCardType'] == "cash"))
                .fold(
                    0.0,
                    (sum, entry) =>
                        sum +
                        double.parse(
                            entry['additionalFare'].toString() ?? "0.0"));
            double prePaidBaggageAmount = prePaidBaggage
                .where((entry) => entry['control_no'] == control_no)
                .fold(
                  0.0,
                  (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
                );
            grandPrepaidPassengerTotal += prePaidPassengerAmount;
            grandPrepaidBaggageTotal += prePaidBaggageAmount;

            double tripTotalbaggage = torTicket
                .where((ticket) => ticket['control_no'] == control_no)
                .fold(
                    0.0,
                    (sum, ticket) =>
                        sum + (ticket['baggage'] as num).toDouble());

            int totalTickets = torTicket
                .where((ticket) => ticket['control_no'] == control_no)
                .length;
            double totalAmount = torTicket
                .where((ticket) => ticket['control_no'] == control_no)
                .fold(
                    0.0,
                    (sum, ticket) =>
                        sum +
                        ((ticket['fare'] as num).toDouble() * ticket['pax']) +
                        (ticket['baggage'] as num).toDouble() +
                        (ticket['additionalFare'] as num).toDouble());

            additionalFare = torTicket
                .where((ticket) => ticket['control_no'] == control_no)
                .fold(
                    0.0,
                    (sum, ticket) =>
                        sum + (ticket['additionalFare'] as num).toDouble());

            grandTotal +=
                totalAmount += prePaidBaggageAmount + prePaidPassengerAmount;

            grandBaggage += tripTotalbaggage;
            grandTotalCashRecived += totalAmount;
            String route = '${torTrip[i]['route']}';
            String tripType = '${torTrip[i]['tripType']}';

            if (conductorName.length > 16) {
              conductorName = conductorName.substring(0, 13) + "..";
            }
            if (dispatcherName1.length > 16) {
              dispatcherName1 = dispatcherName1.substring(0, 13) + "..";
            }
            if (dispatcherName2.length > 16) {
              dispatcherName2 = dispatcherName2.substring(0, 13) + "..";
            }
            if (driverName.length > 16) {
              driverName = driverName.substring(0, 13) + "..";
            }
            if (cashierName.length > 16) {
              cashierName = cashierName.substring(0, 13) + "..";
            }

            // if (route.length <= 16) {
            //   // route = route.substring(0, 12) + "..";
            //   isrouteLong = true;
            // } else if (route.length > 25) {
            //   isrouteLong = true;
            //   route = route.substring(0, 23) + "..";
            // }

            // bluetooth.printNewLine();

            if (isPrinterReady) {
              // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
              // if (coopData['coopType'] == 'Bus') {
              //   bluetooth.printCustom("TRIP No ${i + 1}", 1, 1);
              // }
              // bluetooth.printCustom("TOR#: $torNo", 1, 1);
              // bluetooth.printCustom(
              //     "TRIP TYPE: ${tripType.toUpperCase()}", 1, 1);
              // // bluetooth.printLeftRight("ATM:", "1", 1);
              // bluetooth.printLeftRight("DISPATCHED:", "$departed_date", 1);
              // bluetooth.printLeftRight("ARRIVED:", "$arrived_date", 1);
              // bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
              // bluetooth.printLeftRight("CONDUCTOR:", "$conductorName", 1);
              // bluetooth.printLeftRight("DRIVER:", "$driverName", 1);
              // bluetooth.printLeftRight("DISPATCHER 1:", "$dispatcherName1", 1);
              // bluetooth.printLeftRight("DISPATCHER 2:", "$dispatcherName2", 1);
              // bluetooth.printLeftRight("CASHIER:", "$cashierName", 1);
              if (coopData['coopType'] == 'Bus') {
                // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
                // bluetooth.printLeftRight("TYPE:", "", 1);
                // bluetooth.printLeftRight("Regular:", "$regularCount", 1);

                // bluetooth.printLeftRight("PWD:", "$pwdCount", 1);
                // bluetooth.printLeftRight("STUDENT:", "$studentCount", 1);
                // bluetooth.printLeftRight("SENIOR:", "$seniorCount", 1);
                // bluetooth.printLeftRight("Discounted:", "$discountedCount", 1);
                // bluetooth.printLeftRight(
                //     "Baggage Issued:", "$baggageCounter", 1);
                // bluetooth.printLeftRight("Total Baggage:",
                //     "${tripTotalbaggage.toStringAsFixed(2)}", 1);
                // bluetooth.printLeftRight(
                //     "CS:", "${cardSales.toStringAsFixed(2)}", 1);
                // bluetooth.printLeftRight(
                //     "CASH RECEIVED:", "${cashR.toStringAsFixed(2)}", 1);
                // bluetooth.printLeftRight(
                //     "PREPAID PASS:", "$prePaidPassengerCount", 1);
                // bluetooth.printLeftRight(
                //     "PREPAID BAGG:", "$prePaidBaggageCount", 1);
                // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

                // bluetooth.printCustom("TRIP", 1, 1);
                // bluetooth.printCustom("$route", 1, 1);

                // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

                // bluetooth.printLeftRight(
                //     "TOTAL TICKETS:", "${totalTickets.toStringAsFixed(2)}", 1);
                // bluetooth.printLeftRight(
                //     "SUBTOTAL AMOUNT:", "${totalAmount.toStringAsFixed(2)}", 1);
                // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
                // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
                List<Map<String, dynamic>> othersExpenses = [];
                try {
                  if (torTrip[i]['control_no'] ==
                      expensesList[i]['control_no']) {
                    double totalExpenses = 0;
                    List<Map<String, dynamic>> filteredExpenses = expensesList
                        .where((expenses) =>
                            expenses['control_no'] == torTrip[i]['control_no'])
                        .toList();
                    if (coopData['coopType'] == 'Bus') {
                      bluetooth.printCustom("TRIP No ${i + 1}", 1, 1);
                    }
                    bluetooth.printCustom("TOR#: $torNo", 1, 1);
                    bluetooth.printCustom(
                        "TRIP TYPE: ${tripType.toUpperCase()}", 1, 1);
                    bluetooth.printCustom("EXPENSES", 1, 1);
                    bluetooth.printLeftRight("PARTICULAR:", "AMOUNT", 1);
                    for (var element in filteredExpenses) {
                      totalExpenses +=
                          double.parse(element['amount'].toString());
                      if (element['particular'] == "SERVICES" ||
                          element['particular'] == "CALLER'S FEE" ||
                          element['particular'] == "EMPLOYEE BENEFITS" ||
                          element['particular'] == "MATERIALS" ||
                          element['particular'] == "REPRESENTATION" ||
                          element['particular'] == "REPAIR") {
                        othersExpenses.add(element);
                      } else {
                        bluetooth.printLeftRight("${element['particular']}",
                            "${element['amount']}", 1);
                      }
                    }
                    if (othersExpenses.isNotEmpty) {
                      bluetooth.printLeftRight("OTHERS", "", 1);
                      for (var element in othersExpenses) {
                        if ("${element['particular']}".length > 16) {
                          element['particular'] =
                              element['particular'].substring(0, 13) + ".";
                        }
                        bluetooth.printLeftRight(" ${element['particular']}",
                            "${element['amount']}", 1);
                      }
                    }

                    bluetooth.printLeftRight(
                        "TOTAL EXPENSES:", "$totalExpenses", 1);
                  }
                } catch (e) {
                  print(e);
                }

                // bluetooth.printNewLine();
                // bluetooth.printNewLine();
              }
            }
          }
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          grandTotalCashRecived += puncherTR + puncherBR;
          bluetooth.printLeftRight(
              "TOTAL BAGGAGE:", "${grandBaggage.toStringAsFixed(2)}", 1);
          if (coopData['coopType'] == "Bus") {
            bluetooth.printLeftRight("PREPAID PASS:",
                "${grandPrepaidPassengerTotal.toStringAsFixed(2)}", 1);
            bluetooth.printLeftRight("PREPAID BAGG:",
                "${grandPrepaidBaggageTotal.toStringAsFixed(2)}", 1);
          }

          bluetooth.printLeftRight("PUNCHER TR:", "${puncherTR}", 1);
          bluetooth.printLeftRight("PUNCHER TC:", "${puncherTC}", 1);

          bluetooth.printLeftRight("PUNCHER BR:", "${puncherBR}", 1);
          bluetooth.printLeftRight("PUNCHER BC:", "${puncherBC}", 1);

          // bluetooth.printLeftRight("BO TOTAL:",
          //     "${fetchservice.totalBaggageOnly().toStringAsFixed(2)}", 1);
          // bluetooth.printLeftRight(
          //     "BWP TOTAL:",
          //     "${fetchservice.totalBaggagewithPassenger().toStringAsFixed(2)}",
          //     1);
          // bluetooth.printLeftRight(
          //     "BAGGAGE TOTAL:",
          //     "${(fetchservice.totalBaggageOnly() + fetchservice.totalBaggagewithPassenger()).toStringAsFixed(2)}",
          //     1);
          bluetooth.printLeftRight("FINAL REMITT:", "$finalRemitt", 1);
          bluetooth.printLeftRight("SHORT/OVER:", "$shortOver", 1);

          bluetooth.printLeftRight("CASH RECEIVED:",
              "${hiveService.getCashReceived().toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight("CARD SALES:",
              "${fetchservice.grandTotalCardSales().toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight("ADD FARE:", "$additionalFare", 1);

          bluetooth.printLeftRight(
              "GRAND TOTAL:", "${grandTotalCashRecived.toStringAsFixed(2)}", 1);

          if (coopData['coopType'] != "Bus") {
            try {
              for (int i = 0; i < torTrip.length; i++) {
                // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
                if (expensesList.isNotEmpty) {
                  if (torTrip[i]['control_no'] ==
                      expensesList[i]['control_no']) {
                    bluetooth.printCustom(
                        "- - - - - - - - - - - - - - -", 1, 1);
                    double totalExpenses = 0;
                    List<Map<String, dynamic>> filteredExpenses = expensesList
                        .where((expenses) =>
                            expenses['control_no'] == torTrip[i]['control_no'])
                        .toList();

                    bluetooth.printCustom("EXPENSES", 1, 1);
                    bluetooth.printLeftRight("PARTICULAR:", "AMOUNT", 1);
                    for (var element in filteredExpenses) {
                      totalExpenses +=
                          double.parse(element['amount'].toString());
                      bluetooth.printLeftRight("${element['particular']}",
                          "${element['amount']}", 1);
                    }
                    bluetooth.printLeftRight("TOTAL:", "$totalExpenses", 1);
                  }
                }
              }
            } catch (e) {
              print(e);
            }
          }

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print('print report error: $e');
      return false;
    }
  }

  bool printTripSummary() {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TRIP SUMMARY", 1, 1);
          bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printLeftRight("DISPATCHED:", "$formattedDate", 1);
          bluetooth.printLeftRight("VEHICLE NO:", "103", 1);
          bluetooth.printLeftRight("CONDUCTOR:", "Juan Dela Cruz", 1);
          bluetooth.printLeftRight("DRIVER:", "Juan Dela Cruz", 1);
          bluetooth.printLeftRight("DISPATCHER:", "Juan Dela Cruz", 1);
          bluetooth.printCustom("ROUTE:     DISTRICT - STAR MALL", 1, 1);
          // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  num convertNumToIntegerOrDecimal(num number) {
    // Convert the number to a string
    String numberString = number.toString();
    int decimalIndex = numberString.indexOf('.');
    // Check if the number contains a decimal point or is greater than 0 as a double
    if (decimalIndex != -1 && decimalIndex < numberString.length - 1) {
      // If it contains a decimal or is greater than 0, return it as a double
      String decimalPart = numberString.substring(decimalIndex + 1);
      if (double.parse(decimalPart) > 0) {
        return double.parse(numberString);
      } else {
        return number.toInt();
      }
    } else {
      // If it doesn't contain a decimal and is not greater than 0, return it as an integer
      return number.toInt();
    }
  }

  Future<bool> printInspectionSummary(
      String type,
      String torNo,
      String passenger,
      String baggage,
      String headCount,
      String kmPost,
      String driverName,
      String conductorName,
      String vehicleNo,
      String route,
      String inspectorName,
      List<Map<String, dynamic>> tickets,
      bool isTicket,
      int discrepancy,
      int passengerTransfer,
      int PassengerWithPass,
      int PassengerPrepaid,
      int baggageCount) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("INSPECTION SUMMARY", 1, 1);
          bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          bluetooth.printCustom("TOR#: $torNo", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
          bluetooth.printLeftRight("INSPECTOR:", "$inspectorName", 1);
          bluetooth.printLeftRight("CONDUCTOR:", "$conductorName", 1);
          bluetooth.printLeftRight("DRIVER:", "$driverName", 1);
          bluetooth.printCustom("ROUTE:     $route", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printLeftRight("PASSENGER:", "$passenger", 1);

          bluetooth.printLeftRight("BAGGAGE:", "$baggage", 1);
          if (!fetchservice.getIsNumeric()) {
            bluetooth.printLeftRight("HEAD COUNT:", "$headCount", 1);
            bluetooth.printLeftRight("BAGGAGE COUNT:", "${baggageCount}", 1);
            bluetooth.printLeftRight("DISCREPANCY:", "${discrepancy}", 1);
          }

          if (!fetchservice.getIsNumeric()) {
            bluetooth.printLeftRight("TRANSFER:", "$passengerTransfer", 1);
            bluetooth.printLeftRight("PASSED:", "$PassengerWithPass", 1);
            bluetooth.printLeftRight("PREPAID:", "$PassengerPrepaid", 1);
          }
          if (!fetchservice.getIsNumeric()) {
            bluetooth.printLeftRight("KM POST:", "$kmPost", 1);
          }

          // bluetooth.printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("INSPECTION TICKET REPORT", 1, 1);
          // if (isTicket) {

          // bluetooth.print4Column("TN", "FR", "TO", "FARE", 1);
          // bluetooth.printCustom("CN\tFR\tTO\tFARE", 1, 1);
          if (!fetchservice.getIsNumeric()) {
            if (coopData['coopType'] != "Bus") {
              bluetooth.printCustom("TN   TIME   FR TO   FARE   PAX", 1, 1);
            } else {
              bluetooth.printCustom("TN\tTIME\tFR TO\tFARE", 1, 1);
            }
          } else {
            if (coopData['coopType'] != "Bus") {
              bluetooth.print4Column("TN", "TIME", "FARE", "PAX", 1);
            } else {
              bluetooth.print3Column("TN", "TIME", "FARE", 1);
            }
            // bluetooth.printCustom("TN\tTIME\tFR  TO\tFARE", 1, 1);
          }

          double grandtotal = 0;
          double grandbaggage = 0;
          double grandcardsales = 0;
          double grandcashreceived = 0;

          double grandbaggageonly = 0;
          double grandbaggagewithpassenger = 0;

          int pwdcount = 0;
          int studentcount = 0;
          int seniorcount = 0;
          int cardsalescount = 0;
          int regularcount = 0;
          int baggagecount = 0;
          int discountedcount = 0;
          int totalticketcount = 0;
          double addfare = 0;

          bool havebaggage = false;
          bool havepwd = false;
          bool havestudent = false;
          bool havesenior = false;
          bool havecardsales = false;
          bool havebaggageonly = false;
          bool havebaggagewithpassenger = false;
          bool haveAddFare = false;
          bool haveCsAddfare = false;
          bool havecardsalesbaggage = false;
          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            // print('inspection tickets $i: ${tickets}');
            grandtotal += (double.parse(tickets[i]['fare'].toString()) *
                tickets[i]['pax']);

            grandtotal += double.parse(tickets[i]['baggage'].toString());
            addfare += double.parse(tickets[i]['additionalFare'].toString());

            totalticketcount += 1;
            if (tickets[i]['cardType'] == "mastercard" ||
                tickets[i]['cardType'] == "cash") {
              grandcashreceived +=
                  (double.parse(tickets[i]['fare'].toString()) *
                          tickets[i]['pax']) +
                      double.parse(tickets[i]['baggage'].toString());
            }
            if (tickets[i]['additionalFareCardType'] == "mastercard" ||
                tickets[i]['additionalFareCardType'] == "cash") {
              grandcashreceived +=
                  double.parse(tickets[i]['additionalFare'].toString());
            }
            if (tickets[i]['cardType'] != "mastercard" &&
                tickets[i]['cardType'] != "cash") {
              grandcardsales += (double.parse(tickets[i]['fare'].toString()) *
                      tickets[i]['pax']) +
                  double.parse(tickets[i]['baggage'].toString());
            }
            if (tickets[i]['additionalFareCardType'] != "mastercard" &&
                tickets[i]['additionalFareCardType'] != "cash") {
              grandcardsales +=
                  double.parse(tickets[i]['additionalFare'].toString());
            }
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                (tickets[i]['passengerType'] == 'regular' ||
                    tickets[i]['passengerType'] == 'FULL FARE')) {
              regularcount += tickets[i]['pax'] as int;

              // bluetooth.print4Column(
              //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
              //     "${tickets[i]['from_km']}",
              //     "${tickets[i]['to_km']}",
              //     "${tickets[i]['fare']}",
              //     1);
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              if (!fetchservice.getIsNumeric()) {
                if (coopData['coopType'] != "Bus") {
                  bluetooth.printCustom(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-${toKm} ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                      1,
                      1);
                } else {
                  bluetooth.printCustom(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${toKm}\t${tickets[i]['fare']}",
                      1,
                      1);
                }
              } else {
                if (coopData['coopType'] != "Bus") {
                  bluetooth.print4Column(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                      "$timeOnly",
                      "${tickets[i]['fare']}",
                      "${tickets[i]['pax']}",
                      1);
                } else {
                  bluetooth.print3Column(
                      "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                      "$timeOnly",
                      "${tickets[i]['fare']}",
                      1);
                }
              }
            }
            // if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] == 0) {
            //   havebaggageonly = true;
            // }
            if (tickets[i]['baggage'] > 0) {
              havebaggage = true;
            }
            if (tickets[i]['additionalFare'] > 0 &&
                (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                    tickets[i]['additionalFareCardType'] == 'cash')) {
              haveAddFare = true;
            }
            if (tickets[i]['additionalFare'] > 0 &&
                tickets[i]['additionalFareCardType'] != 'mastercard' &&
                tickets[i]['additionalFareCardType'] != 'cash') {
              haveCsAddfare = true;
            }

            if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] > 0) {
              havebaggagewithpassenger = true;
            }

            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'student') {
              havestudent = true;
            }
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'pwd') {
              havepwd = true;
            }
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'senior') {
              havesenior = true;
            }
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] != 'mastercard' &&
                    tickets[i]['cardType'] != 'cash')) {
              havecardsales = true;
            }
            if (tickets[i]['fare'] == 0 &&
                tickets[i]['cardType'] != 'mastercard' &&
                tickets[i]['cardType'] != 'cash') {
              havecardsalesbaggage = true;
            }
          }

          grandtotal += addfare;
          if (havebaggage) {
            bluetooth.printLeftRight("BAGGAGE", "", 1);
            // bluetooth.printCustom("BAGGAGE", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['baggage'] > 0) {
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                grandbaggageonly +=
                    double.parse(tickets[i]['baggage'].toString());
                baggagecount += 1;
                grandbaggage += double.parse(tickets[i]['baggage'].toString());
                // grandcashreceived +=
                //     double.parse(tickets[i]['baggage'].toString()) +
                //         double.parse(tickets[i]['additionalFare'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['baggage']}",
                //     1);
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}\t\t\t",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['baggage']}",
                        1);
                  } else {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['baggage']}",
                        "",
                        1);
                  }
                }
              }
            }
          }
          // if (havebaggageonly) {
          //   bluetooth.printLeftRight("BAGGAGE ONLY", "", 1);
          //   // bluetooth.printCustom("BAGGAGE", 1, 1);

          //   for (int i = 0; i < tickets.length; i++) {
          //     if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] <= 0) {
          //       DateTime dateTime =
          //           DateTime.parse(tickets[i]['created_on'].toString());
          //       String timeOnly = "${dateTime.hour}:${dateTime.minute}";
          //       grandbaggageonly +=
          //           double.parse(tickets[i]['baggage'].toString());
          //       baggagecount += 1;
          //       grandbaggage += double.parse(tickets[i]['baggage'].toString());
          //       // grandcashreceived +=
          //       //     double.parse(tickets[i]['baggage'].toString()) +
          //       //         double.parse(tickets[i]['additionalFare'].toString());
          //       // bluetooth.print4Column(
          //       //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //       //     "${tickets[i]['from_km']}",
          //       //     "${tickets[i]['to_km']}",
          //       //     "${tickets[i]['baggage']}",
          //       //     1);
          //       if (!fetchservice.getIsNumeric()) {
          //         if (coopData['coopType'] != "Bus") {
          //           bluetooth.printCustom(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}",
          //               1,
          //               1);
          //         } else {
          //           bluetooth.printCustom(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}\t\t\t",
          //               1,
          //               1);
          //         }
          //       } else {
          //         if (coopData['coopType'] != "Bus") {
          //           bluetooth.print3Column(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //               "$timeOnly",
          //               "${tickets[i]['baggage']}",
          //               1);
          //         } else {
          //           bluetooth.print4Column(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //               "$timeOnly",
          //               "${tickets[i]['baggage']}",
          //               "",
          //               1);
          //         }
          //       }
          //     }
          //   }
          // }
          // if (havebaggagewithpassenger) {
          //   bluetooth.printLeftRight("BAGGAGE W/ PASS", "", 1);
          //   // bluetooth.printCustom("BAGGAGE", 1, 1);

          //   for (int i = 0; i < tickets.length; i++) {
          //     if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] > 0) {
          //       DateTime dateTime =
          //           DateTime.parse(tickets[i]['created_on'].toString());
          //       String timeOnly = "${dateTime.hour}:${dateTime.minute}";
          //       grandbaggagewithpassenger +=
          //           double.parse(tickets[i]['baggage'].toString());
          //       baggagecount += 1;
          //       grandbaggage += double.parse(tickets[i]['baggage'].toString());
          //       // grandcashreceived +=
          //       //     double.parse(tickets[i]['baggage'].toString()) +
          //       //         double.parse(tickets[i]['additionalFare'].toString());
          //       // bluetooth.print4Column(
          //       //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //       //     "${tickets[i]['from_km']}",
          //       //     "${tickets[i]['to_km']}",
          //       //     "${tickets[i]['baggage']}",
          //       //     1);
          //       if (!fetchservice.getIsNumeric()) {
          //         if (coopData['coopType'] != "Bus") {
          //           bluetooth.printCustom(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}",
          //               1,
          //               1);
          //         } else {
          //           bluetooth.printCustom(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-${tickets[i]['to_km']}\t${tickets[i]['baggage']}\t\t\t",
          //               1,
          //               1);
          //         }
          //       } else {
          //         if (coopData['coopType'] != "Bus") {
          //           bluetooth.print3Column(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //               "$timeOnly",
          //               "${tickets[i]['baggage']}",
          //               1);
          //         } else {
          //           bluetooth.print4Column(
          //               "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
          //               "$timeOnly",
          //               "${tickets[i]['baggage']}",
          //               "",
          //               1);
          //         }
          //       }
          //     }
          //   }
          // }
          //
          if (havestudent) {
            bluetooth.printLeftRight("STUDENT", "", 1);
            // bluetooth.printCustom("STUDENT", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['fare'] > 0 &&
                  (tickets[i]['cardType'] == 'mastercard' ||
                      tickets[i]['cardType'] == 'cash') &&
                  tickets[i]['passengerType'] == 'student') {
                studentcount += tickets[i]['pax'] as int;
                discountedcount += tickets[i]['pax'] as int;

                // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
                // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
                // grandcashreceived +=
                //     double.parse(tickets[i]['fare'].toString()) +
                //         double.parse(tickets[i]['additionalFare'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['fare']}",
                //     1);
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";

                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        "${tickets[i]['pax']}",
                        1);
                  } else {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        1);
                  }
                }
              }
            }
          }

          if (havesenior) {
            bluetooth.printLeftRight("SENIOR", "", 1);
            // bluetooth.printCustom("SENIOR", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['fare'] > 0 &&
                  (tickets[i]['cardType'] == 'mastercard' ||
                      tickets[i]['cardType'] == 'cash') &&
                  tickets[i]['passengerType'] == 'senior') {
                seniorcount += tickets[i]['pax'] as int;
                discountedcount += tickets[i]['pax'] as int;

                // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
                // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
                // grandcashreceived +=
                //     double.parse(tickets[i]['fare'].toString()) +
                //         double.parse(tickets[i]['additionalFare'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['fare']}",
                //     1);
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        "${tickets[i]['pax']}",
                        1);
                  } else {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        1);
                  }
                }
              }
            }
          }
          if (havepwd) {
            bluetooth.printLeftRight("PWD", "", 1);
            // bluetooth.printCustom("PWD", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['fare'] > 0 &&
                  (tickets[i]['cardType'] == 'mastercard' ||
                      tickets[i]['cardType'] == 'cash') &&
                  tickets[i]['passengerType'] == 'pwd') {
                pwdcount += tickets[i]['pax'] as int;
                discountedcount += tickets[i]['pax'] as int;

                // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
                // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);
                // grandcashreceived +=
                //     double.parse(tickets[i]['fare'].toString()) +
                //         double.parse(tickets[i]['additionalFare'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['fare']}",
                //     1);
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        "${tickets[i]['pax']}",
                        1);
                  } else {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        1);
                  }
                }
              }
            }
          }
          if (havecardsales) {
            bluetooth.printLeftRight("CS TICKET", "", 1);
            // bluetooth.printCustom("CARD SALES", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if ((tickets[i]['cardType'] != 'mastercard' &&
                      tickets[i]['cardType'] != 'cash') &&
                  tickets[i]['fare'] > 0) {
                cardsalescount += tickets[i]['pax'] as int;
                if (tickets[i]['passengerType'] == "regular" ||
                    tickets[i]['passengerType'] == "FULL FARE") {
                  regularcount += tickets[i]['pax'] as int;
                }
                if (tickets[i]['passengerType'] == "student") {
                  studentcount += tickets[i]['pax'] as int;
                }
                if (tickets[i]['passengerType'] == "senior") {
                  seniorcount += tickets[i]['pax'] as int;
                }
                if (tickets[i]['passengerType'] == "pwd") {
                  pwdcount += tickets[i]['pax'] as int;
                }

                // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
                // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);

                // grandcardsales += double.parse(tickets[i]['fare'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['fare']}",
                //     1);
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)} $timeOnly   ${tickets[i]['from_km']}-$toKm ${tickets[i]['fare'].toStringAsFixed(2)}  ${tickets[i]['pax']}  ",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['fare']}",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        "${tickets[i]['pax']}",
                        1);
                  } else {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['fare']}",
                        1);
                  }
                }
              }
            }
          }
          if (havecardsalesbaggage) {
            bluetooth.printLeftRight("CS BAGGAGE", "", 1);
            // bluetooth.printCustom("CARD SALES", 1, 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if ((tickets[i]['cardType'] != 'mastercard' &&
                      tickets[i]['cardType'] != 'cash') &&
                  tickets[i]['fare'] == 0) {
                cardsalescount += tickets[i]['pax'] as int;

                // bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);
                // bluetooth.printCustom("123456\t0\t23\t61", 1, 1);

                // grandcardsales +=
                //     double.parse(tickets[i]['baggage'].toString());
                // bluetooth.print4Column(
                //     "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                //     "${tickets[i]['from_km']}",
                //     "${tickets[i]['to_km']}",
                //     "${tickets[i]['fare']}",
                //     1);
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['baggage']}\t\t\t",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['baggage']}",
                        1);
                  } else {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['baggage']}",
                        "",
                        1);
                  }
                }
              }
            }
          }
          if (haveAddFare) {
            bluetooth.printLeftRight("ADD FARE", "", 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['additionalFare'] > 0 &&
                  (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                      tickets[i]['additionalFareCardType'] == 'cash')) {
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}\t\t\t",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['additionalFare']}",
                        1);
                  } else {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['additionalFare']}",
                        "",
                        1);
                  }
                }
              }
            }
          }
          if (haveCsAddfare) {
            bluetooth.printLeftRight("CS ADD FARE", "", 1);

            for (int i = 0; i < tickets.length; i++) {
              num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
              if (tickets[i]['additionalFare'] > 0 &&
                  tickets[i]['additionalFareCardType'] != 'mastercard' &&
                  tickets[i]['additionalFareCardType'] != 'cash') {
                DateTime dateTime =
                    DateTime.parse(tickets[i]['created_on'].toString());
                String timeOnly = "${dateTime.hour}:${dateTime.minute}";
                if (!fetchservice.getIsNumeric()) {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}",
                        1,
                        1);
                  } else {
                    bluetooth.printCustom(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}\t$timeOnly\t${tickets[i]['from_km']}-$toKm\t${tickets[i]['additionalFare']}\t\t\t",
                        1,
                        1);
                  }
                } else {
                  if (coopData['coopType'] != "Bus") {
                    bluetooth.print3Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['additionalFare']}",
                        1);
                  } else {
                    bluetooth.print4Column(
                        "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}",
                        "$timeOnly",
                        "${tickets[i]['additionalFare']}",
                        "",
                        1);
                  }
                }
              }
            }
          }

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printLeftRight("TICKET ISSUED:", "$totalticketcount", 1);
          bluetooth.printLeftRight("BAGGAGE ISSUED:", "$baggage", 1);
          bluetooth.printLeftRight("REGULAR ISSUED:", "$regularcount", 1);
          bluetooth.printLeftRight("STUDENT ISSUED:", "$studentcount", 1);
          bluetooth.printLeftRight("PWD ISSUED:", "$pwdcount", 1);
          bluetooth.printLeftRight("SENIOR ISSUED:", "$seniorcount", 1);

          bluetooth.printLeftRight("DISC ISSUED:", "$discountedcount", 1);
          bluetooth.printLeftRight("CS ISSUED:", "$cardsalescount", 1);
          bluetooth.printLeftRight("CARD SALES:", "$grandcardsales", 1);
          bluetooth.printLeftRight("CASH RECEIVED:", "$grandcashreceived", 1);

          // bluetooth.printLeftRight(
          //     "BWP TOTAL:", "$grandbaggagewithpassenger", 1);
          // bluetooth.printLeftRight("BO TOTAL:", "$grandbaggageonly", 1);
          bluetooth.printLeftRight("BAGGAGE TOTAL:", "$grandbaggage", 1);
          bluetooth.printLeftRight("ADD FARE:", "$addfare", 1);
          bluetooth.printLeftRight("GRAND TOTAL:", "$grandtotal", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          // } else {
          //   for (int i = 0; i < tickets.length; i++) {
          //     bluetooth.printCustom("DATE: ${tickets[i]['timestamp']}", 1, 1);

          //     bluetooth.printCustom(
          //         "Ticket No: ${tickets[i]['FLUTticket_no']}", 1, 1);
          //     bluetooth.printLeftRight(
          //         "FROM:", "${tickets[i]['from_place']}", 1);
          //     bluetooth.printLeftRight("TO:", "${tickets[i]['to_place']}", 1);
          //     bluetooth.printLeftRight(
          //         "BAGGAGE:",
          //         "${double.parse(tickets[i]['fare'].toString()).round()}",
          //         1);
          //     bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          //   }
          // }

          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpPassengerReceipt(
      String sNo,
      String MCsNo,
      String vehicleNo,
      double amount,
      double previousBalance,
      double newBalance,
      double conductorpreviousBalance,
      double conductornewBalance,
      String referenceNumber) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TOP-UP CONDUCTOR'S COPY RECEIPT", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printCustom("REF NO: $referenceNumber", 1, 1);
          bluetooth.printCustom("SN: $MCsNo", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
          bluetooth.printLeftRight(
              "AMOUNT:", "${amount.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight("PREV BALANCE:",
              "${conductorpreviousBalance.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "NEW BALANCE:", "${conductornewBalance.toStringAsFixed(2)}", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

          bluetooth.printNewLine();
          bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TOP-UP PASSENGER'S COPY RECEIPT", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printCustom("REF NO: $referenceNumber", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          bluetooth.printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
          bluetooth.printLeftRight(
              "AMOUNT:", "${amount.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpMasterCard(
      String sNo,
      String cardOwner,
      double amount,
      double previousBalance,
      double newBalance,
      String referenceNumber,
      String cashierName) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (cardOwner.length > 16) {
      cardOwner = cardOwner.substring(0, 15);
    }
    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TOP-UP CASHIER'S COPY RECEIPT", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printCustom("REF NO: $referenceNumber", 1, 1);

          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          bluetooth.printLeftRight("SN:", "$sNo", 1);
          bluetooth.printLeftRight("CARD OWNER:", "$cardOwner", 1);
          bluetooth.printLeftRight("CASHIER:", "$cashierName", 1);
          bluetooth.printLeftRight(
              "AMOUNT:", "${amount.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

          bluetooth.printNewLine();
          bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("TOP-UP COPY RECEIPT", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);

          bluetooth.printCustom("REF NO: $referenceNumber", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          bluetooth.printLeftRight("SN:", "$sNo", 1);
          bluetooth.printLeftRight("CARD OWNER:", "$cardOwner", 1);
          bluetooth.printLeftRight("CASHIER:", "$cashierName", 1);
          bluetooth.printLeftRight("AMOUNT:", "$amount", 1);
          bluetooth.printLeftRight(
              "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}", 1);
          bluetooth.printLeftRight(
              "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}", 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print('printTopUpMasterCard error: $e');
      return false;
    }
  }

  Future<bool> printCheckingBalance(
    String cardId,
    double amount,
  ) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      String formattedNumber = NumberFormat("#,##0", "en_US")
          .format(double.parse(amount.toStringAsFixed(2)));
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }

          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("CHECKING BALANCE RECEIPT", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);
          bluetooth.printCustom("SN: $cardId", 1, 1);

          bluetooth.printCustom("BALANCE: ${amount.toStringAsFixed(2)}", 1, 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();

          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printViolation(
      String torNo,
      String route,
      String dateoftrip,
      String vehicleNo,
      String bound,
      String inspectorName,
      String employeeName,
      String violation) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("VIOLATION REPORT", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);

          bluetooth.printCustom("TOR NO: $torNo", 1, 1);
          bluetooth.printCustom("ROUTE: $route", 1, 1);
          bluetooth.printCustom("DATE OF TRIP: $dateoftrip", 1, 1);
          bluetooth.printLeftRight('Vehicle No', '$vehicleNo', 1);
          bluetooth.printLeftRight('Bound', '$bound', 1);
          bluetooth.printLeftRight('INSP NAME:', '$inspectorName', 1);
          bluetooth.printLeftRight('EMP NAME:', '$employeeName', 1);
          bluetooth.printCustom("VIOLATION: $violation", 1, 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();

          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printAdditionalFare(
      Map<String, dynamic> item, double amount) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("ADDITIONAL FARE", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);

          bluetooth.printCustom("Ticket No: ${item['ticket_no']}", 1, 1);
          bluetooth.printCustom("ROUTE: ${item['route']}", 1, 1);
          if (!fetchservice.getIsNumeric()) {
            bluetooth.printLeftRight('FROM', '${item['from_place']}', 1);
            bluetooth.printLeftRight('TO', '${item['to_place']}', 1);
          }

          bluetooth.printLeftRight('ADDITIONAL FARE', '$amount', 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();

          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printFuel(Map<String, dynamic> item) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();
          bluetooth.printCustom(
              breakString("${coopData['cooperativeName']}", 24), 1, 1);
          if (coopData['telephoneNumber'] != null) {
            bluetooth.printCustom(
                "Contact Us: +63${coopData['telephoneNumber']}", 1, 1);
          }
          // bluetooth.printCustom("DEL MONTE LAND", 1, 1);
          // bluetooth.printCustom("TRANSPORT BUS COMPANY INC.", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);

          bluetooth.printCustom("FUEL RECEIPT", 1, 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);
          // bluetooth.printCustom("${type.toUpperCase()}", 1, 1);
          // bluetooth.printCustom("TOR#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("OT#: 123-456-789-910", 1, 1);
          // bluetooth.printCustom("CT#: 123-456-789-910", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          // bluetooth.printLeftRight("ATM:", "1", 1);

          bluetooth.printCustom("VEHICLE#: ${item['bus_no']}", 1, 1);
          bluetooth.printCustom("ROUTE: ${item['route']}", 1, 1);
          bluetooth.printCustom("ATTENDANT: ${item['fuel_attendant']}", 1, 1);
          bluetooth.printLeftRight('STATION', '${item['fuel_station']}', 1);
          bluetooth.printLeftRight('FULL TANK', '${item['full_tank']}', 1);
          bluetooth.printLeftRight('LITERS', '${item['fuel_liters']}', 1);
          bluetooth.printLeftRight(
              'PRICE PER LITER', '${item['fuel_price_per_liter']}', 1);
          bluetooth.printLeftRight('AMOUNT', '${item['fuel_amount']}', 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);
          bluetooth.printNewLine();

          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
