import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool _connected = false;
  Future<bool> connectToPrinter() async {
    BluetoothDevice? targetDevice;
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      print(devices);
      for (BluetoothDevice device in devices) {
        print('device.address: ${device.address}');
        if (device.address == '00:11:22:33:44:55' ||
            device.name == 'InnerPrinter') {
          targetDevice = device;
          break;
        }
      }
      if (targetDevice != null) {
        _connected = true;
      } else {
        bluetooth.onStateChanged().listen((state) {
          switch (state) {
            case BlueThermalPrinter.CONNECTED:
              _connected = true;
              print("bluetooth device state: connected");
              break;
            case BlueThermalPrinter.DISCONNECTED:
              _connected = false;
              print("bluetooth device state: disconnected");
              break;
            case BlueThermalPrinter.DISCONNECT_REQUESTED:
              _connected = false;
              print("bluetooth device state: disconnect requested");
              break;
            case BlueThermalPrinter.STATE_TURNING_OFF:
              _connected = false;
              print("bluetooth device state: bluetooth turning off");
              break;
            case BlueThermalPrinter.STATE_OFF:
              _connected = false;
              print("bluetooth device state: bluetooth off");
              break;
            case BlueThermalPrinter.STATE_ON:
              _connected = false;

              print("bluetooth device state: bluetooth on");
              break;
            case BlueThermalPrinter.STATE_TURNING_ON:
              _connected = false;
              print("bluetooth device state: bluetooth turning on");
              break;
            case BlueThermalPrinter.ERROR:
              _connected = false;
              print("bluetooth device state: error");
              break;
            default:
              print(state);
              break;
          }
        });
      }

      // Find the printer with the specified MAC address or name

      if (targetDevice != null) {
        print('targetDevice: $targetDevice');
        bool isConnected = await bluetooth.isConnected ?? false;
        if (!isConnected) {
          await bluetooth.connect(targetDevice).catchError((error) {
            _connected = false;
          });
          _connected = true;
        }
        return _connected;
      } else {
        print('Printer not found or not paired.');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
    // Retrieve the list of bonded (paired) devices
  }

  void disconnectFromPrinter() {
    if (_connected) {
      bluetooth.disconnect();
      _connected = false;
    }
  }

  // Add a function for printing if needed
  void printReceipt() {
    // Your printing logic here
  }
}

// void main() async {
//   final printerController = PrinterController();
//   await printerController.connectToPrinter();

//   if (printerController._connected) {
//     // Use the printer for printing
//     printerController.printReceipt();
//   }

//   // Don't forget to disconnect when done
//   printerController.disconnectFromPrinter();
// }
