import 'dart:math';

import 'package:uuid/uuid.dart';

class uuidService {
  String generateUUID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$timestamp$random';
  }
}
