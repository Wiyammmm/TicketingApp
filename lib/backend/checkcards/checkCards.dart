import 'package:dltb/backend/fetch/fetchAllData.dart';

class checkCards {
  fetchServices fetchservice = fetchServices();

  Map<String, dynamic>? isCardExisting(String cardID) {
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    List<Map<String, dynamic>> cardList = fetchservice.fetchCardList();
    for (int i = 0; i < cardList.length; i++) {
      print('cardList$i: ${cardList[i]}');
    }
    final card = cardList.firstWhere(
      (card) => card['cardId'].toString() == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    print('card: $card');

    if (card != {}) {
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );

      return Map<String, dynamic>.from(employee);
    }
    return null; // Employee not found
  }

  Map<String, dynamic>? dashboardisCardExisting(String cardID) {
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    List<Map<String, dynamic>> cardList = fetchservice.fetchCardList();
    final card = cardList.firstWhere(
      (card) => card['cardId'].toString == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    if (card != {}) {
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );

      return Map<String, dynamic>.from(employee);
    }
    return null; // Employee not found
  }
}
