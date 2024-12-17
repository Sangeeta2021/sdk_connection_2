//copy of HomeScreen with changes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/colors.dart';

class TestScreen2 extends StatefulWidget {
  const TestScreen2({super.key});

  @override
  State<TestScreen2> createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  String _weightCharacteristicUuid = ''; // To store the weight characteristic UUID
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
    PermissionStatus locationStatus = await Permission.locationWhenInUse.status;

    if (!bluetoothStatus.isGranted) {
      await Permission.bluetooth.request();
    }

    if (!locationStatus.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    await _startScan();
  }

  Future<void> _startScan() async {
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
      return;
    }

    setState(() {
      _deviceList.clear();
    });

    try {
      await platform.invokeMethod('startScan');
      print('Scanning for devices...');
    } on PlatformException catch (e) {
      print("Failed to start scan: ${e.message}");
    }
  }

  Future<void> _connectToDevice(String deviceAddress) async {
    try {
      final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
      print("Connected to device: $result");
      setState(() {
        _deviceName = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  Future<void> _getWeightData() async {
    if (_weightCharacteristicUuid.isEmpty) {
      setState(() {
        _weightData = 'Weight UUID not identified!';
      });
      return;
    }

    try {
      final result = await platform.invokeMethod('getWeightData', {'uuid': _weightCharacteristicUuid});
      print("Weight Data Retrieved: $result");
      setState(() {
        _weightData = result;
        print("weight data is......................: $result");
      });
    } catch (e) {
      print("Error getting weight data: $e");
      setState(() {
        _weightData = "Failed to retrieve weight data.";
      });
    }
  }

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onDeviceFound":
        Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
        setState(() {
          _deviceList.add(deviceInfo);
        });
        break;

      case "onServicesDiscovered":
        Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
        print("Discovered Services and Characteristics: $serviceInfo");

        // Extract the weight characteristic UUID from the discovered services
        String weightUuid = _extractWeightUuid(serviceInfo);
        if (weightUuid.isNotEmpty) {
          setState(() {
            _weightCharacteristicUuid = weightUuid;
          });
          print("Weight UUID identified: $_weightCharacteristicUuid");
        } else {
          print("No weight UUID found in discovered services.");
        }


        break;

      case "onWeightDataReceived":
        setState(() {
          _weightData = call.arguments;
        });
        break;

      default:
        throw MissingPluginException("Not implemented: ${call.method}");
    }
  }

  String _extractWeightUuid(Map<String, dynamic> serviceInfo) {
    for (var serviceUuid in serviceInfo.keys) {
      var characteristics = serviceInfo[serviceUuid];
      // Known UUIDs for weight data
      if (serviceUuid == "0000ffb0-0000-1000-8000-00805f9b34fb") {
        for (var characteristic in characteristics) {
          if ([
                "0000ffb1-0000-1000-8000-00805f9b34fb",
                "0000ffb2-0000-1000-8000-00805f9b34fb",
                "0000ffb3-0000-1000-8000-00805f9b34fb"
              ].contains(characteristic)) {
            return characteristic;
          }
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: const Text('SDK Connection , TestScreen2', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _detailsRow("Connected Device:  ", _deviceName),
            const SizedBox(height: 20),
            _detailsRow("Weight Data:  ", _weightData),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getWeightData,
              child: const Text('Get Weight Data'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_deviceList[index]['name']!),
                    subtitle: Text(_deviceList[index]['address']!),
                    onTap: () async {
                      await _connectToDevice(_deviceList[index]['address']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: const TextStyle(color: Colors.black)),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}
