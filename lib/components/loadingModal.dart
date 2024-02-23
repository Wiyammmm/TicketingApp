import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/components/color.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoadingModal {
  fetchServices fetchService = fetchServices();
  Map<String, dynamic> coopData = {};

  void showProcessing(BuildContext context) {
    coopData = fetchService.fetchCoopData();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PROCESSING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    coopData['_id'].toString() == "655321a339c1307c069616e9"
                        ? Image.asset(
                            'assets/loading-red.gif',
                            width: MediaQuery.of(context).size.width * 0.4,
                          )
                        : Image.asset(
                            'assets/loading.gif',
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                    Text(
                      'Please wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showLoading(BuildContext context) {
    coopData = fetchService.fetchCoopData();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // logic
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOADING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    coopData['_id'].toString() == "655321a339c1307c069616e9"
                        ? Image.asset(
                            'assets/loading-red.gif',
                            width: MediaQuery.of(context).size.width * 0.4,
                          )
                        : Image.asset(
                            'assets/loading.gif',
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                    Text(
                      'Please wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showSyncing(BuildContext context) {
    coopData = fetchService.fetchCoopData();
    final myBox = Hive.box('myBox');
    final SESSION = myBox.get('SESSION');
    final torTrip = myBox.get('torTrip');

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   'SYNCING',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //       color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  // ),
                  Text(
                    'TOR NO\n${torTrip[SESSION['currentTripIndex'] - 1]['tor_no']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  coopData['_id'].toString() == "655321a339c1307c069616e9"
                      ? Image.asset(
                          'assets/loading-red.gif',
                          width: MediaQuery.of(context).size.width * 0.4,
                        )
                      : Image.asset(
                          'assets/loading.gif',
                          width: MediaQuery.of(context).size.width * 0.4,
                        ),
                  Text(
                    'PLEASE WAIT...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
