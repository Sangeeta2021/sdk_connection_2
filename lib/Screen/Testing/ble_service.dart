import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleService {
  static const MethodChannel _channel = MethodChannel('com.example.ble_sdk_connection/ble');

  final Map<String, List<String>> serviceUuidCharacteristics = {
    "00001530-1212-efde-1523-785feabcd123": [
      "00001531-1212-efde-1523-785feabcd123",
      "00001532-1212-efde-1523-785feabcd123",
      "00001534-1212-efde-1523-785feabcd123",
    ],
    "0000ffb0-0000-1000-8000-00805f9b34fb": [
      "0000ffb1-0000-1000-8000-00805f9b34fb",
      "0000ffb2-0000-1000-8000-00805f9b34fb",
      "0000ffb3-0000-1000-8000-00805f9b34fb",
    ],
    "0000180a-0000-1000-8000-00805f9b34fb": [
      "00002a23-0000-1000-8000-00805f9b34fb",
      "00002a24-0000-1000-8000-00805f9b34fb",
      "00002a25-0000-1000-8000-00805f9b34fb",
    ],
  };

  Future<void> scanAndTestCharacteristics() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) async {
      print("Discovered device: ${scanResult.device.name} (${scanResult.device.id})");

      await scanResult.device.connect();
      print("Connected to ${scanResult.device.name}");

      List<BluetoothService> services = await scanResult.device.discoverServices();

      for (var service in services) {
        print("Service: ${service.uuid}");

        if (serviceUuidCharacteristics.containsKey(service.uuid.toString())) {
          for (var characteristicUuid in serviceUuidCharacteristics[service.uuid.toString()]!) {
            var characteristic = _getCharacteristic(service, characteristicUuid);

            if (characteristic == null) {
              print("Characteristic with UUID $characteristicUuid not found in service ${service.uuid}");
              continue; // Skip to the next characteristic if it's not found
            }

            print("Testing characteristic: ${characteristic.uuid}");

            try {
              List<int> value = await characteristic.read();
              print("Value for characteristic ${characteristic.uuid}: $value");

              if (isWeightData(value)) {
                print("Weight data found: $value");
                return;
              }
            } catch (e) {
              print("Error reading characteristic ${characteristic.uuid}: $e");
            }
          }
        }
      }
    }, onError: (e) {
      print("Error during scan: $e");
    });
  }

  BluetoothCharacteristic? _getCharacteristic(BluetoothService service, String characteristicUuid) {
    for (var characteristic in service.characteristics) {
      if (characteristic.uuid.toString() == characteristicUuid) {
        return characteristic;
      }
    }
    return null;
  }

  bool isWeightData(List<int> value) {
    if (value.isNotEmpty && value[0] == 0x01) {
      return true;
    }
    return false;
  }
}
