import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/http.dart';

class httprequestService {
  final _myBox = Hive.box('myBox');
  String bearerToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiZnVuY3Rpb24gbm93KCkgeyBbbmF0aXZlIGNvZGVdIH0iLCJpYXQiOjE2OTcwOTcyNjl9.tT7GdpjGqGRRuP83ts2Ok2arhVu8sAyFKWjd8M7do9k';

  // Replace 'https://api.example.com/data' with the actual API endpoint URL
  Future<bool> isDeviceValid() async {
    try {
      final session = _myBox.get('SESSION');
      String serialNumber = session['serialNumber'];
      print('serialNumber: $serialNumber');
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/device/deviceId/$serialNumber";
      Map<String, dynamic> coopData = {};
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed`
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        coopData = data['response'];
        session['coopId'] = coopData['coopId'];

        print('isDeviceValid: $coopData');
        _myBox.put('SESSION', session);
        return true;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getCoopData(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/cooperative/$coopId";
      Map<String, dynamic> coopData = {};
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        coopData = data['response'];

        print('coopData: $coopData');
        _myBox.put('coopData', coopData);
        return true;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getFilipayCardList() async {
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/filipaycard";
      List<Map<String, dynamic>> filipayCardList = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 240));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        filipayCardList =
            (data['response'] as List<dynamic>).cast<Map<String, dynamic>>();

        print('filipayCardList: $filipayCardList');
        _myBox.put('filipayCardList', filipayCardList);
        return true;
      } else {
        // Handle error responses
        print('filipayCardList Error: ${response.statusCode}');
        print('filipayCardList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('filipayCardList error: $e');
      return false;
    }
  }

  Future<bool> getRouteList(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/directions/$coopId";
      List<Map<String, dynamic>> getRouteList = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        getRouteList =
            (data['response'] as List<dynamic>).cast<Map<String, dynamic>>();

        print('getRouteList: $getRouteList');
        _myBox.put('routeList', getRouteList);
        return true;
      } else {
        // Handle error responses
        print('getRouteList Error: ${response.statusCode}');
        print('getRouteList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getStationList(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/station/$coopId";
      List<Map<String, dynamic>> stationList = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        stationList =
            (data['response'] as List<dynamic>).cast<Map<String, dynamic>>();

        print('stationList: $stationList');
        _myBox.put('stationList', stationList);
        return true;
      } else {
        // Handle error responses
        print('stationList Error: ${response.statusCode}');
        print('stationList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getVehicleList(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/vehicle/$coopId";
      Map<String, dynamic> vehicleList = {
        "messages": [
          {
            "code": 500,
            "message": "CHECK YOUR INTERNET CONNECTION",
          }
        ],
        "response": {}
      };
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        vehicleList = json.decode(response.body);

        print('vehicleList: $vehicleList');
        _myBox.put('vehicleListDB', vehicleList['response']);
        return true;
      } else {
        // Handle error responses
        print('vehicleList Error: ${response.statusCode}');
        print('vehicleList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getcardList(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/employeecard/$coopId";
      List<Map<String, dynamic>> cardList = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        cardList =
            (data['response'] as List<dynamic>).cast<Map<String, dynamic>>();

        print('cardList: $cardList');
        _myBox.put('cardList', cardList);

        return true;
      } else {
        // Handle error responses
        print('cardList Error: ${response.statusCode}');
        print('cardList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getemployeeList(String coopId) async {
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/employee/$coopId";
      List<Map<String, dynamic>> employeeList = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        employeeList =
            (data['response'] as List<dynamic>).cast<Map<String, dynamic>>();

        print('employeeList: $employeeList');
        for (int i = 0; i < employeeList.length; i++) {
          print('employeeList$i: ${employeeList[i]}');
        }
        _myBox.put('employeeList', employeeList);
        return true;
      } else {
        // Handle error responses
        print('employeeList Error: ${response.statusCode}');
        print('employeeList Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getRiderWalletData() async {
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/riderwallet";
      List<Map<String, dynamic>> riderWalletData = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> responseList = data['response'];

        if (responseList != null) {
          riderWalletData = List<Map<String, dynamic>>.from(responseList);
        }

        print('riderWalletData: $riderWalletData');
        _myBox.put('riderWallet', riderWalletData);
        return true;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('getRiderWalletData error: $e');
      return false;
    }
  }

  Future<bool> getRiderData() async {
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/rider";
      List<Map<String, dynamic>> riderData = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> responseList = data['response'];

        if (responseList != null) {
          riderData = List<Map<String, dynamic>>.from(responseList);
        }

        print('riderData: $riderData');
        _myBox.put('rider', riderData);
        return true;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('riderData error: $e');
      return false;
    }
  }

  Future<bool> getMasterCardData() async {
    final coopData = _myBox.get('coopData');
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/mastercard/${coopData['_id']}";
      List<Map<String, dynamic>> masterCardData = [];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> responseList = data['response'];

        if (responseList != null) {
          masterCardData = List<Map<String, dynamic>>.from(responseList);
        }

        print('masterCardData: $masterCardData');
        _myBox.put('masterCardList', masterCardData);
        return true;
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('getMasterCardData error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> updateOnlineCardBalance(String cardId,
      double amount, bool isDecrease, String cardType, bool isNegative) async {
    try {
      final coopData = _myBox.get('coopData');
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/riderwallet";
      String updater = 'increaseAmount';
      if (isDecrease) {
        updater = 'decreaseAmount';
      }
      final Map<String, dynamic> requestBody = {
        "cardId": "$cardId",
        "$updater": amount,
        "cardType": "$cardType",
        "isNegative": isNegative,
        "coopId": "${coopData['_id']}"
      };

      final response = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 10));
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        // Successful response

        print('updateOnlineCardBalance data: $data');
        return data;
      } else {
        // Handle error responses
        print('updateOnlineCardBalanceError: ${response.statusCode}');
        print(' updateOnlineCardBalance Response body: ${response.body}');
        return data;
      }
    } catch (e) {
      if (e is ClientException) {
        // Handle connection failure
        print('Connection failed: $e');
        return {
          "messages": [
            {
              "code": 2,
              "message": "Connection failed",
            }
          ],
          "response": {}
        };
      } else {
        // Handle other errors
        print("updateOnlineCardBalance error: $e");
        return {
          "messages": [
            {
              "code": 1,
              "message": "Something went wrong",
            }
          ],
          "response": {}
        };
      }
    }
  }

  Future<Map<String, dynamic>> topUpPassenger(
      String passengerCardId, String masterCardId, double amount) async {
    final coopData = _myBox.get('coopData');
    Map<String, dynamic> masterCarddata = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/filipaycard/mastercard/";

      final Map<String, dynamic> MasterCardrequestBody = {
        "masterCardId": "$masterCardId",
        "filipayCardId": "$passengerCardId",
        "amount": amount,
        "coopId": "${coopData['_id']}"
      };

      final responseMastercard = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(MasterCardrequestBody),
          )
          .timeout(Duration(seconds: 30));
      masterCarddata = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('masterCarddata: $masterCarddata');
        if (masterCarddata['messages'][0]['code'].toString() == "0") {
          return masterCarddata;
        } else {
          return masterCarddata;
        }
      } else {
        // Handle error responses
        print('Error: ${responseMastercard.statusCode}');
        print('Response body: ${responseMastercard.body}');
        return masterCarddata;
      }
    } catch (e) {
      print(e);
      return masterCarddata;
    }
  }

  Future<String> getDLTBSessionToken() async {
    String token = '';
    String username = 'filipay';
    String password = '#LNxj.WRY58Q';
    String apiUrl =
        "https://s833502.fmphost.com/fmi/data/v1/databases/dltb%20booking/sessions";
    try {
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      ).timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        // Successful response
        print('Response data: ${response.body}');
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        token = jsonResponse['response']['token'];
      } else {
        // Handle error responses
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return token;
    } catch (e) {
      print(e);
      return token;
    }
  }

  Future<Map<String, dynamic>> verifyBooking(String ticketNo) async {
    Map<String, dynamic> bookingData = {};
    print('ticketNo: $ticketNo');
    String apiUrl = "http://filipworks.com/dltb-api/checkin.php";

    try {
      String token = await getDLTBSessionToken();
      // String token = "f0f7851a73196d6802ec92cfb524fe8a55abca411397408641ds";

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "ticketNo": ticketNo,
          "token": token,
        },
      ).timeout(Duration(seconds: 30));
      print('response: ${response.body}');
      if (response.statusCode == 200) {
        // Successful response
        print('Response data: ${response.body}');
        bookingData = json.decode(response.body);
      } else {
        // Handle error responses
        print('Response Error Code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      print('http response bookingData: $bookingData');
      return bookingData;
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": [
            {"code": "500", "message": "NO INTERNET"}
          ]
        };
      }
      print(e);
      return {
        "messages": [
          {"code": "500", "message": "SOMETHING WENT WRONG"}
        ]
      };
    }
  }

  Future<bool> checkInUpdate(String recordId) async {
    final session = _myBox.get('SESSION');
    String deviceId = session['serialNumber'];
    Map<String, dynamic> bookingData = {};
    print('recordId: $recordId');
    String apiUrl = "http://filipworks.com/dltb-api/updatecheckin.php";

    try {
      String token = await getDLTBSessionToken();
      // String token = "f0f7851a73196d6802ec92cfb524fe8a55abca411397408641ds";

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"token": token, "recordId": recordId, "deviceId": deviceId},
      ).timeout(Duration(seconds: 30));
      print('checkInUpdate response: ${response.body}');
      if (response.statusCode == 200) {
        // Successful response
        print('checkInUpdate Response data: ${response.body}');
        bookingData = json.decode(response.body);
        print('checkInUpdate bookingData: $bookingData');
      } else {
        // Handle error responses
        print('checkInUpdate Response Error Code: ${response.statusCode}');
        print('checkInUpdate Response body: ${response.body}');
      }
      // print('http response checkInUpdate: $bookingData');
      return true;
    } catch (e) {
      print("checkInUpdate error: $e");
      return false;
    }
  }

  // tor http request

  Future<Map<String, dynamic>> torTicket(Map<String, dynamic> item) async {
    print('sendtocketTicket body requestsss: $item');
    Map<String, dynamic> masterCarddata = {
      "messages": {
        "code": 500,
        "message": "SOMETHING WENT WRONG",
      },
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/ticket/${item['ticket_no']}";
      // String apiUrl =
      //     "http://filipworks.com/dltb-api/torTicket/addTorTicket.php";
      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseMastercard = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 5));
      print('sendtocketTicket Raw Response: ${responseMastercard.body}');
      masterCarddata = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('sendtocketTicket: $masterCarddata');
        if (masterCarddata['messages']['code'].toString() == "0") {
          return masterCarddata;
        } else {
          return masterCarddata;
        }
      } else {
        // Handle error responses
        print('sendtocketTicket Error: ${responseMastercard.statusCode}');
        print('sendtocketTicket Response body: ${responseMastercard.body}');
        return masterCarddata;
      }
    } catch (e) {
      print("sendtocketTicket error: $e");
      if (e is ClientException) {
        return {
          "messages": {"code": "500", "message": "NO INTERNET"}
        };
      } else {
        return {
          "messages": {
            "code": 500,
            "message": "SOMETHING WENT WRONG",
          },
          "response": {}
        };
      }
    }
  }

  Future<Map<String, dynamic>> updateTorTrip(Map<String, dynamic> item) async {
    print('updateTorTrip body: $item');
    Map<String, dynamic> updateTorTrip = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/trip/${item['control_no']}";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseMastercard = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));
      updateTorTrip = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('updateTorTrip: $updateTorTrip');
        if (updateTorTrip['messages'][0]['code'].toString() == "0") {
          return updateTorTrip;
        } else {
          return updateTorTrip;
        }
      } else {
        // Handle error responses
        print('updateTorTrip Error: ${responseMastercard.statusCode}');
        print('updateTorTrip Response body: ${responseMastercard.body}');
        return updateTorTrip;
      }
    } catch (e) {
      print("updateTorTrip: $e");
      return updateTorTrip;
    }
  }

  Future<Map<String, dynamic>> addTorMain(Map<String, dynamic> item) async {
    Map<String, dynamic> addTorMain = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/tor/main";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseMastercard = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));
      addTorMain = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('addTorMain: $addTorMain');
        if (addTorMain['messages'][0]['code'].toString() == "0") {
          return addTorMain;
        } else {
          return addTorMain;
        }
      } else {
        // Handle error responses
        print('addTorMain Error: ${responseMastercard.statusCode}');
        print('addTorMain Response body: ${responseMastercard.body}');
        return addTorMain;
      }
    } catch (e) {
      print("addTorMain: $e");
      return addTorMain;
    }
  }

  Future<Map<String, dynamic>> updateTorMain(Map<String, dynamic> item) async {
    print('updateTorMain req body: $item');
    Map<String, dynamic> updateTorMain = {
      "messages": {
        "code": 500,
        "message": "SOMETHING WENT WRONG",
      },
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/main/${item['UUID']}";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseupdateTorMain = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));
      updateTorMain = json.decode(responseupdateTorMain.body);
      if (responseupdateTorMain.statusCode == 200) {
        // Successful response

        print('updateTorMain: $updateTorMain');
        if (updateTorMain['messages']['code'].toString() == "0") {
          return updateTorMain;
        } else {
          return updateTorMain;
        }
      } else {
        // Handle error responses
        print('updateTorMain Error: ${responseupdateTorMain.statusCode}');
        print('updateTorMain Response body: ${responseupdateTorMain.body}');
        return updateTorMain;
      }
    } catch (e) {
      print("updateTorMain: $e");
      return updateTorMain;
    }
  }

  Future<Map<String, dynamic>> addTorFuel(Map<String, dynamic> item) async {
    print('addTorFuel body: ${item}');
    Map<String, dynamic> addTorMain = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/tor/fuel";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseMastercard = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode({"fieldData": item}),
          )
          .timeout(Duration(seconds: 30));
      addTorMain = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('addTorFuel: $addTorMain');
        if (addTorMain['messages'][0]['code'].toString() == "0") {
          return addTorMain;
        } else {
          return addTorMain;
        }
      } else {
        // Handle error responses
        print('addTorFuel Error: ${responseMastercard.statusCode}');
        print('addTorFuel Response body: ${responseMastercard.body}');
        return addTorMain;
      }
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": [
            {"code": 500, "message": "NO INTERNET"}
          ]
        };
      } else {
        return addTorMain;
      }
    }
  }

  Future<Map<String, dynamic>> torTrip(Map<String, dynamic> item) async {
    print('sendtorTrip torTrip body req: $item');
    Map<String, dynamic> torTrip = {
      "messages": [
        {
          "code": 500,
          "message": "CHECK YOUR INTERNET CONNECTION",
        }
      ],
      "response": {}
    };
    // try {
    String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/tor/trip";

    // final Map<String, dynamic> MasterCardrequestBody = {
    //   "masterCardId": "$masterCardId",
    //   "filipayCardId": "$passengerCardId",
    //   "amount": amount
    // };

    final responseMastercard = await http
        .post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json',
            // Add other headers if needed
          },
          body: jsonEncode(item),
        )
        .timeout(Duration(seconds: 30));
    torTrip = json.decode(responseMastercard.body);
    print('sendtorTrip torTrip: $torTrip');
    if (responseMastercard.statusCode == 200) {
      // Successful response

      print('sendtorTrip: $torTrip');
      if (torTrip['messages'][0]['code'].toString() == "0") {
        return torTrip;
      } else {
        return torTrip;
      }
    } else {
      // Handle error responses
      print('sendtorTrip Error: ${responseMastercard.statusCode}');
      print('sendtorTrip Response body: ${responseMastercard.body}');
      return torTrip;
    }
    // } catch (e) {
    //   print("sendtorTrip: $e");
    //   print('sendtorTrip torTrip error: $torTrip');
    //   return torTrip;
    // }
  }

  Future<Map<String, dynamic>> addInspection(Map<String, dynamic> item) async {
    print('addInspection body: ${item}');
    Map<String, dynamic> torTrip = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/inspection";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseMastercard = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));
      torTrip = json.decode(responseMastercard.body);
      if (responseMastercard.statusCode == 200) {
        // Successful response

        print('addInspection: $torTrip');
        if (torTrip['messages'][0]['code'].toString() == "0") {
          return torTrip;
        } else {
          return torTrip;
        }
      } else {
        // Handle error responses
        print('addInspection Error: ${responseMastercard.statusCode}');
        print('addInspection Response body: ${responseMastercard.body}');
        return torTrip;
      }
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": [
            {"code": "500", "message": "NO INTERNET"}
          ]
        };
      } else {
        return torTrip;
      }
    }
  }

  Future<Map<String, dynamic>> addViolation(Map<String, dynamic> item) async {
    print('addViolation body: ${item}');
    Map<String, dynamic> torViolation = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl = "http://172.232.77.205:3000/api/v1/filipay/tor/violation";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      print('addViolation request body: $item');
      final responseMastercard = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));

      if (responseMastercard.statusCode == 200) {
        // Successful response
        torViolation = json.decode(responseMastercard.body);
        print('addInspection: $torViolation');
        if (torViolation['messages'][0]['code'].toString() == "0") {
          return torViolation;
        } else {
          return torViolation;
        }
      } else {
        // Handle error responses
        print('addInspection Error: ${responseMastercard.statusCode}');
        print('addInspection Response body: ${responseMastercard.body}');
        return torViolation;
      }
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": [
            {"code": "500", "message": "NO INTERNET"}
          ]
        };
      } else {
        return torViolation;
      }
    }
  }

  Future<Map<String, dynamic>> addTorRemittance(
      Map<String, dynamic> item) async {
    Map<String, dynamic> torRemittance = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/remittance";

      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responsetorRemittance = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));

      if (responsetorRemittance.statusCode == 200) {
        // Successful response
        torRemittance = json.decode(responsetorRemittance.body);
        print('addTorRemittance: $torRemittance');
        if (torRemittance['messages'][0]['code'].toString() == "0") {
          return torRemittance;
        } else {
          return torRemittance;
        }
      } else {
        // Handle error responses
        print('addTorRemittance Error: ${responsetorRemittance.statusCode}');
        print('addTorRemittance Response body: ${responsetorRemittance.body}');
        return torRemittance;
      }
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": [
            {"code": "500", "message": "NO INTERNET"}
          ]
        };
      } else {
        return torRemittance;
      }
    }
  }

  Future<Map<String, dynamic>> updateAdditionalFare(
      Map<String, dynamic> item, bool isOffline) async {
    print('updateAdditionalFare body: $item');
    int lastAddFare = 0;
    if (!isOffline) {
      lastAddFare = item['items']['additionalFare'];
    }

    Map<String, dynamic> additionalFare = {
      "messages": [
        {
          "code": 500,
          "message": "SOMETHING WENT WRONG",
        }
      ],
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/tor/ticket/${item['items']['ticket_no']}";

      // String apiUrl =
      //     'http://filipworks.com/dltb-api/torTicket/updateTorTicket.php';
      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responsAdditionalFare = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));

      print('updateAdditionalFare response: ${responsAdditionalFare.body}');
      if (responsAdditionalFare.statusCode == 200) {
        // Successful response
        additionalFare = json.decode(responsAdditionalFare.body);
        print('updateAdditionalFare response: $additionalFare');
        if (additionalFare['messages']['code'].toString() == "0") {
          if (!isOffline) {
            item['items']['additionalFare'] += item['amount'];
          }
          return additionalFare;
        } else {
          if (!isOffline) {
            item['items']['additionalFare'] = lastAddFare;
          }

          return additionalFare;
        }
      } else {
        if (!isOffline) {
          item['items']['additionalFare'] = lastAddFare;
        }
        // Handle error responses
        print(
            'updateAdditionalFare response Error: ${responsAdditionalFare.statusCode}');
        print(
            'updateAdditionalFare Response body: ${responsAdditionalFare.body}');
        return additionalFare;
      }
    } catch (e) {
      if (!isOffline) {
        item['items']['additionalFare'] = lastAddFare;
      }
      if (e is ClientException) {
        return {
          "messages": [
            {"code": "200", "message": "NO INTERNET"}
          ]
        };
      } else {
        print('updateAdditionalFare response Error: $e');
        return additionalFare;
      }
    }
  }

  Future<Map<String, dynamic>> updateLocation(Map<String, dynamic> item) async {
    Map<String, dynamic> updateLocation = {
      "messages": {
        "code": 500,
        "message": "SOMETHING WENT WRONG",
      },
      "response": {}
    };
    try {
      String apiUrl =
          "http://172.232.77.205:3000/api/v1/filipay/device-location";

      // String apiUrl =
      //     'http://filipworks.com/dltb-api/torTicket/updateTorTicket.php';
      // final Map<String, dynamic> MasterCardrequestBody = {
      //   "masterCardId": "$masterCardId",
      //   "filipayCardId": "$passengerCardId",
      //   "amount": amount
      // };

      final responseupdateLocation = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
              // Add other headers if needed
            },
            body: jsonEncode(item),
          )
          .timeout(Duration(seconds: 30));

      print('updateLocation response: ${responseupdateLocation.body}');
      if (responseupdateLocation.statusCode == 200) {
        // Successful response
        updateLocation = json.decode(responseupdateLocation.body);
        print('updateLocation response: $updateLocation');
        if (updateLocation['messages']['code'].toString() == "0") {
          return updateLocation;
        } else {
          return updateLocation;
        }
      } else {
        // Handle error responses
        print(
            'updateLocation response Error: ${responseupdateLocation.statusCode}');
        print('updateLocation Response body: ${responseupdateLocation.body}');
        return updateLocation;
      }
    } catch (e) {
      if (e is ClientException) {
        return {
          "messages": {"code": "200", "message": "NO INTERNET"}
        };
      } else {
        print('updateLocation response Error: $e');
        return updateLocation;
      }
    }
  }
}
